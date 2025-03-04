#!/bin/bash
#SBATCH --job-name=blc2fastq           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=8                   # Run on a single CPU
#SBATCH --mem=36gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --output=bcl2fastq_%j.log          # Standard output and error log 

pwd; hostname; date
 
pwd; hostname; date

ml load bcl2fastq2
ml R/4.2
export R_LIBS_USER=/kuhpc/work/biostat/e617n596/tools/R/4.2 

Rscript 1_PreProcess_bcl2fastq.R
 
date 