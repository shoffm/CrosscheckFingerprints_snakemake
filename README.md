# crosscheck_fingerprints_pipeline
Pipeline for scaling crosscheck fingerprints for datasets with multiple samples per patient. 

**This is a work in progress.** 

[Crosscheck fingerprints](https://gatk.broadinstitute.org/hc/en-us/articles/360037594711-CrosscheckFingerprints-Picard-) indicates whether two RNA-seq samples come from the same individual.

## 1. ExtractFingerprints (in progress) 
This part of the pipeline is run with snakemake. Help getting started with snakemake [here](https://github.com/Snitkin-Lab-Umich/Snakemake_setup).

Why snakemake? 
- Parallelization of independent jobs (i.e. adding read groups and extracting fingerprints) 
- Snakemake is aware of which jobs have been run (read: if job output exists in the correct location) and will only run jobs that haven't been run before (read: don't have existing output in the correct location). For this project, we don't have all of our rna samples sequenced yet. In this case, we will be able to add bam files as samples are sequenced and rerun the snakemake pipeline. Snakemake will only do the jobs in the Snakefile (add read groups and extract fingerprints) for the new files without modifying our code. Same will be true for comparisons later... 

### To run this pipeline you will need to: 
### 1.1. Activate conda environment
Make and activate the conda environment from the [gatk4_sn.yml](https://github.com/shoffm/crosscheck_fingerprints_pipeline/blob/main/gatk4_sn.yml). Help getting started with conda [here](https://github.com/Snitkin-Lab-Umich/Snakemake_setup#conda).
```
conda env create -f gatk4_sn # do this only once, the first time
conda activate gatk4_sn # do this every time
```
### 1.2. Edit Snakefile
In the Snakefile there are two steps 
1. `AddOrReplaceReadGroups` You'll need a directory of .bam input files
2. `ExtractFingerprints` You'll need two files
- Reference sequence used to assemble your genomes (i.e. `Homo_sapiens.GRCh38.dna.primary_assembly.fa`) 
- [Haplotype map](https://gatk.broadinstitute.org/hc/en-us/articles/360035531672-Haplotype-map-format). Can be downloaded from [github](https://github.com/naumanjaved/fingerprint_maps). **Note:** The header to this file must match the header of your bam files (copy the header of your file and replace the header to the haplotype map file if need be). 

**Edit** the [Snakefile](https://github.com/shoffm/crosscheck_fingerprints_pipeline/blob/main/Snakefile) to point to the directory with your bam files, reference sequence adnd haplotype map

### 1.3. Submit snakemake job 
Run the script to submit snakemake as a job ## TO DO: add this 

## 2. CrosscheckFingerprints (in progress)
### 2.1. Generate a list of sample-sample pairs for CrosscheckFingerprints input 
Using this [example script](https://github.com/shoffm/crosscheck_fingerprints_pipeline/blob/main/generate_sample_pairs.R). In our study we have 0-5 samples (from distinct time points) per individual. In order to make this analysis computationally efficient, we begin by comparing each sample from an individual only to the first time point from that individual. Not all individuals have the same first time point.
