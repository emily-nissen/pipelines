####################################################
# Title: Deconvolution
# Author: Emily Nissen
# Date: 08/21/2023
####################################################

library(ggplot2)
library(tidyr)
library(dplyr)
library(ggpubr)

dir = "/path/to/folder/"
####################################################################
# Deconvolute samples for 6 cell types with a subset of CpGs
####################################################################

file2 = readRDS(paste0(dir,"EPIC.hg38.manifest.rds"))
file2 = as.data.frame(file2)
file2$name = rownames(file2)

file1Keys = c("V1","V2")
file2Keys = c("seqnames","end")

tab = read.csv("IDOLOptimized_6CellTypes", skip =1)
IDOLOptimizedCpGsBlood = tab$X

files = list.files(paste0(dir,"extractMethylation/"))

props = as.data.frame(matrix(NA, nrow = length(files), ncol = 7))
rownames(props) = files
colnames(props) = c("CD8T","CD4T","NK","Bcell","Mono","Neu","numCpG")

for(i in 1:length(files)){
  file1 = fread(paste0(dir,"extractMethylation/",
                files[i],"/",files[i],"_trimmed_bismark_stripped.dedup.bismark.cov.gz"))
  
  liftOver <- merge(file1, file2, by.x=file1Keys, by.y=file2Keys)
  
  liftOver.sub = liftOver[liftOver$name%in%IDOLOptimizedCpGsBlood,]
  
  comp.table = as.data.frame(IDOLOptimizedCpGs.compTable[rownames(IDOLOptimizedCpGs.compTable)%in%liftOver.sub$name,])
  # lifOver.sub = liftOver.sub[order(match(liftOver.sub$name, rownames(comp.table))),]
  data = as.data.frame(liftOver.sub$V4/100)
  rownames(data) = liftOver.sub$name
  
  comp.table = comp.table[order(match(rownames(comp.table),rownames(data))),]
  
  if(all(rownames(comp.table)==rownames(data)) == F){
    break
  }
  
  propEPIC<-projectCellType_CP (
    as.matrix(data),
    as.matrix(comp.table), contrastWBC=NULL, nonnegative=TRUE,
    lessThanOne=FALSE)
  
  props[i,1:6] = propEPIC[1,]
  props[i,7] = nrow(data)
}

save(paste0(dir,"robjects/props_6celltypes.RData"))

# #####################################################################
# # Testing subset of CpGs deconvolution in reconstruction mixtures
# #####################################################################
# gse.id = "GSE110554"
# dataset_directory = "GSE11054/"
# if(!dir.exists(dataset_directory)){
#   dir.create(dataset_directory)
# }
# gset <- getGEO(
#   gse.id, GSEMatrix =TRUE, getGPL=FALSE,
#   destdir = dataset_directory
# )
# if (length(gset) > 1) idx <- grep("GPL13534", attr(gset, "names")) else idx <- 1
# gset <- gset[[idx]]
# 
# betas = exprs(gset)
# covariates = pData(gset)
# covariates = subset(covariates, characteristics_ch1.6 == "cell type: MIX")
# betas = betas[,colnames(betas)%in%covariates$geo_accession]
# dim(betas)
# 
# sub.betas = liftOver.sub$name
# 
# betas.sub = betas[rownames(betas)%in%rownames(comp.table),]
# betas.sub = betas.sub[order(match(rownames(betas.sub),rownames(comp.table))),]
# all(rownames(betas.sub)==rownames(comp.table))
# 
# propEPIC<-projectCellType_CP (
#   as.matrix(betas.sub),
#   as.matrix(comp.table), contrastWBC=NULL, nonnegative=TRUE,
#   lessThanOne=FALSE)
# 
# covariates$CD4T = as.numeric(sapply(strsplit(covariates$characteristics_ch1.7, ":"), "[",2))
# covariates$CD8T = as.numeric(sapply(strsplit(covariates$characteristics_ch1.8, ":"), "[",2))
# covariates$Bcell = as.numeric(sapply(strsplit(covariates$characteristics_ch1.9, ":"), "[",2))
# covariates$NK = as.numeric(sapply(strsplit(covariates$characteristics_ch1.10, ":"), "[",2))
# covariates$Mono = as.numeric(sapply(strsplit(covariates$characteristics_ch1.11, ":"), "[",2))
# covariates$Neu = as.numeric(sapply(strsplit(covariates$characteristics_ch1.12, ":"), "[",2))
# 
# colnames(propEPIC) = paste0(colnames(propEPIC),".est")
# covariates = merge(covariates, propEPIC*100, by.x = 0, by.y = 0, all.x = T)
# 
# covariates.long = gather(covariates, cell, perc, 87:92)
# covariates.long$perc2 = ifelse(covariates.long$cell=="CD4T",covariates.long$CD4T.est,ifelse(covariates.long$cell=="CD8T",covariates.long$CD8T.est,ifelse(covariates.long$cell=="NK",covariates.long$NK.est,ifelse(covariates.long$cell=="Bcell",covariates.long$Bcell.est,ifelse(covariates.long$cell=="Mono",covariates.long$Mono.est,ifelse(covariates.long$cell=="Neu",covariates.long$Neu.est,NA))))))
# 
# pdf("Deconvolution_Mixtures_Test.pdf")
# covariates.long %>%
#   ggplot(aes(x = perc, y = perc2)) +
#   geom_point() +
#   geom_smooth(method = "lm") +
#   geom_abline(slope = 1, intercept = 0) +
#   facet_wrap(vars(cell), scales = "free")
# dev.off()