#!/bin/bash
#SBATCH --job-name=fastqc           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=8                  # Run on a single CPU
#SBATCH --mem=12gb                    # Job memory request
#SBATCH --time=1-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-4
#SBATCH --output=fastqc_%A_%a.log         # Standard output and error log 

pwd; hostname; date
 
ml load R
ml load fastqc
ml load cutadapt
ml load java

echo "Running R script"

echo "$SLURM_ARRAY_TASK_ID"

Rscript 1_PreProcess_fastqc.R $SLURM_ARRAY_TASK_ID
 
date 