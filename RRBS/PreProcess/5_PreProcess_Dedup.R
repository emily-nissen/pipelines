##########################################
# Title: Dedup
# Author: Emily Nissen
# Date: 8/7/2024
##########################################

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])

folder <- "path/to/folder/"
dir <- paste0(folder,"bismarkAlignments/")
ix.dir <- paste0(folder,"runfolder/Project_/")
tmp.dir <- folder

samples <- c()

if(group == 1){
  samples = samples[]
}else if(group == 2){
  samples = samples[]
}

for(sample in samples){
  #  First, need to convert bam to sam
  convert <- paste0("samtools view -h -o ", dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam ", 
                    dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.bam")
  print(convert)
  system(convert)
  
  # Second, need to strip sam file to correct names
  strip <- paste0("strip_bismark_sam.sh ", dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam")
  print(strip)
  system(strip)
  
  ## Third, run dedup script
  dedup <- paste0("python nudup.py -2 -f ", ix.dir, "Project_", sample, "/", sample, "_R2.fastq -o ",
                  sample, "_trimmed_bismark_stripped -T ", tmp.dir, "tmp", sample, " ", 
                  dir, sample, "_R1_val_1_trimmed_bismark_bt2_pe.sam_stripped.sam")
  print(dedup)
  system(dedup)
}

