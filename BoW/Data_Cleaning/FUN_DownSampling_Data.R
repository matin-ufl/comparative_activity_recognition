


# Our accelerometer files either have 30 Hz , 80 or 100 Hz sampling rates.
# Therefore, this function only checks for these three cases.
find.samplingRate <- function(visit.df) {
  samplingRate <- 30
  if((visit.df$timeOnly[1] == visit.df$timeOnly[80]) & (visit.df$timeOnly[80] != visit.df$timeOnly[81])) {
    samplingRate <- 80
  }
  else if(visit.df$timeOnly[1] == visit.df$timeOnly[100]) {
    samplingRate <- 100
  }
  samplingRate
}

# Since more than 10 Hz is unnecessary for human movement, we downsample all the accelerometer files to 10 Hz.
downSampleToTenHz <- function(visit.df, sampling.rate = 100) {
  newSampleCount <- floor(nrow(visit.df) / (sampling.rate / 10))
  keys <- sapply(1:newSampleCount, FUN = function(x) {rep(x, (sampling.rate / 10))})
  keys <- matrix(keys, ncol = 1)
  if(nrow(keys) < nrow(visit.df)) {
    keys <- rbind(keys, matrix(rep(newSampleCount + 1, (nrow(visit.df) - length(keys))), ncol = 1))
  }
  visit.df$keys <- keys
  result.df <- visit.df
  result.df[, c("Timestamp", "X", "Y", "Z", "VM", "timeOnly") := list(Timestamp[1], mean(X, na.rm = T), mean(Y, na.rm = T), mean(Z, na.rm = T), mean(VM, na.rm = T), timeOnly[1]), by = keys]
  result.df[, keys := NULL]
  result.df <- result.df[seq(1, nrow(result.df), by = sampling.rate / 10), ]
}