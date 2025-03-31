#!/bin/bash
#SBATCH --job-name=align           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8
#SBATCH --mem=64gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=align_%A_%a.log         # Standard output and error log 

pwd; hostname; date
 
ml conda
conda activate bowtie2
conda activate --stack samtools
ml load R/4.4

PFOLDER=/path/to/project/folder

Rscript 4_PreProcess_Align_Bismark.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_MAX $PFOLDER

date 
