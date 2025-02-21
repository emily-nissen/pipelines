#!/bin/bash
#SBATCH --job-name=scRNA      # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL       # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --ntasks=16                   # Run on a single CPU
#SBATCH --nodes=1
#SBATCH --mem=96gb                    # Job memory request
#SBATCH --time=3-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --array=1-3
#SBATCH --output=scRNA_%A_%a.log          # Standard output and error log 

pwd; hostname; date

ml load R/4.4
export R_LIBS_USER=/kuhpc/work/biostat/e617n596/tools/R/4.4

Rscript 0_Cell_Ranger.R $SLURM_ARRAY_TASK_ID SampleSheet.xlsx

date
