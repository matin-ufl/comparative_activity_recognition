# ___________________________________________________
# Functions for calculating statistical summaries.
#
# ____________________
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)
# ___________________________________________________


# This function receives a transformed vector and produces an informative data.frame for analysis.
# Example:
#     freq.df <- convrt.fft(fft(VM)) 
convert.fft <- function(cs, sample.rate = 10) {
     cs <- cs / length(cs) # normalize
     
     distance.center <- function(c) signif(Mod(c), 4)
     angle           <- function(c) signif(180 * Arg(c) / pi, 3)
     
     df <- data.frame(cycle    = 0:(length(cs)-1),
                      freq     = 0:(length(cs)-1) * sample.rate / length(cs),
                      strength = sapply(cs, distance.center),
                      delay    = sapply(cs, angle))
     df
}

# Receives vector magnitude and converts it to frequency domain. Then calculates the fraction of power covered by 0.6 Hz to 2.5 Hz.
p625 <- function(VM, sample.rate = 10) {
     VM_freq <- convert.fft(fft(VM), sample.rate)
     VM_freq <- VM_freq[-(ceiling(nrow(VM_freq)/2):nrow(VM_freq)), ]
     idx0_6 <- min(which(signif(VM_freq$freq, digits = 1) == 0.6))
     idx2_5 <- min(which(signif(VM_freq$freq, digits = 2) == 2.5))
     result <- sum(VM_freq$strength[idx0_6:idx2_5]) / sum(VM_freq$strength[2:(nrow(VM_freq)-1)])
     result
}

# Receives vector magnitude and converts it to frequency domain. Find the dominant frequency.
df <- function(VM, sample.rate = 10) {
     VM_freq <- convert.fft(fft(VM), sample.rate)
     VM_freq <- VM_freq[-(ceiling(nrow(VM_freq)/2):nrow(VM_freq)), ]
     temp_idx <- min(which(VM_freq$strength == max(VM_freq$strength[2:length(VM_freq$strength)])))
     if(length(temp_idx) > 0) {
          idx_max <- temp_idx
     }
     result <- VM_freq$freq[idx_max]
     
     result
}

# Converts the given vector magnitude and finds the dominant frequency. Returns the fraction of power covered by DF.
fpdf <- function(VM, sample.rate = 10) {
     VM_freq <- convert.fft(fft(VM), sample.rate)
     VM_freq <- VM_freq[-(ceiling(nrow(VM_freq)/2):nrow(VM_freq)), ]
     
     idx_max <- which(VM_freq$strength == max(VM_freq$strength[2:length(VM_freq$strength)]))
     indices <- which(round(VM_freq$freq, digits = 1) == round(VM_freq$freq[idx_max], digits = 1))
     result <- sum(VM_freq$strength[indices]) / sum(VM_freq$strength[2:(nrow(VM_freq))])
     
     result
}

# Returns the average angle between the vertical axis and the vector magnitude.
mangle <- function(x, VM) {
     angle <- (90 * asin(x / VM)) / (pi/2)
     result <- mean(angle, na.rm = T)
     result
}

# Returns the standard deviation of the angle between the vertical axis and the vector magnitude.
sdangle <- function(x, VM) {
     angle <- (90 * asin(x / VM)) / (pi/2)
     result <- sd(angle, na.rm = T)
     result
}

# Average of vector magnitude.
mvm <- function(VM) {
     result <- mean(VM, na.rm = T)
     result
}

# Standard deviation of vector magnitude.
sdvm <- function(VM) {
     result <- sd(VM)
     result
}