scRNA-seq Pipeline
================
Emily Nissen
2024-02-07

- [Pre-processing](#pre-processing)
- [Analysis](#analysis)

# Pre-processing

These steps are specifically for data from 10x genomics.

Demultiplex - if needed

``` bash
#!/bin/bash
#SBATCH --job-name=mkfastq      # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL       # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail  
#SBATCH --ntasks=16                   
#SBATCH --nodes=1
#SBATCH --mem=120gb                    # Job memory request
#SBATCH --time=5-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --output=mkfastq_%j.log          # Standard output and error log 

pwd; hostname; date
 
ml bcl2fastq2

/path/tools/cellranger-7.1.0/cellranger mkfastq --id=fastq --run=/path/to/run/folder --samplesheet=/path/to/run/folder/SampleSheet-1.csv

date
```

Run a for loop to get count data.

The output will be a folder with summary metrics and files needed for
downstream analysis.

``` r
args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

samples <- c("sample1","sample2","sample3")

if(group == 1){
  samples = samples[1]
}else if(group == 2){
  samples = samples[2]
}else if(group == 3){
  samples = samples[3]
}

cell.ranger <- "/path/tools/cellranger-7.1.0/cellranger "

for (sample in samples){
  cellranger.count <- paste0(cell.ranger, "count ",
                            "--id=", sample, " ",
                            "--transcriptome=/path/to/references/cellranger/refdata-gex-mm10-2020-A ",
                            "--fastqs=/path/to/fastq/outs/fastq_path/Project_SahaSC3_051524/", sample,
                            # " --sample=", sample.id, # not really needed if sample is already named intuitively
                            " --localcores=16")
  print(cellranger.count)
  system(cellranger.count)
}
```

# Analysis

<https://hbctraining.github.io/scRNA-seq/lessons/04_SC_quality_control.html>
