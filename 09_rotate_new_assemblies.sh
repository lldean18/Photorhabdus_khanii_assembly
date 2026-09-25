#!/bin/bash
# Laura Dean
# 25/9/26

# script to rotate the new assemblies to the same startpoint as the microbesNG one

#################
### SETUP ENV ###
#################

# set the assembly to be rotated
NEW_ASSEMBLY=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/unicycler_hybrid/assembly.fasta
NEW_ASSEMBLY=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/flye_polished/assembly_polished.fasta

# set the start sequence for the Phororhabdus contigs
START_LARGE_CONTIG=ATAAACGCTTGCCAGCGCCAAAGAACTCCCTATAATGCGCCACCACTGACCGACACAACGCTGACAAAACGTGTGAGGTCAGGCAGAGCAACGTGAATCAGCGCTTGACTCTGCGGGCGAAAAGCGTAGTATACGCAGCCCGGCTGAACCAGAATGTTAATTTTTAGTTCAGCCTGCTCT
START_SMALL_CONTIG=GAAAACATTAGCCACTATCGCTTTTAACCTACCTGATTTCGGAGTTCATCACCATGAATAATTCGTTGACTGAATTCATCCATGAATATATTGATCAACACCAAAGTGATTTTATTCACCTTAGCGATAATATTTGGGAACACCCAGAAACCCGCTTTGAAGAAACCTTTTCTGCGGAGC

# move to the directory in which it is located
cd $(dirname $NEW_ASSEMBLY)


###########################################
### SPLIT THE ASSEMBLY INTO ITS CONTIGS ###
###########################################

# split it into its separate contigs
awk '/^>/ {
    file = sprintf("part_%03d.fasta", ++n)
}
file {
    print > file
}' $(basename $NEW_ASSEMBLY)

# assess which contig is the larger one
awk '{ print length }' part_001.fasta
awk '{ print length }' part_002.fasta
# in both cases the first contig is the larger chromosome

############################
### PERFORM THE ROTATION ###
############################

# rotate the larger chromosome
/gpfs01/home/mbzlld/software_bin/rotate/rotate \
-s $START_LARGE_CONTIG part_001.fasta > part_001_rotated.fasta
# keep the old header (by default it keeps only until the first space)
sed -i "1s/.*/$(sed -n '1p' part_001.fasta)/" part_001_rotated.fasta

# rotate the smaller plasmid
/gpfs01/home/mbzlld/software_bin/rotate/rotate \
-s $START_SMALL_CONTIG part_002.fasta > part_002_rotated.fasta
# keep the old header (by default it keeps only until the first space)
sed -i "1s/.*/$(sed -n '1p' part_002.fasta)/" part_002_rotated.fasta


#######################################################
### STICK THE ROTATED CONTIGS BACK IN THE SAME FILE ###
#######################################################

cat part_001_rotated.fasta part_002_rotated.fasta > $(basename ${NEW_ASSEMBLY%.*})_rotated.fasta

# cleanup
rm part_00*

