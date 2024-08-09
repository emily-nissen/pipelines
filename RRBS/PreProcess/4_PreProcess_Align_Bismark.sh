#!/bin/bash
#SBATCH --job-name=align           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=8                  # Run on a single CPU
#SBATCH --mem=64gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=align_%A_%a.log         # Standard output and error log 

pwd; hostname; date
 
ml load bowtie2
ml load samtools
ml load R/4.2
export R_LIBS_USER=/kuhpc/work/biostat/e617n596/tools/R/4.2 

Rscript 4_PreProcess_Align_Bismark.R $SLURM_ARRAY_TASK_ID

date 
