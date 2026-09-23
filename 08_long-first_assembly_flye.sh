#!/bin/bash
# Laura Dean
# 22/09/26

# Script to perform de-novo long-read first assembly with Flye
# and then polish this assembly with short reads with polypolish

#SBATCH --job-name=flye+polypolish
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=48g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
SHORT1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_1.fq.gz
SHORT2=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_2.fq.gz
LONG=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/long_reads/323630L_Photorhabduskhanii.fastq.gz
OUTDIR=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/flye_polished

# hashing the bit that already completed
##  # perform initial genome assembly
##  conda activate flye
##  flye \
##  --nano-hq $LONG \
##  --out-dir $OUTDIR \
##  --threads 16 \
##  --genome-size 5m
##  conda deactivate
##  
##  # align the short reads to the assembly
##  bwa index $OUTDIR/assembly.fasta
bwa mem -t 16 -a $OUTDIR/assembly.fasta $SHORT1 > $OUTDIR/alignments_1.sam
bwa mem -t 16 -a $OUTDIR/assembly.fasta $SHORT2 > $OUTDIR/alignments_2.sam

# filter alignments
conda activate polypolish
polypolish filter --in1 $OUTDIR/alignments_1.sam --in2 $OUTDIR/alignments_2.sam --out1 $OUTDIR/filtered_1.sam --out2 $OUTDIR/filtered_2.sam

# polish the assembly
polypolish polish $OUTDIR/assembly.fasta $OUTDIR/filtered_1.sam $OUTDIR/filtered_2.sam > $OUTDIR/assembly_polished.fasta


# cleanup env
module unload bwa-uoneasy/0.7.17-GCCcore-12.3.0
conda deactivate

