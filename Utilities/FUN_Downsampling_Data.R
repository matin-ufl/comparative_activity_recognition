#Script Details -------------------------------------------------------------------------------------

#Script Name : FUN_Downsampling_Data.R

#Script Summary : 
#       This script contains one function required to read raw accelerometer files.
#         1. FUN_Downsample_To_TenHz : Function to downsample raw accelerometer files to 10 Hz. 

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date :
#Reviewer E-Mail : hiranava@ufl.edu



#FUN_Downsample_To_TenHz

FUN_Downsample_To_TenHz <- function(visit.df, sampling.rate = 100) {
  
  # Input:
  #     1. visit.df: the accelerometer dataframe of the subset data
  #     2. sampling.rate: accelerometer data sampling rate
  # Output:
  #     1. result.df: output dataframe with entire downsampled accelerometer data.
  
  
  #Set the sampling factors for different sampling rates (30Hz, 80Hz and 100Hz)
  
  if (sampling.rate == 100)
  {
    sampling.factor <-10
    
  } else if (sampling.rate == 80)
  {
    sampling.factor <-8
  }else if (sampling.rate == 30)
  {
    sampling.factor <-3
  }
  
  newSampleCount <- floor(nrow(visit.df) / (sampling.rate / sampling.factor))
  keys <- sapply(1:newSampleCount, FUN = function(x) {rep(x, (sampling.rate / sampling.factor))})
  keys <- matrix(keys, ncol = 1)
  if(nrow(keys) < nrow(visit.df)) {
    keys <- rbind(keys, matrix(rep(newSampleCount + 1, (nrow(visit.df) - length(keys))), ncol = 1))
  }
  visit.df$keys <- keys
  result.df <- visit.df
  result.df[, c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel") := list(Timestamp[1], mean(X, na.rm = T), mean(Y, na.rm = T), mean(Z, na.rm = T), timeOnly[1], mean(VM, na.rm = T),TaskLabel[1]), by = keys]
  result.df[, keys := NULL]
  result.df <- result.df[seq(1, nrow(result.df), by = sampling.rate / sampling.factor), ]
}
