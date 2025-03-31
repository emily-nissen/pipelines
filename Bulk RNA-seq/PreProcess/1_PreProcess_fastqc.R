#######################################
# Title: Zcat and FastQC
# Author: Emily (Nissen) Schueddig
# Date: 10/08/2024
# Modified: 3/28/2025
#######################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
runfolder <- args[4]
out <- paste0(pfolder, "/fastqc/")

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for(sample in samples.run){
  zcat = paste0("zcat ", runfolder, "/", sample, "/*R1*.fastq.gz >> ", runfolder, "/", sample, "/", sample, "_R1.fastq")
  print(zcat)
  system(zcat)
  print(gsub("R1","R2",zcat))
  system(gsub("R1","R2",zcat))

  fast = paste0("fastqc -o ", out, " -f fastq -t 8 ", runfolder, "/", sample, "/", sample, "_R1.fastq")
  print(fast)
  system(fast)
  print(gsub("R1","R2",fast))
  system(gsub("R1","R2",fast))
}