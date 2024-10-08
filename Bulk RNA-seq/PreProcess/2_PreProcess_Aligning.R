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
reference <- "/path/to/reference/"
rsem.path <- paste0(folder, "rsemResults/")

samples <- c()

if(group == 1){
  files = samples[]
}else if(group == 2){
  files = samples[]
}


for(file in files){
  system(paste0("mkdir ", rsem.path, "rsemResult_", files))
  
  rsem = paste0("rsem-calculate-expression -p 8 --bowtie2 --paired-end --output-genome-bam --strandedness reverse ",
                dir, file, "_R1.fastq.gz ", file, "_R2.fastq.gz ", reference, 
                "ucsc-hg38-rsem/hg38-rsem ", rsem.path, "rsemResults_", file, "/", file)
  print(rsem)
  system(rsem)
}