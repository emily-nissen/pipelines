#!/bin/bash
#SBATCH --job-name=dedup          # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=All          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=8                 # Run on a single CPU
#SBATCH --mem=24gb                    # Job memory request
#SBATCH --time=5-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=dedup_%A_%a.log         # Standard output and error log 

pwd; hostname; date

ml load bowtie2
ml load samtools
ml load R
ml load python/2.7

Rscript 5_PreProcess_DeDup.R $SLURM_ARRAY_TASK_ID

date 
