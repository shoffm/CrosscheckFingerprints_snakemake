#!/bin/bash
#BSUB -o cf_sn.stdout
#BSUB -e cf_sn.stderr
#BSUB -J cf_sn
#BSUB -q "long"
#BSUB -R "select[mem>25000] rusage[mem=25000] span[hosts=1]"
#BSUB -M25000

# for running crosscheck with 4000 samples, crosscheck fingerprints job required M330000 and basement queue (254 hours or 10.5 days)
# Job commands
snakemake --latency-wait 90 --jobs 50 --cluster "bsub -o /path/to/output/logfiles -M25000 --jobname={rule}_{wildcards}"
