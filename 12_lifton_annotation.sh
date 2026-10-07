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


# list all the feature types that are present in the annotation (to be lifted over)
awk '!/^#/ {print $3}' $annotation | sort | uniq > $(dirname $polished)/feature_types.txt
sed -i '/^[[:space:]]*$/d' $(dirname $polished)/feature_types.txt


# add parent information
conda activate gffread
sed 's/^\([^\t]*\t\)\{6\}?/\1./' $annotation |
awk 'BEGIN{FS="\t"; OFS=FS} {sub("?", ".", $7)}1' $annotation |
gffread -O --keep-comments - > $(dirname $polished)/temp.gff
conda deactivate

gffread --keep-comments -T $annotation > $(dirname $polished)/temp.gtf


# transfer the annotation to the polished assembly
conda activate liftoff
# fix liftoff
#cp "$(python -c 'import liftoff,os; print(os.path.dirname(liftoff.__file__))')/polish.py" \
#   "$(python -c 'import liftoff,os; print(os.path.dirname(liftoff.__file__))')/polish.py.orig"
# then edited the function def group_cds_by_tran


liftoff \
    $polished \
    $assembly \
    -f $(dirname $polished)/feature_types.txt \
    -infer_genes \
    -g $(dirname $polished)/temp.gff \
    -o ${polished%.*}.gff \
    -p 4
conda deactivate



