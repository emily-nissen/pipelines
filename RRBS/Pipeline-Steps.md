scRNA-seq Pipeline
================
Emily Nissen
2024-02-07

- [Pre-processing](#pre-processing)
  - [Convert BCL to FastQ files](#convert-bcl-to-fastq-files)
  - [Concatenate files, trim adaptors, and
    FastQC](#concatenate-files-trim-adaptors-and-fastqc)
  - [Diversity Trim and Filtering](#diversity-trim-and-filtering)
  - [Align using Bismark](#align-using-bismark)
  - [Dedup](#dedup)
  - [Extract Methylation](#extract-methylation)
- [Analysis](#analysis)

# Pre-processing

These are the folders you will need in the project folder

``` bash
cd /path/to/folder

mkdir trimmedData
mkdir trimmedData/complete
mkdir fastqc
mkdir bismarkAlignments
mkdir extractMethylation
```

See the “PreProcess” folder for scripts that can be downloaded based on
the code in the following steps.

If the sequencing was done at the KUMC genomics core - they most likely
used the NuGEN Ovation RRBS Methyl-Seq technology. These steps follow
the recommendations found here:
<https://github.com/nugentechnologies/NuMetRRBS>

## Convert BCL to FastQ files

``` r
runfolder <- "/path/to/run/folder/"

convert <- paste0("bcl2fastq --runfolder-dir ", runfolder, 
                  " --input-dir ", runfolder, "Data/Intensities/BaseCalls/ --output-dir ",
                  runfolder, "Unaligned/ --sample-sheet ", runfolder, 
                  "SampleSheet.csv --use-bases-mask Y*,I8Y*,Y* --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0")

print(convert)
system(convert)
```

## Concatenate files, trim adaptors, and FastQC

``` r
args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
dir <- paste0(folder,"runfolder/Unaligned/Project_/")
out <- paste0(folder,"trimmedData/")
out2 <- paste0(folder,"fastqc/")

samples <- c()
files <- paste0("Sample_",samples)
# split into however many groups you want
if(group == 1){
  samples = samples[]
  files = files[]
}else if(group == 2){
  samples = samples[]
  files = files[]
}

i=1
for(file in files){
  zcat <- paste0("zcat ", dir, file, "/*R1*.fastq.gz >> ", dir, file, "/", samples[i], "_R1.fastq")
  print(zcat)
  system(zcat)
  print(gsub("R1","R3",zcat))
  system(gsub("R1","R3",zcat))
  
  trim <- paste0("/kuhpc/work/biostat/e617n596/tools/TrimGalore-0.6.6/trim_galore --output_dir ", out, 
                " --paired -a AGATCGGAAGAGC -a2 AAATCAAAAAAAC ", 
                dir, file, "/", samples[i], "_R1.fastq ",
                dir, file, "/", samples[i], "_R3.fastq")
  print(trim)
  system(trim)
  
  fast <- paste0("fastqc -o ", out2, " -f fastq -t 8 ", out, samples[i], "_R1_val_1.fq")
  print(fast)
  system(fast)
  print(gsub("R1_val_1","R3_val_2",fast))
  system(gsub("R1_val_1","R3_val_2",fast))
  
  i = i+1
}
```

## Diversity Trim and Filtering

``` r
args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
out.dir <- paste0(folder, "trimmedData/")

samples <- c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  trim <- paste0("python ", dir, "/trimRRBSdiversityAdaptCustomers.py -1 '", 
                out.dir, sample, "_R1_val_1.fq' -2 '",
                out.dir, sample, "_R3_val_2.fq'")
  print(trim)
  system(trim)
  
  move <- paste0("mv ", dir, sample,
                "_R*_trimmed.fq ", out.dir, "complete/")
  print(move)
  system(move)
}
```

## Align using Bismark

``` r
args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

dir <- "/path/to/folder/"
data.dir <- paste0(dir, "trimmedData/complete/")
out.dir <- paste0(dir, "bismarkAlignments/")

samples <- c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  bismark <- paste0("/kuhpc/work/biostat/e617n596/tools/Bismark-0.22.3/bismark --bowtie2 --path_to_bowtie2 /kuhpc/software/7/install/bowtie2/2.3.5.1/ --output_dir ", 
                    out.dir, " --multicore 8 --samtools_path /kuhpc/software/7/install/samtools/1.9/bin /kuhpc/work/biostat/e617n596/References/bismark/hg38 -1 ", 
                    dir, sample, "_R1_val_1_trimmed.fq -2 ", dir, sample, "_R3_val_2_trimmed.fq")
  
  print(bismark)
  systme(bismark)
}
```

## Dedup

<https://github.com/tecangenomics/nudup>

``` r
args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "path/to/folder/"
dir <- paste0(folder,"bismarkAlignments/")
ix.dir <- paste0(folder,"runfolder/Project_/")
tmp.dir <- folder

samples <- c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  #  First, need to convert bam to sam
  convert <- paste0("samtools view -h -o ", dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam ", 
                    dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.bam")
  print(convert)
  system(convert)
  
  # Second, need to strip sam file to correct names
  strip <- paste0("strip_bismark_sam.sh ", dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam")
  print(strip)
  system(strip)
  
  ## Third, run dedup script
  dedup <- paste0("python nudup.py -2 -f ", ix.dir, "Project_", sample, "/", sample, "_R2.fastq -o ",
                  sample, "_trimmed_bismark_stripped -T ", tmp.dir, "tmp", sample, " ", 
                  dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam_stripped.sam")
  print(dedup)
  system(dedup)
}
```

## Extract Methylation

``` r
args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
dir <- paste0(folder,"bismarkAlignments/")
out.dir <- paste0(folder,"extractMethylation/")

samples <- c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  sort <- paste0("samtools sort -n -o ", dir, sample, "_trimmed_bismark_stripped_dedup.bam ", 
                 dir, sample, "_trimmed_bismark_stripped.sorted.dedup.bam")
  print(sort)
  system(sort)
  
  extract <- paste0("/kuhpc/work/biostat/e617n596/tools/Bismark-0.22.3/bismark_methylation_extractor --paired-end -o ",
                    out.dir, sample, " --bedGraph --multicore 8 ", dir, sample, "_trimmed_bismark_stripped.dedup.bam")
  print(extract)
  system(extract)
}
```

# Analysis
