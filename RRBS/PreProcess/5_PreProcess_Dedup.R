##########################################
# Title: Dedup
# Author: Emily (Nissen) Schueddig
# Date: 8/7/2024
# Modified: 3/31/2025
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])

pfolder <- args[3]
runfolder <- args[4]
dir <- paste0(pfolder,"/bismarkAlignments/")
tmp.dir <- pfolder

samples = c()
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for(sample in samples){
  #  First, need to convert bam to sam
  convert <- paste0("samtools view -h -o ", dir, "/", sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam ", 
                    dir, "/", sample, "_R1_val_1_trimmed_bismark_bt2_pe.bam")
  print(convert)
  system(convert)
  
  # Second, need to strip sam file to correct names
  # strip_bismark_sam.sh is a file directly from the NuGEN github page
  # save it in project folder
  strip <- paste0("strip_bismark_sam.sh ", dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam")
  print(strip)
  system(strip)
  
  # Third, run dedup script
  # nudup.py is a file directly from the NuGEN github page
  # save it in project folder
  dedup <- paste0("python nudup.py -2 -f ", runfolder, sample, "/", sample, "_R2.fastq -o ",
                  sample, "_trimmed_bismark_stripped -T ", tmp.dir, "tmp", sample, " ", 
                  dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam_stripped.sam")
  print(dedup)
  system(dedup)
}

