#!/bin/bash
#SBATCH --job-name=deconv     # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL       # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --nodes=1
#SBATCH --mem=36gb                    # Job memory request
#SBATCH --time=05:00:00             # Time limit days-hrs:min:sec
#SBATCH --output=deconvolute_%j.log         # Standard output and error log 

pwd; hostname; date

ml load R/4.2
export R_LIBS_USER=/kuhpc/work/biostat/e617n596/tools/R/4.2

Rscript 0_Deconvolute_Cell_Types.R
 
date
