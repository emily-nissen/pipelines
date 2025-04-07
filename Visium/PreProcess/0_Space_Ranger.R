################################################
# Title: Get Counts
# Author: Emily Schueddig
# Date: 02/14/2025
# Last modified: 3/28/2025
################################################
library(rio)

args <- commandArgs(trailingOnly=TRUE)
group <- as.numeric(args[1])
n <- as.numeric(args[2])
print(group)

runfolder <- args[3]
imagefolder <- args[4]
cytafolder <- paste0(imagefolder,"/",list.files(imagefolder)[grep("assay",list.files(imagefolder))])
# read in sample sheet
csv = read.csv(paste0(cytafolder,"/",list.files(cytafolder)[grep("csv",list.files(cytafolder))]))
# get sample names
samples = csv[grep("Sample",rownames(csv)),1]
# get slide ID
slide = csv[grep("Visium Slide ID",rownames(csv)),1]

# split samples
l = split(samples, cut(seq_along(samples), n, labels=F))
samples.run = l[[group]]

print(samples.run)

for (sample in samples.run){
  area=strsplit(sample,"_")[[1]][1]
  cytaimage=list.files(cytafolder)[grep(sample,list.files(cytafolder))]
  
  spaceranger.count <- paste0(args[5],"/spaceranger-3.1.2/spaceranger count --id=", sample, 
                              " --transcriptome=",args[6],"/spaceranger/refdata-gex-mm10-2020-A --fastqs=",runfolder,"/",sample,
                              " --probe-set=",args[5],"/spaceranger-3.1.2/external/tenx_feature_references/targeted_panels/Visium_Mouse_Transcriptome_Probe_Set_v2.0_mm10-2020-A.csv --slide=",slide,
                              " --area=",area," --cytaimage=",cytafolder,"/",cytaimage," --image=",imagefolder,"/",sample,"_",slide,".tif --create-bam=false --custom-bin-size=4")
  print(spaceranger.count)
  system(spaceranger.count)
}

