
# Since more than 10 Hz is unnecessary for human movement, we downsample all the accelerometer files to 10 Hz.
downSampleToTenHz <- function(visit.df, sampling.rate = 100) {
  
  
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