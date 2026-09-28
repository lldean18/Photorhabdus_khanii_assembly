#!/bin/bash
# Laura Dean
# 28/9/26

# script to find best bacterial assembly from mulitple with autocycler
# ran very quickly with srun 4 cores 20G mem

# setup env
source $HOME/.bash_profile
#conda create --name autocycler bioconda::autocycler
conda activate autocycler

# copy each assembly to a directory called assemblies
mkdir -p /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/autocycler
cd /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/autocycler
mkdir -p assemblies
cp /gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna assemblies/
cp /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna assemblies/
cp /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/unicycler_hybrid/assembly_rotated.fasta assemblies/
cp /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/flye_polished/assembly_polished_rotated.fasta assemblies/
reads=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/long_reads/323630L_Photorhabduskhanii.fastq.gz
 

# compress and cluster input assemblies
autocycler compress -i assemblies -a autocycler_out
autocycler cluster -a autocycler_out

# trim and resolve each QC pass cluster
for c in autocycler_out/clustering/qc_pass/cluster_*; do
    autocycler trim -c "$c"
    if [[ $(wc -c <"$c"/1_untrimmed.gfa) -lt 1000000 ]]; then
        autocycler dotplot -i "$c"/1_untrimmed.gfa -o "$c"/1_untrimmed.pngc
        autocycler dotplot -i "$c"/2_trimmed.gfa -o "$c"/2_trimmed.png
    fi
    autocycler resolve -c "$c"
done

# combine resolved clusters into a final assembly
autocycler combine -a autocycler_out -i autocycler_out/clustering/qc_pass/cluster_*/5_final.gfa -r "$reads"


# cleanup env
conda deactivate


