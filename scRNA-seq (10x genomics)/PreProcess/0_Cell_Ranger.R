################################################
# Title: Get Counts
# Author: Emily Schueddig
# Date: 02/14/2025
# Last modified: 3/28/2025
################################################
library(rio)

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[3])
print(group)
csv <- rio::import(args[2], skip=15)

samples = csv$Sample_ID

l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for (sample in samples.run){
  cellranger.count <- paste0("$CRANGER count ", # $CRANGER is path to cellranger
                            "--id=", sample, " ",
                            "--transcriptome=$REFERENCES/cellranger/refdata-gex-mm10-2020-A ",
                            "--fastqs=",args[4], sample,
                            # " --sample=", sample.id,
                            " --localcores=16")
  print(cellranger.count)
  system(cellranger.count)
}

