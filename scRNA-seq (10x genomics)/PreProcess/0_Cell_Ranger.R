################################################
# Title: Get Counts
# Author: Emily Schueddig
# Date: 02/14/2025
# Last modified: 
################################################
library(rio)

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
print(group)
csv <- rio::import(args[2], skip=15)

samples = csv$Sample_ID

if(group == 1){
  samples = samples[1:3]
}else if(group == 2){
  samples = samples[4:6]
}else if(group == 3){
  samples = samples[7:9]
}

print(samples)

cell.ranger <- "/path/to/cellranger "

for (sample in samples){
  cellranger.count <- paste0(cell.ranger, "count ",
                            "--id=", sample, " ",
                            "--transcriptome=/path/to/reference/refdata-gex-mm10-2020-A ",
                            "--fastqs=/path/to/run/folder/", sample,
                            # " --sample=", sample.id,
                            " --localcores=16")
  print(cellranger.count)
  system(cellranger.count)
}

