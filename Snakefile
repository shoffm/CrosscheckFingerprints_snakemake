import glob 
import re

# ---------------- CHANGE these variables to match the project -------------

# input file directory - where bam files exist in this structure project_dirrectory/sample_1/sample_1.bam
bam_dir = 'path/to/bams/project_directory/' #include / at the end for directory
# bam suffix - where samples are named like sample_1.Aligned.sortedByCoord.out.bamm
bam_suffix = '.Aligned.sortedByCoord.out.bam'

# fingerprint vcf output directory - ENSURE this directory exists (mkdir fingerprints) and is empty to start
vcf_outpath = 'path/to/crosscheck_fingerprints_pipeline/fingerprints/'  #include / at the end for directory

# haplotype map file location 
haplotype_map = 'path/to/hg38_nochr.map'

# reference sequence file location 
ref_seq = 'path/to/Homo_sapiens.GRCh38.dna.primary_assembly.fa'

# crosscheckFingerprint metric output file - should be in an existing directory (mkdir crosscheck_metrics)
metric_outpath = '/lustre/scratch123/hgi/projects/pops2/rna-seq/qc/crosscheck_fingerprints/crosscheck_metrics/'

# ---------------------------------------------------------------------------

# generate strings used later in the script
infile = bam_dir + "{smp}/{smp}" + bam_suffix
outfile_bams = bam_dir + "{smp}/{smp}_RG.bam"
indexed_bams = bam_dir + "{smp}/{smp}_RG.bam.bai"
outfile_vcfs = vcf_outpath + "{smp}.vcf"
vcf_path = vcf_outpath + "*.vcf"
vcf_list_path = vcf_outpath + "vcf_list.txt"
metric_outfile = metric_outpath + "all_sample_crosscheck_metrics.txt"


# get list of sample names
samps=os.listdir(bam_dir)

# specify outputs
rule all: 
  input: 
    metric_outfile

# run AddOrReplaceReadGroups on each bam 
rule run_AddOrReplaceReadGroups:
  input:
    infile=infile, 
    bam_dir=bam_dir
  output:
    outfile_bams 
  shell:
    "infile={input.infile};" #sampe ID
    "outfile={input.bam_dir}{wildcards.smp}/{wildcards.smp}_RG.bam;" #file and path to the output (same as input but with _RG.bam)
    "s={wildcards.smp};"
    "gatk AddOrReplaceReadGroups INPUT=$infile OUTPUT=$outfile RGID=$s RGLB=RNAseq RGPL=illumina RGPU=$s RGSM=$s;" 

# index rg bams 
rule run_samtoolsIndex:
  input:
    outfile_bams=outfile_bams,
    bam_dir=bam_dir
  output:
    indexed_bams=indexed_bams
  shell:
    "infile={input.outfile_bams};" #rg bams
    "samtools index $infile;"

# run ExtractFingerprint on each bam
rule run_ExtractFingerprint:
  input: 
    indexed_bams=indexed_bams,
    outfile_bams=outfile_bams,
    vcf_outpath=vcf_outpath
  output: 
    outfile_vcfs
  shell: 
    "infile={input.outfile_bams};" #rg bams
    "outfile={input.vcf_outpath}{wildcards.smp}.vcf;" #fingerprint vcf files 
    "gatk ExtractFingerprint HAPLOTYPE_MAP={haplotype_map} INPUT=$infile OUTPUT=$outfile REFERENCE_SEQUENCE={ref_seq};"

# run CrosscheckFingerprints on all vcf files
rule run_CrosscheckFingerprints:
  input:
    expand(outfile_vcfs, smp=samps)
  output:
    metric_outfile
  shell:
    "path={vcf_path};"
    "ls $path > {vcf_list_path};"
    "gatk CrosscheckFingerprints INPUT={vcf_list_path} HAPLOTYPE_MAP={haplotype_map} OUTPUT={metric_outfile} EXIT_CODE_WHEN_MISMATCH=0;"
