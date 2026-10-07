#!/bin/bash
# Laura Dean
# 28/9/26

# script to copy an annotation to a polished version of the assembly


# setup env
srun --partition defq --cpus-per-task 2 --mem 20g --time 08:00:00 --pty bash
source $HOME/.bash_profile
assembly=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna
annotation=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.gff
polished=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna


##  # index the polished assembly
##  conda activate samtools1.24
##  samtools faidx $polished
##  conda deactivate


# load software
#conda create --name ratt bioconda::ratt
conda activate ratt
#conda install --channel conda-forge --channel bioconda perl-bioperl
#conda install bioconda::perl-yaml

# prep the input annotation embl files
cd $(dirname $polished)/annotation
cp /share/bryant_lab/reference_genomes/323630L_Photorhabduskhanii.embl ./

# split the embl annotation into one file per contig
awk 'BEGIN {n=0}
     /^ID   / {n++; file="contig_" n ".embl"}
     {print > file}
     /^\/\/$/ {close(file)}
' 323630L_Photorhabduskhanii.embl

# move things around so its organised correctly for ratt
mkdir contig_1_annotations
mkdir contig_2_annotations
mv contig_1.embl contig_1_annotations/
mv contig_2.embl contig_2_annotations/

# remove the unsplit file
rm 323630L_Photorhabduskhanii.embl

# next make the separate fasta files
cp $assembly ./
awk 'BEGIN {n=0}
     /^>/ {n++; file="contig_" n ".fna"}
     {print > file}
' $(basename $assembly)

# remove the unsplit file
rm $(basename $assembly)


# copy the annotation from the old assembly to the polished version
ratt \
--prefix $(basename ${polished%.*}) \
--type Assembly \
--refseq $assembly \
contig_1_annotations contig_1.fna 

ratt \
--prefix $(basename ${polished%.*}) \
--type Assembly \
--refseq $assembly \
contig_2_annotations contig_2.fna

# fix the contig names in the embl annotations made my RATT
sed -i 's/^\(ID[[:space:]]*\)[^;]*/\1contig_1/' $(basename ${polished%.*}).contig_1.final.embl
sed -i 's/^\(ID[[:space:]]*\)[^;]*/\1contig_2/' $(basename ${polished%.*}).contig_2.final.embl

# merge the final annotations
cat 323630L_Photorhabduskhanii_polished.contig_1.final.embl \
323630L_Photorhabduskhanii_polished.contig_2.final.embl > 323630L_Photorhabduskhanii_polished.embl


# convert to gff format
bp_genbank2gff3 \
--format EMBL \
--outdir ./ \
323630L_Photorhabduskhanii_polished.embl


# cleanup env
conda deactivate



