####################################################
# Title: Test for Differential Methylation
# Author: Emily Nissen
# Date: 08/21/2023
####################################################

library(emmeans)
library(doParallel)
library(dplyr)
library(ggplot2)

dir = "/path/to/folder/"
load(paste0(dir,"robjects/Methyl_Data.RData"))

sample.sheet = read.csv(paste0(dir,"SampleSheet.csv"), skip = 18)
sample.sheet$Group = group
all(sample.sheet$Sample_Name == rownames(meth.data))

test.data = cbind(sample.sheet[,c("Sample_Name","Group")], meth.data)
dim(test.data)

detectCores()
myCluster = makeCluster(12, type = "FORK")
registerDoParallel(myCluster)
r = foreach(i = 1:(ncol(test.data) - 2))%dopar%{
  fit = aov(test.data[,(i+2)] ~ test.data$Group)
  lsm.trt=emmeans::lsmeans(fit, c("Group"))
  summary=summary(emmeans::contrast(lsm.trt, list(
    "Grp2-Grp1" = c(1, -1)),
    adjust="none",infer=c(T,T), level=0.95))
  summary

  return(summary)
}

test.name = "Grp2_vs_Grp1"
save(r, file = paste0(dir, "robjects/AOV_Results_List_", test.name, ".RData"))

names(r) = colnames(meth.data)

results.df = as.data.frame(matrix(NA, nrow = length(r), ncol = 5))
rownames(results.df) = names(r)
colnames(results.df) = c("Estimate","SE","LL","UL","p.value")

results.df$Estimate = as.numeric(sapply(r, "[",2))
results.df$SE = as.numeric(sapply(r,"[",3))
results.df$LL = as.numeric(sapply(r,"[",5))
results.df$UL = as.numeric(sapply(r,"[",6))
results.df$p.value = as.numeric(sapply(r,"[",8))
save(results.df, file = paste0(dir, "robjects/AOV_Results_DF_", test.name, ".RData"))

