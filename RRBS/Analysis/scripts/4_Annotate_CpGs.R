####################################################
# Title: Annotate CpGs
# Author: Emily Nissen
# Date: 08/08/2024
####################################################

library(annotatr)
library(GenomicRanges)

dir = "/path/to/folder/"
test.name = "Grp2_vs_Grp1"
load(file = paste0(dir,"robjects/AOV_Results_DF_Top500k_", test.name, ".RData"))

results.map = results.df.sub[,c(10,11,11,9)]
colnames(results.map) = c("chr","start","end","strand")

pos.to.map = makeGRangesFromDataFrame(results.map)
names(pos.to.map) = results.df.sub$Row.names
pos.to.map

###############################################################
# Add Gene annotations
###############################################################
gene_annot = build_annotations(genome = "hg38", annotations = "hg38_basicgenes")
gene_annot
names(gene_annot) = seq(1,length(gene_annot),1)

olaps.gene = findOverlaps(gene_annot, pos.to.map)
olaps.gene

maps = as.data.frame(olaps.gene)
names= as.data.frame(unique(maps$subjectHits))
results.df.sub$gene = NA
results.df.sub$type = NA

for(i in 1:nrow(names)){
  idx = names[i,1]
  maps.sub = subset(maps, subjectHits == idx)
  
  gene.sub = data.frame(gene_annot[maps.sub$queryHits])
  results.df.sub$gene[idx] = paste0(gene.sub$symbol, collapse = ";")
  
  types = sapply(strsplit(gene.sub$id,":"),"[",1)
  results.df.sub$type[idx] = paste0(types, collapse = ";")
  
  if(i%in%seq(0,500000,by=10000)){
    print(i)
  }
}

save(results.df.sub, file = paste0(dir,"robjects/AOV_Results_DF_Top500k_", test.name, "_Gene_Annots.RData"))
###############################################################
# Add CpG annotations
###############################################################
pos.to.map = makeGRangesFromDataFrame(results.df.sub, seqnames.field = "chr", start.field = "start", end.field = "start")

cpg_annot = build_annotations(genome = "hg38", annotations = "hg38_cpgs")
cpg_annot
names(cpg_annot) = seq(1,length(cpg_annot),1)

olaps.cpg = findOverlaps(pos.to.map, cpg_annot)
olaps.cpg

maps = as.data.frame(cbind(names(pos.to.map)[queryHits(olaps.cpg)],names(cpg_annot)[subjectHits(olaps.cpg)]))
maps$V3 = NA
for(i in 1:nrow(maps)){
  id = as.character(cpg_annot[names(cpg_annot)==maps$V2[i],]@elementMetadata$id)
  maps$V3[i] = id
}

maps$V4 = sapply(strsplit(maps$V3,":"),"[",1)
maps = maps[-c(2,3)]
results.df.sub = merge(results.df.sub, maps, by.x = 0, by.y = 1, all.x = T)

save(results.df.sub, file = paste0(dir,"robjects/AOV_Results_DF_Top500k_", test.name, "_Gene_CpG_Annots.RData"))