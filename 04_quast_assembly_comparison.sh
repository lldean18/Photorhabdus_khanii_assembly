#!/bin/bash
# Laura Dean
# 18/9/26

# script to compare assemblies using Quast

#SBATCH --job-name=quast
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=30g
#SBATCH --time=10:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
#conda create --name quast quast
conda activate quast
mkdir -p /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/genome_comparisons
cd /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/genome_comparisons

# compare genomes with Quast
python /gpfs01/home/mbzlld/software_bin/miniconda3/envs/quast/bin/quast \
--threads 16 \
--eukaryote \
-o quast \
/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna \
/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna \
/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/pypolca/pypolca_corrected.fasta

# other options not used in this run
#	-r $reference \
#	-g $annotation \

# cleanup env
conda deactivate

