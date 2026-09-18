#!/bin/bash
# Laura Dean
# 17/9/26

# script to perform assembly polishing with pypolca

#SBATCH --job-name=pypolca
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=10g
#SBATCH --time=10:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
#conda create -n pypolca_env pypolca
conda activate pypolca_env

cd /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly
assembly=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna
reads1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_1.fq.gz
reads2=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_2.fq.gz


# polish the assembly
pypolca run -a $assembly -1 $reads1 -2 $reads2 -t 8 -o pypolca --careful


# cleanup env
conda deactivate

