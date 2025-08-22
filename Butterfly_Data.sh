#! /bin/bash

######### Download Data and Quality Control ############
## Purpose: The purpose of this script is to download data from the SRA and evalulate raw data quality
## Required files : SRR_IDs.txt (located in RNAseq_Samples directory)
## Recommended parameters (on ASC):
##              core: 1
##              time limit (HH:MM:SS): 04:00:00
##              Memory: 36gb
###############################################

#!/bin/bash

# ============================================================================
# Butterfly Genomics Project: Download SRA Data and Run Quality Control
# ============================================================================
# Purpose: Download FASTQ data for SRR25297534 and assess raw data quality
# Recommended ASC parameters:
#   - Core: 1
#   - Time limit: 04:00:00
#   - Memory: 36GB
# ============================================================================

# Load required modules
source /apps/profiles/modules_asax.sh.dyn
module load sra
module load fastqc/0.10.1

# Define user and project variables
MyID=aubsxs003
ProjectName=ButterflyGenomics
SRR_ID=SRR25297534

# Define directories
WD=/scratch/$MyID/$ProjectName
DD=$WD/data
QC=$WD/results/fastqc

# Create directories
mkdir -p $DD $QC

# Move to data directory
cd $DD

# Download FASTQ file using SRA Toolkit
echo "Downloading FASTQ for $SRR_ID..."
fastq-dump --split-files -F $SRR_ID

# Run FastQC on downloaded FASTQ files
echo "Running FastQC..."
fastqc ${SRR_ID}*.fastq --outdir=$QC

# Archive FastQC results
cd $QC
tar -cvzf ${SRR_ID}_fastqc_results.tar.gz *
echo "Download and QC complete. Results archived in $QC/${SRR_ID}_fastqc_results.tar.gz"
                                                  
