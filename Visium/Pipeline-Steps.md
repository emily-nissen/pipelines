Visium Pipeline
================
Emily (Nissen) Schueddig
2025-04-11

- [Project Notes](#project-notes)
- [Pre-processing](#pre-processing)
  - [Step 1: 0_Space_Ranger](#step-1-0_space_ranger)
- [Analysis](#analysis)

**Last modified:** 2025-04-11

# Project Notes

Add any project notes here

# Pre-processing

See the “PreProcess/” folder for scripts that can be downloaded based on
the code in the following steps.

## Step 1: 0_Space_Ranger

``` bash
sbatch 0_Space_Ranger.sh
```

Run Space Ranger. You will need to set \$PATH variables in the bash
script.

\$RUNFOLDER = path to the sequencing run

\$IMAGEFOLDER = path to the imaging

\$TOOLS = path to folder where Space Ranger was downloaded

\$REFERENCES = path to folder where 10x transcriptome build is
downloaded

# Analysis

See analysis folder for R Markdown describing analysis with Visium Data.
