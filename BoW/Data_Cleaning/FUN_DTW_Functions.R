#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : FUN_DTW_Functions.R

#Script Summary : 
#       This script contains two functions required for Dynamic Time Warping (DTW) Calculations.
#         1. FUN_DistanceToAnAtom : Function to calculate the distance of a vector to an Atom.
#         2. FUN_WhichCluster : Function to generate cluster labels for a each ppt-task vector.

#Author & Reviewer Details ------------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu


# Load the dtw library
library(dtw)



# FUN_DistanceToAnAtom
FUN_DistanceToAnAtom <- function(atom, sample) {
  
  # Input :- 
  #       1. atom : Codebook Atom Vector
  #       2. sample : Sub-sequence Data Vector
  # Output :- 
  #       1. out$distance : The distance between the atom and the sample vectors.
  
  y <- as.numeric(as.vector(t(atom[-1])))
  z <- as.vector(t(sample))
  out <- dtw(z, y, distance.only = T)
  out$distance
}



# FUN_WhichCluster
FUN_WhichCluster <- function(sample, codebook.df) {
  # Input :- 
  #       1. codebook.df : Codebook DataFrame
  #       2. sample : Sub-sequence Data Vector
  # Output :- 
  #       1. clusterLabel : The cluster label for the sample vector.
  
  distances <- apply(codebook.df, FUN = FUN_DistanceToAnAtom, sample = sample, MARGIN = 1)
  clusterLabel <- as.character(codebook.df$Atom[which.min(distances)])
}