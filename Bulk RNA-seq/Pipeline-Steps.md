Bulk RNA-seq Pipeline
================
Emily (Nissen) Schueddig
2024-02-07

- [Project Notes](#project-notes)
- [Pre-processing](#pre-processing)
  - [1_PreProcess_fastqc](#1_preprocess_fastqc)
    - [MultiQC](#multiqc)
  - [1.2_PreProcess_Trimming](#12_preprocess_trimming)
  - [2_PreProcess_Aligning](#2_preprocess_aligning)
  - [Get Relevant Tables](#get-relevant-tables)
  - [MultiQC](#multiqc-1)
- [Differential Expression Analysis](#differential-expression-analysis)
  - [Setup](#setup)
  - [Load Data and Format as edgeR
    Object](#load-data-and-format-as-edger-object)
  - [Data Exploration](#data-exploration)
  - [Testing for Differential
    Expression](#testing-for-differential-expression)
    - [Paired Design - 2 groups](#paired-design---2-groups)
    - [Unpaired Design - 2 groups](#unpaired-design---2-groups)
  - [Plot Results](#plot-results)
- [Gene Set Enrichment](#gene-set-enrichment)
  - [Reactome Pathways](#reactome-pathways)
  - [IPA](#ipa)

**Last Modified:** 2025-03-28

# Project Notes

Add any project notes here

# Pre-processing

These are the folders you will need to set up in the project folder on
the cluster:

``` bash
PFOLDER=/path/to/project/folder

mkdir $PFOLDER/fastqc
mkdir $PFOLDER/rsemResults
```

See the “PreProcess” folder for scripts that can be downloaded based on
the code in the following steps.

## 1_PreProcess_fastqc

First, concatenate files if needed.

Run FastQC to check quality of data.

Run on fastq file for each sample (if paired-end data, run on two fastq
files for each sample)

<https://www.bioinformatics.babraham.ac.uk/projects/fastqc/>

### MultiQC

FastQC outputs individual document for each fastq file. MultiQC will
aggregate all files. Input is the folder where all FastQC reports are.

<https://multiqc.info/>

``` bash
multiqc --interactive ./
```

## 1.2_PreProcess_Trimming

Only trim if needed. Usually adaptor content shows up in FastQC reports.

I typically use trimmomatic:
<http://www.usadellab.org/cms/?page=trimmomatic>

Or Trim Galore!:
<https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/>

Trimming for Illumina universal adapters

``` bash
TrimGalore-0.6.6/trim_galore --paired \
-a AGATCGGAAGAGC -a2 AAATCAAAAAAAC \
path_to_data_folder/sample1_R1.fastq.gz \
path_to_data_folder/sample1_R2.fastq.gz \
```

## 2_PreProcess_Aligning

RSEM aligns to the transcriptome. Use rsem-prepare-reference to setup
and index transcriptome for the organism and aligner you plan on using
(this only needs to be done once). Then you can run
rsem-calculate-expression to calculate expression values.

<https://github.com/deweylab/RSEM>

<https://deweylab.github.io/RSEM/rsem-calculate-expression.html>

This code will output two results files for each sample
“sampleN.genes.results” and “sampleN.isoforms.results”. The
“sampleN.genes.results” are the expression values aggregated at the gene
level. The “expected_count” column is what is needed for input in to a
differential expression analysis.

rsem-calculate-expression \[options\] –paired-end upstream_read_file(s)
downstream_read_file(s) reference_name sample_name

<!-- ```{bash, eval = F} -->
<!-- rsem-generate-data matrix \ -->
<!-- # list all gene.results files -->
<!-- path_to_rsem_results/rsemResults/rsemResults_sample1/sample1.genes.results \ -->
<!-- path_to_rsem_results/rsemResults/rsemResults_sample2/sample2.genes.results \ -->
<!-- path_to_rsem_results/rsemResults/rsemResults_sampleN/sampleN.genes.results > genes.count.matrix -->
<!-- ``` -->

## Get Relevant Tables

``` r
# change column based on what you want to grab
# expected_count = 5, TPM = 6, FPKM = 7
column <- 5

# change path to where your samples are
path <- 'path/to/rsem/results'
samples <- c()

# change based on what samples you are trying to use
all.samples.ret <- paste(path, '/rsemResults', samples,'/',samples, '.genes.results', sep = "")

gene_ids = list()
row_length = NULL
for(i in 1:length(all.samples.ret)){
  counts <- read.table(all.samples.ret[i],
                       header = T, sep = "\t", check.names = F)
  row_length[i] = nrow(counts)
  
  gene_ids[[i]] = counts$gene_id
  
  if(i > 1){
    check_length = row_length[i] == row_length[i-1]
    if(check_length == F){
      print(i)
      print("Two data frames have differing number of rows")
      break
    }
    else{
      check_names = length(intersect(gene_ids[[i]], gene_ids[[i-1]]))
      if(check_names != row_length[i]){
        print(i)
        print("Two data frames have differing gene ids")
        break
      }
    }
  }
  
  if(i == 1){
    genes.matrix <- as.data.frame(matrix(NA, nrow = row_length[i], ncol = length(samples)))
    rownames(genes.matrix) <- counts$gene_id
    colnames(genes.matrix)[i] <- all.samples.ret[i]
    genes.matrix[ ,i] <- counts[ ,column]
  }else{
    colnames(genes.matrix)[i] <- all.samples.ret[i]
    genes.matrix[ ,i] <- counts[ ,column]
  }
}

if(column == 5){
  genes.count.matrix = genes.matrix
  save(genes.count.matrix, file = paste0(path, "/genes_count_matrix.RData"))
}else if(column == 6){
  genes.tpm.matrix = genes.matrix
  save(genes.tpm.matrix, file = paste0(path, "/genes_tpm_matrix.RData"))
}else if(column == 7){
  genes.fpkm.matrix = genes.matrix
  save(genes.fpkm.matrix, file = paste0(path, "/genes_fpkm_matrix.RData"))
}
```

## MultiQC

Run multiqc again to add on mapping statistics

``` bash
multiqc --interactive ./
```

# Differential Expression Analysis

<https://bioconductor.org/packages/release/bioc/html/edgeR.html>

## Setup

``` r
#load any packages here
library(edgeR)
library(ggplot2)
library(dplyr)
library(org.Hs.eg.db)
# library(org.Mm.eg.db)
library(gage)
library(pathview)
library(aliases2entrez)
library(data.table)
library(ggrepel)
library(Glimma)
library(ggpubr)
library(Rtsne)
library(UpSetR)
library(grid)
library(tidyr)
library(clusterProfiler)
library(pheatmap)
library(ggridges)
library(enrichplot)
library(ggvenn)
library(ReactomePA)

# helpful functions
source("utils_RNASeq.R")
```

## Load Data and Format as edgeR Object

``` r
load("genes_count_matrix.RData")
# OR
# counts = read.table("genes.count.matrix", header = T, sep = "\t", row.names = 1, check.names = F)

pheno = read.csv("SampleSheet.csv")

all(colnames(counts) == pheno$Sample.Name)
# group should be whatever the experimental groups of interest are
group = pheno$Group

# create DGEList object
y = DGEList(counts, group = factor(group))

# filter lowly expressed genes
# n is the sample size of the smallest experiment group
n = 3
# only keep genes that have more than 1 CPM in more than n samples
keep = rowSums(cpm(y)>1) >= n
sum(keep)
y = y[keep,]
dim(y)
# calculate scaling factors to convert raw library sizes into effective library sizes
y = calcNormFactors(y)
```

## Data Exploration

``` r
pca = prcomp(t(as.matrix(y$counts)), scale = T)
summary(pca)

var_explained = pca$sdev^2/sum(pca$sdev^2)

df=as.data.frame(cbind(pca$x[,1], pca$x[,2], pca$x[,3], pca$x[,4]))
colnames(df)=c('PC1','PC2','PC3','PC4')
# add variables that might explain variation
df$Sample = colnames(counts)
df$Group = pheno$Group

df %>%
  ggplot(aes(x=PC1,y=PC2))+ 
  geom_point(aes(color = Group), size=5) +
  geom_text_repel(aes(label=ID)) +
  labs(x=paste0("PC1: ",round(var_explained[1]*100,1),"%"),
       y=paste0("PC2: ",round(var_explained[2]*100,1),"%"))

df %>%
  ggplot(aes(x=PC3,y=PC4))+ 
  geom_point(aes(color = Group), size=5) +
  geom_text_repel(aes(label=ID)) +
  labs(x=paste0("PC3: ",round(var_explained[3]*100,1),"%"),
       y=paste0("PC4: ",round(var_explained[4]*100,1),"%"))
```

## Testing for Differential Expression

### Paired Design - 2 groups

This is testing under a paired sample design

``` r
# ID should be a unique ID for individual
ID = factor(pheno$ID)
Group = factor(pheno$Group)
Group = relevel(Group, ref = "ref.group")
# design matrix 
design = model.matrix(~ID + Group)
rownames(design) = colnames(y)
design

# estimate the negative binomial dispersion
y1 = estimateDisp(y, design, robust = T)
# coefficient of variation of biological variation
sqrt(y1$common.dispersion)
# view the dispersion estimates
plotBCV(y1)

# fit genewise GLMs
# tests are conducted for the last coefficient in the linear model (in this case the mMDSC vs Monocyte effect)
fit = glmQLFit(y1, design)
qlf = glmQLFTest(fit)

# show top 10 DEGs
topTags(qlf)

summary(decideTests(qlf, adjust.method = "BH", p.value = 0.05))
summary(decideTests(qlf, adjust.method = "BH", p.value = 0.05, lfc = 1))
```

### Unpaired Design - 2 groups

This would be the setup if the data were not paired

``` r
Group = factor(pheno$Group)
# design matrix
design = model.matrix(~0+Group)
rownames(design) = colnames(y)
design
  
# estimate the negative binomial dispersion
y1 = estimateDisp(y, design, robust = T)

#########################################################################################
# if there are outliers use robust method to downweight outliers when conducting tests
# y1 = estimateGLMRobustDisp(y, design)
#########################################################################################

# coefficient of variation of biological variation
sqrt(y1$common.dispersion)
# view the dispersion estimates
plotBCV(y1)

# fit genewise GLMs
fit = glmQLFit(y1, design)
# need to create a contrast to make the comparison of interest
qlf = glmQLFTest(fit, contrast=c(1,-1))

#########################################################################################
# if there are more than 2 levels in the group, contrasts might look different, like:
# qlf = glmQLFTest(fit, contrast = c(0,1,0,-1))
#########################################################################################

# show top 10 DEGs
topTags(qlf.notpaired)
```

## Plot Results

Using the paired design.

``` r
# these are functions in the "utils_RNASeq.R" that are hopefully helpful for plotting 
# volcano plot
plot.volcano(qlf, "Title", 0.05)
# p-value histogram
plot.pval.hist.simp(qlf)
# plot CPM boxplots of top N genes
plot.topN(qlf, y1, N, group, "x", "y", "Title")
```

# Gene Set Enrichment

## Reactome Pathways

``` r
gene.list = qlf$table$logFC
names = read.csv("rsem_gene_symbols_entrez.csv")
names = subset(names, SYMBOL%in%rownames(qlf$table))
# Names of gene list must be Entrez IDs
names(gene.list) = names$ENTREZID
# Sort in decreasing order
gene.list = sort(gene.list, decreasing = T)

gseReactome = gsePathway(gene = gene.list, pvalueCutoff = 0.05)

dotplot(gseReactome)

# plot Normalized Enrichment Score
plot.bar.NES(gseReactome@result, gseReactome@result$qvalues, "q-value")

# OR

results = read.table("Tables/edgeR_Results.tsv", sep = "\t", quote = "")
ids = bitr(rownames(results), "SYMBOL","ENTREZID", OrgDb = org.Mm.eg.db, drop = F)
results = merge(results, ids, by.x = 0, by.y = 1, all.x = T)

# within breeding temperature
## 20:30 vs 20:20
geneList = results$log2FC
names(geneList) = results$ENTREZID
geneList = geneList[order(geneList, decreasing = T)]
gseaReactome = gsePathway(geneList = geneList,
                               organism = "mouse",
                               # organism = "human",
                               pvalueCutoff = 0.05, pAdjustMethod = "BH",
                               seed = 534)
gseaReactome = setReadable(gseaReactome, OrgDb = org.Mm.eg.db)
write.csv(gseaReactome@result, file = "Tables/GSEA_Reactome.csv")
```

## IPA

``` r
ipa = read.table("Canonical_Pathways.txt", sep = "\t", skip = 2,
                  quote = "", header = T)

ipa$p.value = 10^(-1*ipa$X.log.p.value.)
sum(ipa$p.value<0.05)

ipa$Count = sapply(strsplit(ipa$Molecules, ","),length)

ipa$FDR = p.adjust(ipa$p.value, method = "BH")

ipa.sub = subset(ipa.sub, abs(z.score) > 2 & p.value < 0.05)

subset(ipa, FDR<0.05) %>%
  ggplot(aes(x = Ratio, y = reorder(Ingenuity.Canonical.Pathways, Ratio), color = FDR, size = Count)) + 
  geom_point() + 
  labs(x = "Overlap Ratio", y = "", fill = "FDR", size = "Number Overlapping") + 
  # scale_fill_gradient2(low = "darkblue", mid = "white", high = "darkred") + 
  theme_bw()

ipa.sub %>%
  ggplot(aes(x = z.score, y = reorder(Ingenuity.Canonical.Pathways, z.score), fill = z.score)) + 
  geom_col() + 
  labs(x = "z-score", y = "", fill = "z-score") + 
  scale_fill_gradient2(low = "darkblue", mid = "white", high = "darkred") + 
  theme_bw()
```
