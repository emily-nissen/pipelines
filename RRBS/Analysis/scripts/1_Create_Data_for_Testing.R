##################################
# Title: Create Files
# Author: Emily Nissen
# Date: 08/08/2024
##################################

library(R.utils)

dir = "/path/to/folder/"
data.dir = paste0(dir, "extractMethylation/")

source(paste0(dir,"readBismarkFiles.R"))

sample.sheet = read.csv(paste0(dir,"SampleSheet.csv"), skip = 18)

intersect_all <- function(a,b,...){
  Reduce(intersect, list(a,b,...))
}

file.list = list()
sample.id.list = list()

for(i in 1:nrow(sample.sheet)){
  file.list[[i]] = paste0(data.dir, sample.sheet$Sample_Name[i], "/", sample.sheet$Sample_Name[i], "_trimmed_bismark_stripped.dedup.bismark.cov.gz")

  sample.id.list[[i]] = sample.sheet$Sample_Name[i]
}

names(file.list) = sample.sheet$Sample_Name

min.cov = 10
coverage.data.list = list()
fracMeth.data.list = list()

for(i in 1:length(file.list)){
  df=fread.gzipped(file.list[[i]], data.table=FALSE)
  # filter CpGs based on minimum coverage
  df=df[(df[,5]+df[,6])>min.cov, ]

  names = paste0(df[,1], ".", df[,2])

  new.df = as.data.frame(names)
  new.df$fracMeth = df[,4]/100
  new.df = new.df[order(new.df$names),]

  fracMeth.data.list[[i]] = new.df
  names(fracMeth.data.list)[i] = sample.id.list[[i]]

  new.df = as.data.frame(names)
  new.df$coverage = df[,5] + df[,6]
  new.df = new.df[order(new.df$names),]

  coverage.data.list[[i]] = new.df
  names(coverage.data.list)[i] = sample.id.list[[i]]
}

save(fracMeth.data.list, file = paste0(dir,"robjects/Fraction_Methylation_Data_List_filtered.RData"))
save(coverage.data.list, file = paste0(dir,"robjects/Coverage_Data_List_filtered.RData"))

print("Starting finding common cpgs...")
# intersect all CpGs identified from all samples to find set of CpGs common across all samples
names = intersect_all(fracMeth.data.list[[1]]$names, fracMeth.data.list[[2]]$names, fracMeth.data.list[[3]]$names)

save(names, file = paste0(dir,"robjects/all_common_cpgs.RData"))

print("Length names...")
print(length(names))

meth.data = as.data.frame(matrix(NA, nrow = nrow(sample.sheet), ncol = length(names)))
rownames(meth.data) = sample.sheet$Sample_Name
colnames(meth.data) = names

print("Starting to create test data...")

for(i in 1:nrow(sample.sheet)){
  data = fracMeth.data.list[[i]]
  data = data[data$names%in%names,]

  if(all(data$names == colnames(meth.data)) == T){
    meth.data[i,] = data$fracMeth
  }else{
    data = data[order(match(data$names, colnames(meth.data))),]
    meth.data[i,] = data$fracMeth
  }
  print(i)
}

save(meth.data, file = paste0(dir,"robjects/Methyl_Data.RData"))

print("Loop end...")

dim(meth.data)
rownames(meth.data)

test.data = cbind(sample.sheet[1:nrow(sample.sheet),"Sample_Name"], meth.data)

save(test.data, file = paste0(dir,"robjects/Test_Data.RData"))

