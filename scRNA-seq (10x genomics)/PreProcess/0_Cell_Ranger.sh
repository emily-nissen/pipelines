#!/bin/bash
#SBATCH --job-name=scRNA      # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL       # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --ntasks=1                   # Run on a single CPU
#SBATCH --cpus-per-task=16
#SBATCH --nodes=1
#SBATCH --mem=96gb                    # Job memory request -- set to appropriate parameters
#SBATCH --time=3-00:00:00             # Time limit days-hrs:min:sec -- set to appropriate parameters
#SBATCH --array=1-3               # Set to number of arrays you want to split
#SBATCH --output=scRNA_%A_%a.log          # Standard output and error log 

pwd; hostname; date

ml R/4.4

RUNFOLDER=/path/to/run/folder/

Rscript 0_Cell_Ranger.R $SLURM_ARRAY_TASK_ID SampleSheet.xlsx $SLURM_ARRAY_TASK_MAX $RUNFOLDER

date
