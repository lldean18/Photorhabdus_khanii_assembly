#!/bin/bash
# Laura Dean
# 18/9/26

# script to compare polished and unpolished assemblies with mummer

#SBATCH --job-name=mummer
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20g
#SBATCH --time=8:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate mummer
mkdir -p /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/genome_comparisons/mummer
cd /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/genome_comparisons/mummer
unpolished=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna
polished1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna
polished2=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/pypolca/pypolca_corrected.fasta


# quantify differences between polished and unpolished assemblies
nucmer --prefix unpol_vs_pol1 $unpolished $polished1
delta-filter -1 unpol_vs_pol1.delta > unpol_vs_pol1.filtered.delta
show-snps -Clr unpol_vs_pol1.filtered.delta > unpol_vs_pol1.snps
mummerplot --png --layout -R $unpolished -Q $polished1 --filter --prefix unpol_vs_pol1 unpol_vs_pol1.filtered.delta

nucmer --prefix pol1_vs_pol2 $polished1 $polished2
delta-filter -1 pol1_vs_pol2.delta > pol1_vs_pol2.filtered.delta
show-snps -Clr pol1_vs_pol2.filtered.delta > pol1_vs_pol2.snps
mummerplot --png --layout -R $polished1 -Q $polished2 --filter --prefix pol1_vs_pol2 pol1_vs_pol2.filtered.delta


# cleanup env
conda deactivate

