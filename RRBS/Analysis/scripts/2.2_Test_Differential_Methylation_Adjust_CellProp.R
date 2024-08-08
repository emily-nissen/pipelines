####################################################
# Title: Test for Differential Methylation
# Author: Emily Nissen
# Date: 08/08/2023
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

load(paste0(dir,"robjects/props_6celltypes.RData"))
props = props[rownames(props)%in%sample.sheet$Sample_Name,]
props = props[,1:6]
props[props<0] = 0
props.scale = (props)/rowSums(props)
props.scale = props.scale[order(match(rownames(props.scale), sample.sheet$Sample_Name)),]

all(rownames(props.scale)==sample.sheet$Sample_Name)
all(rownames(props.scale)==rownames(meth.data))

test.data = cbind(sample.sheet[,c("Sample_Name","Group")], props.scale, meth.data)
dim(test.data)

detectCores()
myCluster = makeCluster(12, type = "FORK")
registerDoParallel(myCluster)
r = foreach(i = 1:(ncol(test.data) - 8))%dopar%{
  fit = aov(test.data[,(i+8)] ~ test.data$Group + test.data$CD8T + test.data$CD4T + test.data$Bcell + test.data$Mono + test.data$Neu)
  lsm.trt=emmeans::lsmeans(fit, c("Group"))
  summary=summary(emmeans::contrast(lsm.trt, list(
    "Grp2-Grp1" = c(1, -1)),
    adjust="none",infer=c(T,T), level=0.95))
  summary

  return(summary)
}

test.name = "Grp2_vs_Grp1"
save(r, file = paste0(dir, "robjects/AOV_Results_wCellProp_List_", test.name, ".RData"))

names(r) = colnames(meth.data)

results.df = as.data.frame(matrix(NA, nrow = length(r), ncol = 5))
rownames(results.df) = names(r)
colnames(results.df) = c("Estimate","SE","LL","UL","p.value")

results.df$Estimate = as.numeric(sapply(r, "[",2))
results.df$SE = as.numeric(sapply(r,"[",3))
results.df$LL = as.numeric(sapply(r,"[",5))
results.df$UL = as.numeric(sapply(r,"[",6))
results.df$p.value = as.numeric(sapply(r,"[",8))
save(results.df, file = paste0(dir, "robjects/AOV_Results_wCellProp_DF_", test.name, ".RData"))

results.df$color = ifelse(results.df$Estimate < -0.1 & results.df$p.value<0.05, "Hypo-methylated in Grp2",
                          ifelse(results.df$Estimate > 0.1 & results.df$p.value<0.05,"Hyper-methylated in Grp2","Not significant"))

results.df$FDR  = p.adjust(results.df$p.value, method = "BH")
results.df.sub = subset(results.df, p.value<0.05)

pdf(file = paste0(dir, "VolcanoPlot.pdf"), height = 12, width = 12)
results.df %>%
  ggplot(aes(x = Estimate, y = -log10(p.value), color = color)) +
  geom_point(alpha = 0.5) + 
  scale_color_manual(values = c("blue","yellow","grey")) +
  ylim(c(0,8)) +
  geom_vline(xintercept = c(-0.1,0.1)) +
  geom_hline(yintercept = -log10(0.05))
dev.off()



