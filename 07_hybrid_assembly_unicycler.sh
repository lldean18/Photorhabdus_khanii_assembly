#!/bin/bash
# Laura Dean
# 22/09/26

# Script to perform de-novo hybrid assembly with Unicycler

#SBATCH --job-name=unicycler
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=48g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate unicycler
SHORT1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_1.fq.gz
SHORT2=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_2.fq.gz
LONG=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/long_reads/323630L_Photorhabduskhanii.fastq.gz
OUTDIR=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/unicycler_hybrid


# perform hybrid genome assembly
unicycler \
--short1 $SHORT1 \
--short2 $SHORT2 \
--long $LONG \
--out $OUTDIR \
--threads 16


# cleanup env
conda deactivate

