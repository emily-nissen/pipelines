##########################################
# Title: Align
# Author: Emily (Nissen) Schueddig
# Date: 8/7/2024
# Modified: 3/31/2025
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
data.dir <- paste0(pfolder, "/trimmedData/complete/")
out.dir <- paste0(pfolder,"/bismarkAlignments/")

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for(sample in samples.run){
  bismark <- paste0("$TOOLS/Bismark-0.22.3/bismark --bowtie2 --output_dir ", 
                    out.dir, " --multicore 8 $REFERENCES/bismark/hg38 -1 ", 
                    data.dir, "/", sample, "_R1_val_1_trimmed.fq -2 ", data.dir, "/", sample, "_R3_val_2_trimmed.fq")
  
  print(bismark)
  systme(bismark)
}