## This is an example script of how to generate a list of sample pairs for Crosscheck Fingerprints
## Crosscheck fingerprints (https://gatk.broadinstitute.org/hc/en-us/articles/360037594711-CrosscheckFingerprints-Picard-) indicates whether two samples come from the same individual
## In our study we have 0-5 samples per individual
## In order to make this analysis computationally efficient, we begin by comparing each sample from an individual only to the first time point from that individual
## Not all individuals have the same first time point 

## Example data
Patient_ID <- c('A', 'A', 'A', 'A', 'B', 'B', 'B', 'C', 'C')
Sample_ID <- c('01', '02', '03', '04', '05', '06', '07', '08', '09')
Sample_Timepoint <- c('01 week', '02 week', '05 week', '10 week', '01 week', '02 week', '05 week', '05 week', '10 week') # it is imperative that time point names are alphabetically or numerically sequential

Manifest <- data.frame(cbind(Patient_ID, Sample_ID, Sample_Timepoint))
Manifest

# load tidyverse
library(tidyverse) 

# dplyr approach 
Sample_pair_list <- Manifest %>% arrange(Patient_ID, Sample_Timepoint) %>% group_by(Patient_ID) %>% 
  mutate(Comp_Sample_ID = first(Sample_ID), Comp_Sample_Timepoint = first(Sample_Timepoint)) %>% ungroup() %>%
  filter(Sample_ID != Comp_Sample_ID) %>% select(Sample_ID, Comp_Sample_ID)
Sample_pair_list

# write out the list as a tsv file
write.table(Sample_pair_list, file = '/path/to/your/directory/cf-rna-sample-pairs-info.tsv', 
            sep="\t", row.names = FALSE, quote = FALSE)

## More complex pairs-based approach if that is helpful

# # Generate a list of all pairs of samples 
# # Order by patient and within patient, time point, remove time point variable 
# Manifest_sub <- Manifest %>% arrange(Patient_ID, Sample_Timepoint) %>% select(Patient_ID, Sample_ID)
# # Generate a matrix of which samples come from the same individual 
# pairs <- crossprod(table(Manifest_sub))
# # Set the top half of this matrix (including the diagonal) to 0 to ensure each pair is only counted once (and samples paired with the same sample are eliminated)
# pairs[upper.tri(pairs, diag = TRUE)] <-0 
# # Make this matrix into a list
# all_pairs_list <- subset(as.data.frame.table(pairs), Freq > 0)
# # Rename columns
# colnames(all_pairs_list) <- c("Sample2", 'Sample1')
# # Remove frequency column 
# all_pairs_list <- all_pairs_list %>% select(-3)
# 
# # make a list of first time point for each individual 
# patient_first_sample <- Manifest %>% group_by(Patient_ID) %>% arrange(Sample_Timepoint) %>% filter(row_number()==1) %>% select(Sample_ID, Patient_ID)
# 
# # only keep rows in pair list where the sample2 value is in the list of first sample per patient 
# pairs_list <- all_pairs_list %>% filter(Sample1 %in% patient_first_sample$Sample_ID)
