#!/bin/bash
#SBATCH --job-name=trim           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --cpus-per-task=8
#SBATCH --mem=12gb                    # Job memory request -- SET TO APPROPRIATE AMOUNT
#SBATCH --time=1-00:00:00             # Time limit days-hrs:min:sec -- SET TO APPROPRIATE AMOUNT
#SBATCH --array=1-4
#SBATCH --output=trim_%A_%a.log         # Standard output and error log 

pwd; hostname; date

source ~/.bashrc
 
ml load R
ml load fastqc
ml load cutadapt
ml load java

echo "Running R script"

echo "$SLURM_ARRAY_TASK_ID"

PFOLDER=/path/to/project/folder
RUNFOLDER=/path/to/run/folder

Rscript 1.2_PreProcess_Trimming.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_MAX $PFOLDER $RUNFOLDER
 
date 