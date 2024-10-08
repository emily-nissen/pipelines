#######################################
# Title: Trim (optional)
# Author: Emily Nissen
# Date: 10/08/2024
# Modified: 
#######################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
dir <- paste0(folder, "runfolder/Unaligned/Project_/")

samples <- c()

if(group == 1){
  files = samples[]
}else if(group == 2){
  files = samples[]
}

for(file in files){
  trim = paste0("java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 8 ", 
                dir, file, "/_R1.fastq.gz ",
                dir, file, "/_R2.fastq.gz ",
                dir, file, "/_R1_paired.fastq.gz ",
                dir, file, "/_R1_unpaired.fastq.gz ",
                dir, file, "/_R2_paired.fastq.gz ",
                dir, file, "/_R2_unpaired.fastq.gz ",
                "ILLUMINACLIP://Trimmomatic-0.39/adapters/TruSeq3-PE-2:2:30:10 Leading:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:31")
  print(trim)
  system(trim)
}