# Labeling the data chunks - We use Dynamic Time Warping for data encoding
library(dtw)

# Dynamic Time Warping Distance to an atom
distanceToAnAtom <- function(atom, sample) {
  y <- as.numeric(as.vector(t(atom[-1])))
  z <- as.vector(t(sample))
  out <- dtw(z, y, distance.only = T)
  out$distance
}

# Find the pattern which is closest to the current epoch using DTW distance
whichCluster <- function(sample, codebook) {
  distances <- apply(codebook, FUN = distanceToAnAtom, sample = sample, MARGIN = 1)
  clusterLabel <- as.character(codebook$Atom[which.min(distances)])
}