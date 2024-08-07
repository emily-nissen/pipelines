##########################################
# Title: Concatenate, Trim, FastQC
# Author: Emily Nissen
# Date: 8/7/2024
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

dir <- "/path/to/run/folder/Unaligned/Project_/"
out <- "/path/to/out/folder/trimmedData/"
out2 <- "/path/to/out/folder/fastqc/"

samples <- c()
files <- paste0("Sample_",samples)
# split into however many groups you want
if(group == 1){
  samples = samples[]
  files = files[]
}else if(group == 2){
  samples = samples[]
  files = files[]
}

i=1
for(file in files){
  zcat <- paste0("zcat ", dir, file, "/*R1*.fastq.gz >> ", dir, file, "/", samples[i], "_R1.fastq")
  print(zcat)
  system(zcat)
  print(gsub("R1","R3",zcat))
  system(gsub("R1","R3",zcat))
  
  trim <- paste0("/kuhpc/work/biostat/e617n596/tools/TrimGalore-0.6.6/trim_galore --output_dir ", out, 
                 " --paired -a AGATCGGAAGAGC -a2 AAATCAAAAAAAC ", 
                 dir, file, "/", samples[i], "_R1.fastq ",
                 dir, file, "/", samples[i], "_R3.fastq")
  print(trim)
  system(trim)
  
  fast <- paste0("fastqc -o ", out2, " -f fastq -t 8 ", out, samples[i], "_R1_val_1.fq")
  print(fast)
  system(fast)
  print(gsub("R1_val_1","R3_val_2",fast))
  system(gsub("R1_val_1","R3_val_2",fast))
  
  i = i+1
}