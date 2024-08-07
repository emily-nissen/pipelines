##########################################
# Title: Convert BCL to FastQ
# Author: Emily Nissen
# Date: 8/7/2024
##########################################

runfolder <- "/path/to/run/folder/"

convert <- paste0("bcl2fastq --runfolder-dir ", runfolder, 
                  " --input-dir ", runfolder, "Data/Intensities/BaseCalls/ --output-dir ",
                  runfolder, "Unaligned/ --sample-sheet ", runfolder, 
                  "SampleSheet.csv --use-bases-mask Y*,I8Y*,Y* --minimum-trimmed-read-length 0 --mask-short-adapter-reads 0")

print(convert)
system(convert)