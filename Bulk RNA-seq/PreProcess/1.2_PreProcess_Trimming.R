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

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for(sample in samples.run){
  trim = paste0("java -jar Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 8 ", 
                runfolder, "/", sample, "/*_R1.fastq.gz ",
                runfolder, "/", sample, "/*_R2.fastq.gz ",
                runfolder, "/", sample, "/",sample,"_R1_paired.fastq.gz ",
                runfolder, "/", sample, "/",sample,"_R1_unpaired.fastq.gz ",
                runfolder, "/", sample, "/",sample,"_R2_paired.fastq.gz ",
                runfolder, "/", sample, "/",sample,"_R2_unpaired.fastq.gz ",
                "ILLUMINACLIP://Trimmomatic-0.39/adapters/TruSeq3-PE-2:2:30:10 Leading:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:31")
  print(trim)
  system(trim)
}