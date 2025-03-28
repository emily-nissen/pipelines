#######################################
# Title: Trim (optional)
# Author: Emily Nissen
# Date: 10/08/2024
# Modified: 3/28/2025
#######################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
runfolder <- args[4]
rsem.path <- paste0(pfolder, "/rsemResults")

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)


for(sample in samples.run){
  system(paste0("mkdir ", rsem.path, "/rsemResult_", sample))
  
  rsem = paste0("rsem-calculate-expression -p 8 --bowtie2 --paired-end --output-genome-bam --strandedness reverse ",
                runfolder, "/", sample, "/*_R1.fastq.gz ", runfolder, "/", sample, "/*_R2.fastq.gz ",
                "$REFERENCES/ucsc-hg38-rsem/hg38-rsem ", rsem.path, "/rsemResults_", sample, "/", sample)
  print(rsem)
  system(rsem)
}