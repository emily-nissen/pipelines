# utils contains some necessary functions for comparison

################################################################################
# volcano plot of results from differential expression analysis
plot.volcano <- function(exactTestObj, title, padj){
  FDR <- p.adjust(exactTestObj$table$PValue, method = "BH")
  color <- ifelse(FDR <= padj & exactTestObj$table$logFC > 0, "Up-Regulated", ifelse(FDR <= padj & exactTestObj$table$logFC < 0, "Down-Regulated", "Not Significant"))
  table <- cbind(exactTestObj$table, FDR, color)

  range.x.y = c(0,1)
  range.x.y[1] = max(abs(exactTestObj$table$logFC))
  range.x.y[2] = min(exactTestObj$table$PValue)
  
  p = as.data.frame(table) %>%
        ggplot(aes(x=logFC, y=-log10(PValue))) +
          geom_point(aes(color=color), shape=19) +
          scale_color_manual(values=c("dodgerblue", "gray", "firebrick")) +
          xlim(c(-range.x.y[1], range.x.y[1])) +
          ylim(c(0, -log10(range.x.y[2]))) +
          geom_hline(yintercept=-log10(0.05)) +
          geom_vline(xintercept=c(-1,1)) +
          theme_classic(base_size = 15) +
          labs(x="log2FC (fold change)", y="-log10(p-value)", title = title)
  print(p)
}
################################################################################
plot.volcano.DESeq2 <- function(res, title, padj){
  res.sub = subset(res, !is.na(padj))
  color <- ifelse(res.sub$padj <= padj & res.sub$log2FoldChange > 0, "Up-Regulated", 
                  ifelse(res.sub$padj <= padj & res.sub$log2FoldChange < 0, "Down-Regulated", "Not Significant"))
  table <- cbind(res.sub, color)
  
  range.x.y = c(0,1)
  range.x.y[1] = max(abs(res$log2FoldChange))
  range.x.y[2] = min(res$pvalue)
  
  p = as.data.frame(table) %>%
    ggplot(aes(x=log2FoldChange, y=-log10(pvalue))) +
    geom_point(aes(color=color), shape=19) +
    scale_color_manual(name = "",values=c("dodgerblue", "gray", "firebrick")) +
    # scale_color_discrete()
    xlim(c(-range.x.y[1], range.x.y[1])) +
    ylim(c(0, -log10(range.x.y[2]))) +
    geom_hline(yintercept=-log10(0.05)) +
    geom_vline(xintercept=c(-1,1)) +
    theme_classic(base_size = 15) +
    labs(x="log2FC (fold change)", y="-log10(p-value)", title = title)
  print(p)
}
################################################################################
# p-value histogram of results from differential expression analysis
# X = 0.6, Y = 1500 typically
plot.pval.hist = function(exactTestObj, X, Y, FDR){
  pval = exactTestObj$table$PValue
  col1 = ifelse(pval < 0.05, "P < 0.05", "P >= 0.05") 
  padjust = p.adjust(pval, method = "BH")
  col2 = ifelse(padjust < FDR, paste0("FDR < ", FDR), paste0("FDR >= ", FDR))
  
  p1 = as.data.frame(pval) %>%
    ggplot(aes(x=pval, fill = col1)) +
    geom_histogram(bins = 20, color = "black") +
    labs(x = "P-value", title = "Distribution of P-values") +
    scale_fill_discrete(name = "P-value") +
    annotate("text", x=X, y=Y, label = paste0("There are ", length(pval[pval<FDR]), "\ndifferentially\nexpressed genes"))
  
  p2 = as.data.frame(pval) %>%
    ggplot(aes(x=pval, fill = col2)) +
    geom_histogram(bins = 20, color = "black") +
    labs(x = "P-value", title = "Distribution of P-values") +
    scale_fill_discrete(name = "FDR") +
    annotate("text", x=X, y=Y, label = paste0("There are ", length(padjust[padjust<FDR]), "\ndifferentially\nexpressed genes\nafter adjustment"))
  
  combine = ggarrange(p1, p2)
  print(combine)
}
################################################################################
plot.pval.hist.DESeq2 = function(res, X, Y, FDR){
  res.sub = subset(res, !is.na(padj))
  pval = res.sub$pvalue
  col1 = ifelse(pval < 0.05, "P < 0.05", "P >= 0.05") 
  padjust = res.sub$padj
  col2 = ifelse(padjust < FDR, paste0("FDR < ", FDR), paste0("FDR >= ", FDR))
  
  
  p1 = as.data.frame(pval) %>%
    ggplot(aes(x=pval, fill = col1)) +
    geom_histogram(bins = 20, color = "black") +
    labs(x = "P-value", title = "Distribution of P-values") +
    scale_fill_discrete(name = "P-value") +
    annotate("text", x=X, y=Y, label = paste0("There are ", length(pval[pval<FDR]), "\ndifferentially\nexpressed genes"))
  
  p2 = as.data.frame(pval) %>%
    ggplot(aes(x=pval, fill = col2)) +
    geom_histogram(bins = 20, color = "black") +
    labs(x = "P-value", title = "Distribution of P-values") +
    scale_fill_discrete(name = "FDR") +
    annotate("text", x=X, y=Y, label = paste0("There are ", length(padjust[padjust<FDR]), "\ndifferentially\nexpressed genes\nafter adjustment"))
  
  combine = ggarrange(p1, p2)
  print(combine)
}
################################################################################
# plot top N genes as boxplots
plot.topN <- function(exactTestObj, y1, N, group, x, y, title){
  o = order(exactTestObj$table$PValue)
  topN = as.data.frame(t(cpm(y1)[o[1:N],]))
  topN$Group = group
  topN.long = gather(topN, gene, cpm, 1:N)
  
  topN.long %>%
    ggplot(aes(x = Group, y = cpm, fill = Group)) +
    geom_boxplot() +
    facet_wrap(vars(gene), scale = "free", ncol = 5) +
    labs(x = x, y = y, title = title)
}
################################################################################
plot.topN.DESeq2 <- function(res, N, counts, group, x, y, title){
  res = res[order(res$padj),]
  topN = as.data.frame(t(cpm(counts)[rownames(cpm(counts))%in%rownames(res)[1:N],]))
  topN$Group = group
  topN.long = gather(topN, gene, cpm, 1:N)
  
  topN.long %>%
    ggplot(aes(x = Group, y = cpm, fill = Group)) +
    geom_boxplot() +
    facet_wrap(vars(gene), scale = "free", ncol = 5) +
    labs(x = x, y = y, title = title)
}

################################################################################
# bar plots of top 15 results from pathway analysis
plot.bar.enrich=function(df, p, id, fdr, title){
  cols <- c("FDR<=0.1" = "steelblue", "FDR>0.1" = "grey")
  plot = df[1:15,] %>%
      ggplot(aes(x=reorder(id[1:15], -p[1:15]), y=-log10(p[1:15]), fill=fdr[1:15])) +
      geom_bar(stat = "identity") +
      coord_flip() +
      scale_fill_manual(name="FDR", values=cols) +
      geom_hline(yintercept = -log10(0.05), color="red", size=2) +
      labs(y="-log10(p-value)", x="", title=title) +
      theme(text=element_text(size=20))
  print(plot)
}
################################################################################
# 
plot.bar.equiv = function(pos, neg, title, size){
  table = as.data.frame(cbind(c(pos$Cal27_log2FC,pos$Tu167_log2FC,neg$Cal27_log2FC,neg$Tu167_log2FC), 
                              c(rownames(pos),rownames(pos),rownames(neg), rownames(neg)),
                              c(rep("Cal27", nrow(pos)), rep("Tu167", nrow(pos)),
                                rep("Cal27", nrow(neg)), rep("Tu167", nrow(neg)))))
  colnames(table) = c("log2_FC", "Gene", "Cell")
  p = table %>%
      ggplot(aes(y = as.numeric(log2_FC), x = reorder(Gene, -as.numeric(log2_FC)), fill = Cell)) +
      geom_bar(stat = "identity", position = "dodge") +
      coord_flip() + 
      labs(y="log2-FC", x="Gene", title=title) +
      theme(text=element_text(size=size))
  print(p)
}
################################################################################
# this function subset genes for IPA input
# FDR<=0.1
# logFC either positive or negative

subset.IPA <- function(exactTestObj, sample.pair){
  # calculate FDR from p value
  FDR <- p.adjust(exactTestObj$table$PValue, method = "BH")
  # get tf indices with FDR < 0.1
  keep.tf <- FDR <= 0.1
  
  # get tf indices with -/+ logFC value
  positive.tf <- exactTestObj$table$logFC > 0
  negative.tf <- exactTestObj$table$logFC < 0
  
  # extract rownames based on indices calculated before
  negativeFC <- rownames(exactTestObj$table[which(keep.tf & negative.tf),])
  positiveFC <- rownames(exactTestObj$table[which(keep.tf & positive.tf),])
  
  # write data into txt file
  write(negativeFC,
        file = paste("negative_", sample.pair[1], "_", sample.pair[2], ".txt", sep = ""),
        sep = "\n")
  write(positiveFC,
        file = paste("positive_", sample.pair[1], "_", sample.pair[2], ".txt", sep = ""),
        sep = "\n")
  
  # print something in console
  cat(paste("extracted IPA input: ", sample.pair[1], "_", sample.pair[2], "\n", sep = ""))
}