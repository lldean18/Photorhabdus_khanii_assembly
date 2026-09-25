#!/bin/bash
# Laura Dean
# 18/9/26

# script to map reads to different assembly versions to compare them

#SBATCH --job-name=MapAndCall
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=40g
#SBATCH --time=48:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


#setup env
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
module load bcftools-uoneasy/1.19-GCC-13.2.0
source $HOME/.bash_profile
conda activate samtools1.24

mkdir -p /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/genome_comparisons/mapping
cd /gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/genome_comparisons/mapping
unpolished=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna
polished1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna
unicycler_hybrid=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/unicycler_hybrid/assembly_rotated.fasta
flye=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/flye_polished/assembly_polished_rotated.fasta
reads1=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_1.fq.gz
reads2=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/Photorhabdus_short_reads/PKWT_EKDN250027778-1A_22W3MHLT4_L8_2.fq.gz
long_reads=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/long_reads/323630L_Photorhabduskhanii.fastq.gz

# map short reads to the assemblies
##  bwa index $unpolished
##  bwa mem -t 8 $unpolished $reads1 $reads2 | samtools sort -@ 8 -o unpolished.bam
##  samtools index unpolished.bam
##  
##  bwa index $polished1
##  bwa mem -t 8 $polished1 $reads1 $reads2 | samtools sort -@ 8 -o polished1.bam
##  samtools index polished1.bam
##  
##  bwa index $unicycler_hybrid
##  bwa mem -t 8 $unicycler_hybrid $reads1 $reads2 | samtools sort -@ 8 -o unicycler_hybrid.bam
##  samtools index unicycler_hybrid.bam
##  
##  bwa index $flye
##  bwa mem -t 8 $flye $reads1 $reads2 | samtools sort -@ 8 -o flye.bam
##  samtools index flye.bam

# generate mapping statistics
##  samtools flagstat unpolished.bam > unpolished.flagstat.txt
##  samtools flagstat polished1.bam > polished1.flagstat.txt
##  samtools flagstat unicycler_hybrid.bam > unicycler_hybrid.flagstat.txt
##  samtools flagstat flye.bam > flye.flagstat.txt


# call SNPs against reads
##  samtools faidx $unpolished
##  samtools faidx $polished1
##  samtools faidx $unicycler_hybrid
##  samtools faidx $flye

##  bcftools mpileup --threads 8 -f $unpolished -Ou unpolished.bam |
##  bcftools call --ploidy 1 -mv --threads 8 -Oz -o unpolished_vs_reads.vcf.gz
##  bcftools filter --threads 8 -i 'QUAL>=30 && DP>=20' unpolished_vs_reads.vcf.gz -Oz -o unpolished_vs_reads.flt.vcf.gz
##  bcftools index --threads 8 -t unpolished_vs_reads.flt.vcf.gz
##  
##  bcftools mpileup --threads 8 -f $polished1 -Ou polished1.bam |
##  bcftools call --ploidy 1 -mv --threads 8 -Oz -o polished1_vs_reads.vcf.gz
##  bcftools filter --threads 8 -i 'QUAL>=30 && DP>=20' polished1_vs_reads.vcf.gz -Oz -o polished1_vs_reads.flt.vcf.gz
##  bcftools index --threads 8 -t polished1_vs_reads.flt.vcf.gz
##  
##  bcftools mpileup --threads 8 -f $unicycler_hybrid -Ou unicycler_hybrid.bam |
##  bcftools call --ploidy 1 -mv --threads 8 -Oz -o unicycler_hybrid_vs_reads.vcf.gz
##  bcftools filter --threads 8 -i 'QUAL>=30 && DP>=20' unicycler_hybrid_vs_reads.vcf.gz -Oz -o unicycler_hybrid_vs_reads.flt.vcf.gz
##  bcftools index --threads 8 -t unicycler_hybrid_vs_reads.flt.vcf.gz
##  
##  bcftools mpileup --threads 8 -f $flye -Ou flye.bam |
##  bcftools call --ploidy 1 -mv --threads 8 -Oz -o flye_vs_reads.vcf.gz
##  bcftools filter --threads 8 -i 'QUAL>=30 && DP>=20' flye_vs_reads.vcf.gz -Oz -o flye_vs_reads.flt.vcf.gz
##  bcftools index --threads 8 -t flye_vs_reads.flt.vcf.gz

conda deactivate
##################
### LONG READS ###
##################

# map long reads to the assembly
declare -A array
array[unpolished]=/gpfs01/home/mbzlld/data/bryant/11d3a3246d_20251024_Bryant1L/assembly/323630L_Photorhabduskhanii.fna
array[polished1]=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/polypolish/323630L_Photorhabduskhanii_polished.fna
array[unicycler_hybrid]=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/unicycler_hybrid/assembly_rotated.fasta
array[flye]=/gpfs01/home/mbzlld/data/bryant/photorhabdus_assembly/flye_polished/assembly_polished_rotated.fasta

# loop over the array to map the long reads
conda activate minimap2
for i in "${!array[@]}"
do
  minimap2 -ax map-ont -t 8 ${array[$i]} $long_reads |
  samtools sort -@ 8 -o ${i}_long.bam
  samtools index ${i}_long.bam

  bcftools mpileup --threads 8 -f ${array[$i]} -Ou ${i}_long.bam |
  bcftools call --ploidy 1 -mv --threads 8 -Oz -o ${i}_vs_long_reads.vcf.gz
  bcftools filter --threads 8 -i 'QUAL>=30 && DP>=20' ${i}_vs_long_reads.vcf.gz -Oz -o ${i}_vs_long_reads.flt.vcf.gz
  bcftools index --threads 8 -t ${i}_vs_long_reads.flt.vcf.gz
done

# cleanup env
module unload bwa-uoneasy/0.7.17-GCCcore-12.3.0
module unload bcftools-uoneasy/1.19-GCC-13.2.0
conda deactivate

