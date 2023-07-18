## Generalized Example code for CrosscheckFingerprints output check 

library(tidyverse)

# CrosscheckFingerprints metric output will contain the following colnames: 
# [1] "LEFT_GROUP_VALUE"                 "RIGHT_GROUP_VALUE"                "RESULT"                           "DATA_TYPE"                       
# [5] "LOD_SCORE"                        "LOD_SCORE_TUMOR_NORMAL"           "LOD_SCORE_NORMAL_TUMOR"           "LEFT_RUN_BARCODE"                
# [9] "LEFT_LANE"                        "LEFT_MOLECULAR_BARCODE_SEQUENCE"  "LEFT_LIBRARY"                     "LEFT_SAMPLE"                     
# [13] "LEFT_FILE"                        "RIGHT_RUN_BARCODE"                "RIGHT_LANE"                       "RIGHT_MOLECULAR_BARCODE_SEQUENCE"
# [17] "RIGHT_LIBRARY"                    "RIGHT_SAMPLE"                     "RIGHT_FILE"                      

# For the purposes of this investigation, we will work with a subset of these variables. 
# To make your input match our format, simply read in your CrosscheckFingerprint metric file 
# and filter to the relevant columns using the command: 
#crosscheck_metrics <- read_delim('/path/to/your/metric_file.txt', delim = '\t', skip = 6) %>%  select(LEFT_SAMPLE, RIGHT_SAMPLE, RESULT)

# the following is an example of how to compare CrosscheckFingerprints output to your expected sample pairs to infer sample swaps on toy data

# crosscheck_metrics should look something like this df
LEFT_SAMPLE <- c("01", "02", "03", "04", "05", "06", "01", "02", "03", "04", "05", "06", "01", "02", "03", "04", "05", "06", "01", "02", "03", "04", "05", "06", "01", "02", "03", "04", "05", "06", "01", "02", "03", "04", "05", "06")
RIGHT_SAMPLE <- c("01", "01", "01", "01", "01", "01", "02", "02", "02", "02", "02", "02", "03", "03", "03", "03", "03", "03", "04", "04", "04", "04", "04", "04", "05", "05", "05", "05", "05", "05", "06", "06", "06", "06", "06", "06")
RESULT <- c("EXPECTED_MATCH", "UNEXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "UNEXPECTED_MATCH", 
            "EXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", 
            "EXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "UNEXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", 
            "EXPECTED_MATCH", "UNEXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "UNEXPECTED_MATCH", 
            "EXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", "UNEXPECTED_MATCH", "EXPECTED_MISMATCH", "EXPECTED_MISMATCH", 
            "EXPECTED_MATCH" )
crosscheck_metrics <- data.frame(cbind(LEFT_SAMPLE, RIGHT_SAMPLE, RESULT))
crosscheck_metrics

# patient ID/sample ID/sample timepoint data should be in the format of the following example: 
Patient_ID <- c('A', 'A', 'B', 'B', 'C', 'C')
Sample_ID <- c('01', '02', '03', '04', '05', '06')
Sample_Timepoint <- c('01 week', '02 week', '01 week', '02 week', '01 week', '02 week') # it is imperative that time point names are alphabetically or numerically sequential
Manifest <- data.frame(cbind(Patient_ID, Sample_ID, Sample_Timepoint))
Manifest

# now we compare the output to the expectation: 

# first by matching LEFT_SAMPLE and creating a LEFT_SAMPLE_ID & LEFT_SAMPLE_taken_at
metric_check <- crosscheck_metrics %>% 
  left_join(Manifest, by = c("LEFT_SAMPLE"="Sample_ID")) %>% 
  rename(LEFT_SAMPLE_PT_ID = Patient_ID, LEFT_SAMPLE_taken_at = Sample_Timepoint) %>%
  # second by matching RIGHT_SAMPLE and creating a RIGHT_SAMPLE_ID & RIGHT_SAMPLE_taken_at
  left_join(Manifest, by = c("RIGHT_SAMPLE"="Sample_ID")) %>% 
  rename(RIGHT_SAMPLE_PT_ID = Patient_ID, RIGHT_SAMPLE_taken_at = Sample_Timepoint) %>%
  # make a new column that says whether RIGHT_SAMPLE_ID == LEFT_SAMPLE_ID (EXPECTED_MATCH, etc.)
  # we won't expect a result of any unexpected mismatches because that would be if reads within the same sample were from different individuals
  mutate(OUR_RESULT = ifelse(LEFT_SAMPLE == RIGHT_SAMPLE, "EXPECTED_MATCH", ifelse(LEFT_SAMPLE_PT_ID == RIGHT_SAMPLE_PT_ID, "UNEXPECTED_MATCH", "EXPECTED_MISMATCH")), FLAG = ifelse(RESULT != OUR_RESULT, "FLAG", "OK")) 
# this will filter the joined dataframe only to sample pairs that don't match our expectation
investigate_flags <- metric_check %>% filter(FLAG == "FLAG") %>% 
  mutate(first_sample = ifelse(LEFT_SAMPLE > RIGHT_SAMPLE, LEFT_SAMPLE, RIGHT_SAMPLE),
         second_sample = ifelse(LEFT_SAMPLE > RIGHT_SAMPLE, RIGHT_SAMPLE, LEFT_SAMPLE)) %>% distinct(first_sample, second_sample, .keep_all = TRUE) %>% select(-first_sample, -second_sample)
investigate_flags

# interpreting this output: 
# There are 3 things going on with 3 different patients
# - patient A has 2 samples that match up (therefore these samples don't appear in investigate_flags)
# - patient B has 2 samples that don't match by CrosscheckFingerprints result 
# - patient C has 2 samples that don't match by CrosscheckFingerprints result
# CrosscheckFingerprints found two unexpected matches between samples (06, 03) and (04, 05)
# From this we can infer that there was a sample swap between patients B and C... 
