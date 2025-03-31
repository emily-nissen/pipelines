##########################################
# Title: Concatenate, Trim, FastQC
# Author: Emily (Nissen) Schueddig
# Date: 8/7/2024
# Modified: 3/30/2025
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
runfolder <- args[4]
out <- paste0(pfolder,"trimmedData/")
out2 <- paste0(pfolder,"fastqc/")

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for(sample in samples.run){
  zcat = paste0("zcat ", runfolder, "/", sample, "/*R1*.fastq.gz >> ", runfolder, "/", sample, "/", sample, "_R1.fastq")
  print(zcat)
  system(zcat)
  print(gsub("R1","R3",zcat))
  system(gsub("R1","R3",zcat))
  
  trim <- paste0("/kuhpc/work/biostat/e617n596/tools/TrimGalore-0.6.6/trim_galore --output_dir ", out, 
                 " --paired -a AGATCGGAAGAGC -a2 AAATCAAAAAAAC ", 
                 runfolder, "/", sample, "/", sample, "_R1.fastq ",
                 runfolder, "/", sample, "/", sample, "_R3.fastq")
  print(trim)
  system(trim)
  
  fast = paste0("fastqc -o ", out2, " -f fastq -t 8 ", runfolder, "/", sample, "/", sample, "_R1_v1_1.fq")
  print(fast)
  system(fast)
  print(gsub("R1_val_1","R3_val_2",fast))
  system(gsub("R1_val_1","R3_val_2",fast))
}