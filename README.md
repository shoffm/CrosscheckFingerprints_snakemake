# crosscheck_fingerprints_pipeline
Pipeline for scaling crosscheck fingerprints for datasets with multiple samples per patient. 

**This is a work in progress.** 

[Crosscheck fingerprints](https://gatk.broadinstitute.org/hc/en-us/articles/360037594711-CrosscheckFingerprints-Picard-) indicates whether two RNA-seq samples come from the same individual.


## 1. Generate a list of sample-sample pairs for CrosscheckFingerprints input 
Using this [example script](https://github.com/shoffm/crosscheck_fingerprints_pipeline/blob/main/generate_sample_pairs.R). In our study we have 0-5 samples (from distinct time points) per individual. In order to make this analysis computationally efficient, we begin by comparing each sample from an individual only to the first time point from that individual. Not all individuals have the same first time point.

## 2. ExtractFingerprints (in progress) 
This part of the pipeline is run as a snakemake file. There are two steps 
1. AddOrReplaceReadGroups. You'll need a directory of .bam input files
2. ExtractFingerprints. You'll need two files
- Reference sequence used to assemble your genomes
- [Haplotype map](https://github.com/naumanjaved/fingerprint_maps). Can be downloaded from github. **Note:** The header to this file must match the header of your bam files (copy the header of your file and replace the header to the haplotype map file if need be). 

Why Snakemake? 
- Parallelization of independent jobs (i.e. adding read groups and extracting fingerprints) 
- We don't have all of our rna samples sequenced yet. Snakemake is aware of which jobs have been run and will only run jobs that haven't been run before. In this case, we will be able to add .bam files as sample come in, and snakemake will only add read groups and extract fingerprints for the new files without modifying our code. Same will be true for comparisons

See here re: [getting started with snakemake](https://github.com/Snitkin-Lab-Umich/Snakemake_setup)

### To run this pipeline you will need to: 
1. Make and activate the conda environment from the [gatk4_sn.yml](https://github.com/shoffm/crosscheck_fingerprints_pipeline/blob/main/gatk4_sn.yml). Help getting started with conda [here](https://github.com/Snitkin-Lab-Umich/Snakemake_setup#conda).
```
conda env create -f gatk4_sn # do this only once, the first time
conda activate gatk4_sn # do this every time
```
2. Edit the Snakefile to point to the directory holding your bam files, reference sequence adnd haplotype map **TO DO**: add the snakefile and link here
3. Run the script to submit snakemake as a job

## 3. CrosscheckFingerprints (in progress)
