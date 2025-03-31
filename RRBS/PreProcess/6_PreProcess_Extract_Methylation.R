##########################################
# Title: Extract Methylation
# Author: Emily (Nissen) Schueddig
# Date: 8/7/2024
# Modified: 3/31/2025
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
dir <- paste0(pfolder, "/bismarkAlignments/")
out.dir <- paste0(pfolder,"/extractMethylation/")

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)


for(sample in samples){
  sort <- paste0("samtools sort -n -o ", dir, sample, "_trimmed_bismark_stripped_dedup.bam ", 
                 dir, sample, "_trimmed_bismark_stripped.sorted.dedup.bam")
  print(sort)
  system(sort)
  
  extract <- paste0("$TOOLS/Bismark-0.22.3/bismark_methylation_extractor --paired-end -o ",
                    out.dir, sample, " --bedGraph --multicore 8 ", dir, sample, "_trimmed_bismark_stripped.dedup.bam")
  print(extract)
  system(extract)
}