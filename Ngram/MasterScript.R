# Master Script: Construct unigram and bigram features for all the participants and save the aggregate Rdata files

# Set the full path where participants' Rdata files are located.
dataFolder <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Testing_Set/"

# Set the working directory to the location where the scripts and function R files are located
setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/DataCleanUp")

source("ConstructNgramsForParticipant.R")
participantsList <- dir(dataFolder, pattern = "^.*.Rdata$")
UnigramFeatures.df <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
BigramFeatures.df <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
for(participantFile in participantsList) {
  
  # Retrieve participant ID from file name
  participantID <- strsplit(participantFile, "_")[[1]][[1]]
  
  # Load Rdata file for the current participant
  participantWristData <- readRDS(file = paste(dataFolder, participantFile, sep = ""))
  print (paste("Data successfully loaded for Participant: ",participantID))
  
  # Call function to construct features from current participant's data
  participantFeatures.df <- nGrams.oneParticipant(participantID = participantID,ppt.df = participantWristData)
  
  # Merge participant features to the main data frame
  UnigramFeatures.df <- rbind.fill(UnigramFeatures.df, participantFeatures.df[[1]])
  BigramFeatures.df <- rbind.fill(BigramFeatures.df, participantFeatures.df[[2]])
  print (paste("Merged features for Participant: ",participantID))
}

# Update all NAs to 0 and save the ngram feature files
UnigramFeatures.df[is.na(UnigramFeatures.df)] <- 0
BigramFeatures.df[is.na(BigramFeatures.df)] <- 0
save(UnigramFeatures.df, file = paste(dataFolder, "nGram_Files/UnigramFeatures.Rdata", sep = ""))
save(BigramFeatures.df, file = paste(dataFolder, "nGram_Files/BigramFeatures.Rdata", sep = ""))
