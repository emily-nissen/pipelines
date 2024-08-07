##########################################
# Title: Extract Methylation
# Author: Emily Nissen
# Date: 8/7/2024
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "/path/to/folder/"
dir <- paste0(folder,"bismarkAlignments/")
out.dir <- paste0(folder,"extractMethylation/")

samples <- c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  sort <- paste0("samtools sort -n -o ", dir, sample, "_trimmed_bismark_stripped_dedup.bam ", 
                 dir, sample, "_trimmed_bismark_stripped.sorted.dedup.bam")
  print(sort)
  system(sort)
  
  extract <- paste0("/kuhpc/work/biostat/e617n596/tools/Bismark-0.22.3/bismark_methylation_extractor --paired-end -o ",
                    out.dir, sample, " --bedGraph --multicore 8 ", dir, sample, "_trimmed_bismark_stripped.dedup.bam")
  print(extract)
  system(extract)
}