#!/bin/bash
#SBATCH --job-name=dTrim           # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL         # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --mem=4gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=dTrim_%A_%a.log         # Standard output and error log 

pwd; hostname; date

source ~/.bashrc
 
ml R/4.4
ml conda
conda activate $CONDA/py311

PFOLDER=/path/to/project/folder

Rscript 3_PreProcess_Diversity_Trim.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_MAX $PFOLDER

date 
