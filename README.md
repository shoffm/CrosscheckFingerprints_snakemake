# crosscheck_fingerprints_pipeline
Pipeline for scaling crosscheck fingerprints for datasets with multiple samples per patient. 

**This is a work in progress.** 

[Crosscheck fingerprints](https://gatk.broadinstitute.org/hc/en-us/articles/360037594711-CrosscheckFingerprints-Picard-) indicates whether two RNA-seq samples come from the same individual.


### 1. Generate a list of sample-sample pairs for Crosscheck Fingerprints input 
Using this [example script](https://github.com/shoffm/crosscheck_fingerprints_pipeline/blob/main/generate_sample_pairs.R). In our study we have 0-5 samples (from distinct time points) per individual. In order to make this analysis computationally efficient, we begin by comparing each sample from an individual only to the first time point from that individual. Not all individuals have the same first time point.

### 2. Run crosscheck fingerprints in an array job (to do) 
