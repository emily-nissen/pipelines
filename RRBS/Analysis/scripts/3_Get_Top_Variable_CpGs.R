####################################################
# Title: Get Top Varying CpGs
# Author: Emily Nissen
# Date: 08/08/2024
####################################################
library(doParallel)

dir = "/path/to/folder/"
load(paste0(dir,"robjects/Methyl_Data.RData"))

detectCores()
myCluster = makeCluster(12, type = "FORK")
registerDoParallel(myCluster)
r = foreach(i = 1:ncol(meth.data))%dopar%{
  var = var(meth.data[,i])
  return(var)
}

names(r) = colnames(meth.data)
var.vec = sapply(r,"[",1)
var.vec = var.vec[order(var.vec, decreasing = T)]
save(var.vec, file = paste0(dir,"robjects/All_CpGs_Variance.RData"))

top.500k = names(var.vec)[1:500000]

test.name = "Grp2_vs_Grp1"
load(file = paste0(dir, "robjects/AOV_Results_DF_", test.name, ".RData"))

results.df.sub = results.df[rownames(results.df)%in%top.500k,]
save(results.df.sub, file = paste0(dir,"robjects/AOV_Results_DF_Top500k_", test.name, ".RData"))

pdf(file = paste0(dir, "VolcanoPlot.pdf"), height = 12, width = 12)
results.df.sub %>%
  ggplot(aes(x = Estimate, y = -log10(p.value), color = color)) +
  geom_point(alpha = 0.5) + 
  scale_color_manual(values = c("blue","yellow","grey")) +
  ylim(c(0,8)) +
  geom_vline(xintercept = c(-0.1,0.1)) +
  geom_hline(yintercept = -log10(0.05))
dev.off()

