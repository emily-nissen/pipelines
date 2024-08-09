#!/bin/bash
#SBATCH --job-name=pre2           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=END,FAIL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=8                   # Run on a single CPU
#SBATCH --mem=36gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=preprocess_2_%A_%a.log          # Standard output and error log 

pwd; hostname; date
 
pwd; hostname; date

ml load R/4.2
export R_LIBS_USER=/kuhpc/work/biostat/e617n596/tools/R/4.2 
ml load fastqc
ml load cutadapt
ml load java

Rscript 2_PreProcess_Cat_Trim_Fastqc.R $SLURM_ARRAY_TASK_ID
 
date 