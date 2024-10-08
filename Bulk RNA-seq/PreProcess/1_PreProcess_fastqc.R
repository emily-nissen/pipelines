#######################################
# Title: Zcat and FastQC
# Author: Emily Nissen
# Date: 10/08/2024
# Modified: 
#######################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
dir <- paste0(folder, "runfolder/Unaligned/Project_/")
out <- paste0(folder, "fastqc/")

samples <- c()

if(group == 1){
  files = samples[]
}else if(group == 2){
  files = samples[]
}

for(file in files){
  zcat = paste0("zcat ", dir, "/", file, "/*R1*.fastq.gz >> ", dir, "/", file, "/", file, "_R1.fastq")
  print(zcat)
  system(zcat)
  print(gsub("R1","R2",zcat))
  system(gsub("R1","R2",zcat))

  fast = paste0("fastqc -o ", out, " -f fastq -t 8 ", dir, "/", file, "/", file, "_R1.fastq")
  print(fast)
  system(fast)
  print(gsub("R1","R2",fast))
  system(gsub("R1","R2",fast))
}