#!/bin/bash
#BSUB -o cf_sn.stdout
#BSUB -e cf_sn.stderr
#BSUB -J cf_sn
#BSUB -q "long"
#BSUB -R "select[mem>25000] rusage[mem=25000] span[hosts=1]"
#BSUB -M25000

# Job commands
snakemake --latency-wait 90 --jobs 50 --cluster "bsub -o /path/to/output/logfiles -M25000 --jobname={rule}_{wildcards}"
