# Computational-Biology-Colloquium_CBC-
## Project Overview
This project explores the genome of a butterfly sample (SRR25297534) using a comparative genomics approach. It includes quality control, trimming, assembly, and downstream analyses such as gene family evolution and synteny conservation.

## Data Source
- NCBI SRA Accession: [SRR25297534](https://www.ncbi.nlm.nih.gov/sra/?term=SRR25297534)
- Paired-end Illumina sequencing reads

## Methods
### 1. Quality Control
- Tool: FastQC
- Output: HTML and summary reports for raw and trimmed reads

### 2. Trimming
- Tool: Trimmomatic v0.39
- Parameters: Adapter removal

### 3. Genome Assembly
- Tool: SPAdes
- Input: Trimmed FASTQ files
- Output: Assembled contigs (FASTA)

### 4. Comparative Genomics
- Reference Genomes: Heliconius melpomene, Bombyx mori, Danaus plexippus
- Analyses:
  - Genome statistics (size, N50, GC content)
  - Gene family evolution (OrthoFinder)
  - Synteny analysis (MUMmer)
  - Phylogenetic tree construction

## Goals
- Assess genome quality and completeness
- Identify expanded or contracted gene families
- Compare synteny blocks across butterfly species
- Visualize genomic relationships and evolutionary patterns

## How to Run the Pipeline
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/ButterflyGenomics.git
   cd ButterflyGenomics
   ```
2. Run trimming and QC:
   ```bash
   bash trim_and_qc.sh
   ```
3. Assemble genome:
   ```bash
   bash assemble_genome.sh
   ```
4. Launch R and run analysis:
   ```r
   source("scripts/R_pipeline.R")
   results <- main_analysis()
   ```

## Folder Structure
- `data/`: Raw and trimmed FASTQ files
- `results/`: Assembly, QC, and analysis outputs
- `figures/`: Visualizations and plots
- `scripts/`: Bash and R scripts
- `logs/`: Log files

## Citations
- Prjibelski, A., Antipov, D., Meleshko, D., Lapidus, A. and Korobeynikov, A., 2020. Using SPAdes de novo assembler. Current protocols in bioinformatics, 70(1), p.e102.
- Bolger, A.M., Lohse, M. and Usadel, B., 2014. Trimmomatic: a flexible trimmer for Illumina sequence data. Bioinformatics, 30(15), pp.2114-2120.
## Author
Samira S.

