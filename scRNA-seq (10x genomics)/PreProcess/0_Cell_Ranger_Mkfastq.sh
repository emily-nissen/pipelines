#!/bin/bash
#SBATCH --job-name=mkfastq      # Job name
#SBATCH --partition=biostat           # Partition Name (Required)
#SBATCH --mail-type=ALL       # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=e617n596@kumc.edu     # Where to send mail	
#SBATCH --ntasks=16                   # Run on a single CPU
#SBATCH --nodes=1
#SBATCH --mem=64gb                    # Job memory request
#SBATCH --time=5-00:00:00             # Time limit days-hrs:min:sec
#SBATCH --output=mkfastq_%j.log          # Standard output and error log 

pwd; hostname; date
 
ml bcl2fastq2

/path/to/cellranger mkfastq \
--id=fastq \
--run=/path/to/run/folder \
--samplesheet=/path/to/run/folder/SampleSheet-1.csv

date
