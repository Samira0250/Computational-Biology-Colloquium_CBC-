#!/bin/bash

# ============================================================================
# Butterfly Genomics Project: Trimming and Post-Cleaning Quality Control
# ============================================================================
# Purpose: Trim adapters and low-quality bases using Trimmomatic, then assess quality with FastQC
# Recommended ASC parameters:
#   - Queue: medium
#   - Core: 6
#   - Time limit: 02:00:00
#   - Memory: 12GB
# ============================================================================

# Load modules
# Load modules
source /apps/profiles/modules_asax.sh.dyn
module load trimmomatic/0.39
module load fastqc/0.10.1

# Define user and project variables
MyID=aubsxs003
ProjectName=ButterflyGenomics
SRR_ID=SRR25297534

# Define directories
WD=/scratch/$MyID/$ProjectName
DD=$WD/data
CD=$WD/CleanData
PCQ=PostCleanQuality
adapters=AdaptersToTrim_All.fa

# Create necessary directories
mkdir -p $CD $WD/$PCQ

# Move to raw data directory
cd $DD

# Copy adapter file (adjust path if needed)
cp /home/$MyID/class_shared/$adapters .

# Run Trimmomatic for single-end data (adjust if paired-end)
java -jar /apps/x86-64/apps/spack_0.19.1/spack/opt/spack/linux-rocky8-zen3/gcc-11.3.0/trimmomatic-0.39-iu723m2xenra563gozbob6ansjnxmnfp/bin/trimmomatic-0.39.jar \
SE -threads 6 -phred33 \
${SRR_ID}_1.fastq ${CD}/${SRR_ID}_1_trimmed.fastq \
ILLUMINACLIP:$adapters:2:35:10 HEADCROP:10 LEADING:30 TRAILING:30 SLIDINGWINDOW:6:30 MINLEN:36

# Run FastQC on trimmed data
fastqc ${CD}/${SRR_ID}_1_trimmed.fastq --outdir=$WD/$PCQ

# Archive FastQC results
cd $WD/$PCQ
tar -cvzf ${PCQ}_trimmed_fastqc.tar.gz *

echo "Trimming and post-cleaning QC complete. Results saved in $WD/$PCQ"
