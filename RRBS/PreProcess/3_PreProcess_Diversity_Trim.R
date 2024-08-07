##########################################
# Title: Diversity Trime
# Author: Emily Nissen
# Date: 8/7/2024
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
out.dir <- paste0(folder, "trimmedData/")

samples = c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  trim = paste0("python ", dir, "/trimRRBSdiversityAdaptCustomers.py -1 '", 
                out.dir, sample, "_R1_val_1.fq' -2 '",
                out.dir, sample, "_R3_val_2.fq'")
  print(trim)
  system(trim)
  
  move = paste0("mv ", dir, sample,
                "_R*_trimmed.fq ", out.dir, "complete/")
  print(move)
  system(move)
}