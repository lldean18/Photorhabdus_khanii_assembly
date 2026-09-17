#!/bin/bash
# Laura Dean
# 17/9/26

# script to perform assembly polishing with polypolish

#SBATCH --job-name=polypolish
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=30g
#SBATCH --time=10:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
source $HOME/.bash_profile
#conda create -c conda-forge -c bioconda -n polypolish polypolish  
conda activate polypolish

mkdir -p /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish
cd /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish
assembly=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna
reads1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_1.fq.gz
reads2=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_2.fq.gz


# align the short reads to the assembly
bwa index $assembly
bwa mem -t 8 -a $assembly $reads1 > alignments_1.sam
bwa mem -t 8 -a $assembly $reads2 > alignments_2.sam

# filter alignments
polypolish filter --in1 alignments_1.sam --in2 alignments_2.sam --out1 filtered_1.sam --out2 filtered_2.sam

# polish the assembly
polypolish polish $assembly filtered_1.sam filtered_2.sam > $(basename ${assembly%.*})_polished.fna



# cleanup env
module unload bwa-uoneasy/0.7.17-GCCcore-12.3.0
conda deactivate

