scRNA-seq Pipeline
================
Emily Nissen
2024-02-07

- [Pre-processing](#pre-processing)

# Pre-processing

These steps are specifically for data from 10x genomics.

The output will be a folder with summary metrics and files needed for
downstream analysis.

``` bash
# path to cell ranger (downloaded from 10x genomics)
## using version 7.1.0
### cell.ranger <- "/path/tools/cellranger-7.1.0/cellranger "

/path/tools/cellranger-7.1.0/cellranger count --id=sample \
--transcriptome=/path/References/cellranger/refdata-gex-GRCh38-2020-A \ --fastqs=/path/RawData/usftp21.novogene.com/01.RawData/sample \
```

<https://hbctraining.github.io/scRNA-seq/lessons/04_SC_quality_control.html>
