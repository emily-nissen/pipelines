RRBS Pipeline
================
Emily (Nissen) Schueddig
2024-08-07

- [Project Notes](#project-notes)
- [Pre-processing](#pre-processing)
  - [Download scripts](#download-scripts)
  - [Script 1: 1_PreProcess_bcl2fastq](#script-1-1_preprocess_bcl2fastq)
  - [Script 2:
    2_PreProcess_Cat_Trim_Fastqc](#script-2-2_preprocess_cat_trim_fastqc)
  - [Script 3:
    3_PreProcess_Diversity_Trim](#script-3-3_preprocess_diversity_trim)
  - [Script 4:
    4_PreProcess_Align_Bismark](#script-4-4_preprocess_align_bismark)
  - [Script 5: 5_PreProcess_Dedup](#script-5-5_preprocess_dedup)
  - [Script 6:
    6_PreProcess_Extract_Methylation](#script-6-6_preprocess_extract_methylation)
- [Analysis](#analysis)
  - [0_Deconvolute_Cell_Types](#0_deconvolute_cell_types)
  - [1_Create_Data_for_Testing](#1_create_data_for_testing)
  - [2_Test_Differential_Methylation](#2_test_differential_methylation)
  - [3_Get_Top_Variable_CpGs](#3_get_top_variable_cpgs)
  - [4_Annotate_CpGs](#4_annotate_cpgs)

**Last modified:** 2025-03-31

# Project Notes

Add any project notes here

# Pre-processing

These are the folders you will to set up in the project folder on the
cluster:

``` bash
cd /path/to/folder

mkdir trimmedData
mkdir trimmedData/complete
mkdir fastqc
mkdir bismarkAlignments
mkdir extractMethylation
```

## Download scripts

Download the scripts in the “PreProcess” folder. Each script is to be
run one by one to ensure the steps are completed correctly. Files output
at each step should be inspected before moving on to the next script.

The scripts should be run in the following order:

``` bash
sbatch 1_Pre_Process_bcl2fastq.sh

sbatch 2_Pre_Process_Cat_Trim_Fastqc.sh

sbatch 3_Pre_Process_Diversity_Trim.sh

sbatch 4_Pre_Process_Align_Bismark.sh

sbatch 5_Pre_Process_Dedup.sh

sbatch 6_Pre_Process_Extract_Methylation.sh
```

If the sequencing was done at the KUMC genomics core - they most likely
used the NuGEN Ovation RRBS Methyl-Seq technology. These steps follow
the steps found here: <https://github.com/nugentechnologies/NuMetRRBS>

More details about each script are below.

## Script 1: 1_PreProcess_bcl2fastq

When they use the NuGEN Ovation technology, the genomics core is not
able to convert the BCL to FastQ files to take into account the
additional 6 bases of random UM for duplicate marking. And we will have
to do it.

We use the –use-bases-mask Y*,I8Y*,Y\* to indicate the first read should
be generated as a fastq file, the first 8 bases of the second read are
the index, and the additional bases after that (6 unknown bps) should be
generated as a fastq file, and the third read should be generated as a
fastq file.

## Script 2: 2_PreProcess_Cat_Trim_Fastqc

Concatenate FastQ files if there are multiple lanes. Then trim adaptor
sequence that might be present on the 3’ end.

## Script 3: 3_PreProcess_Diversity_Trim

Following adaptor and quality trimming and prior to alignment, the
additional sequence added by the diversity adaptors must be removed from
the data. This trimming is performed by a custom python script
trimRRBSdiversityAdaptCustomers.py provided by NuGEN in this repository.
The script removes any reads that do not contain an MspI site signature
YGG at the 5’ end. For paired end data an MspI site signature is
required at the 5’ end of both sequences. The script accepts as input
one or two fastq file strings, given either as complete filenames or as
a pattern in quotes. When a pattern is given, the script will find all
the filenames matching a specified pattern according to the rules used
by the Unix shell (\*,?). You may access the help option of this script
for more details -h.

The script will generate new file(s) with \_trimmed.fq appended to the
filename. The reads will have been trimmed at the 5’ end to remove the
diversity sequence (0–3 bases), and all reads should begin with YGG,
where Y is C or T. On the 3’ end, 5 bases are trimmed from every read (6
bases are trimmed for paired-end to prevent alignment issues).

The trimmed fastq file should be used for downstream analysis including
bismark.

## Script 4: 4_PreProcess_Align_Bismark

The data should be aligned to the genome of interest using Bismark.

## Script 5: 5_PreProcess_Dedup

Duplicate determination with NuDup is an optional step. Can only be done
if the N6 molecular tags were added.
<https://github.com/tecangenomics/nudup>

The N6 molecular tag is a novel approach to the unambiguous
identification of unique molecules. Traditionally, PCR duplicates are
identified in libraries made from randomly fragmented inserts by mapping
inserts to the genome and discarding any paired end reads that share the
same genomic coordinates. This approach doesn’t work for restriction
digested samples, such as RRBS, because all fragments mapping to a
genomic location will share the same ends. The Duplicate Marking tool
utilizes information provided by the unique N6 sequence to discriminate
between true PCR duplicates and independent adaptor ligation events to
fragments with the same start site resulting in the recovery of more
usable data.

Bismark modifies read names in its output and NuDup requires that the
read names in the alignment and index files match exactly. The
strip_bismark_sam.sh script is provided to strip the read name changes
that happen in bismark.

## Script 6: 6_PreProcess_Extract_Methylation

Extract the methylation data using Bismark.

# Analysis

These are the folders you will to set up in the project folder on the
cluster:

``` bash
cd /path/to/folder

mkdir robjects
```

## 0_Deconvolute_Cell_Types

This is an optional script, it can be run if you have human peripheral
blood.

One issue with deconvolution is the IDOL optimized library is based on
the EPIC array and in the past, we have not seen large overlap with RRBS
CpG sites and EPIC array sites. This script will run deconvolution with
any IDOL optimized CpGs found in the RRBS data. But please note, this
will only be a fraction of the CpGs in the IDOL library.

## 1_Create_Data_for_Testing

Combine all individual extract methylation files into one table.

## 2_Test_Differential_Methylation

Tests for differential methylation between 2 groups.

If you have human peripheral blood, and deconvoluted cell types, run the
2.2_Test_Differential_Methylation_Adjusted_CellProp.R script.

## 3_Get_Top_Variable_CpGs

Usually there are millions of CpG sites tested. We can subset the data
to the top N varying CpGs to summarize data and look at plots. I have
found that most of the CpGs that show differential methylation, are
found in the top 500K variable CpGs.

## 4_Annotate_CpGs

Annotate CpG sites with gene information and type of CpGs information.
