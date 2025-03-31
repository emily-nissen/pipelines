#!/bin/bash
#SBATCH --job-name=pre2           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=1                   # Run on a single CPU
#SBATCH --cpus-per-task=8
#SBATCH --mem=36gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=preprocess_2_%A_%a.log          # Standard output and error log 

pwd; hostname; date
 
pwd; hostname; date

ml load R/4.4
ml conda
ml fastqc
conda activate --stack cutadapt
ml java

PFOLDER=/path/to/project/folder
RUNFOLDER=/path/to/run/folder

Rscript 2_PreProcess_Cat_Trim_Fastqc.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_MAX $PFOLDER $RUNFOLDER
 
date 