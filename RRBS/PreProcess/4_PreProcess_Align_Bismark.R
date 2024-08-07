##########################################
# Title: Align
# Author: Emily Nissen
# Date: 8/7/2024
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

dir <- "/path/to/working/dir/"
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