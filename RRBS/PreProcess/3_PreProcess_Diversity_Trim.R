##########################################
# Title: Diversity Trime
# Author: Emily (Nissen) Schueddig
# Date: 8/7/2024
# Modified: 3/31/2025
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
out <- paste0(pfolder,"trimmedData/")

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for(sample in samples.run){
  trim = paste0("python ", pfolder, "/trimRRBSdiversityAdaptCustomers.py -1 '", 
                out, sample, "_R1_val_1.fq' -2 '",
                out, sample, "_R3_val_2.fq'")
  print(trim)
  system(trim)
  
  move = paste0("mv ", out, sample,
                "_R*_trimmed.fq ", out, "complete/")
  print(move)
  system(move)
}