#!/bin/bash
#SBATCH --job-name=annot     # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL       # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --ntasks=1                  # Run on a single CPU
#SBATCH --nodes=1
#SBATCH --mem=64gb                    # Job memory request
#SBATCH --time=2-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --output=annotate_%j.log         # Standard output and error log 

pwd; hostname; date

ml load R/4.2
export R_LIBS_USER=/panfs/pfs.local/work/biostat/e617n596/tools/R/4.2

Rscript 4_Annotate_CpGs.R
 
date
