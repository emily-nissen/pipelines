#!/bin/bash
#SBATCH --job-name=dedup          # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=All          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --nodes=1
#SBATCH --ntasks=1                 # Run on a single node
#SBATCH --cpus-per-task=8
#SBATCH --mem=24gb                    # Job memory request
#SBATCH --time=5-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-5
#SBATCH --output=dedup_%A_%a.log         # Standard output and error log 

pwd; hostname; date

source ~/.bashrc

ml conda
conda activate $CONDA/py311
conda activate --stack bowtie2
conda activate --stack samtools
ml R/4.4

PFOLDER=/path/to/project/folder
RUNFOLDER=/path/to/run/folder

Rscript 5_PreProcess_DeDup.R $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_MAX $PFOLDER $RUNFOLDER

date 
