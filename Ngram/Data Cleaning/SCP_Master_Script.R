#Script Details -------------------------------------------------------------------------------------------------

#Script Name : SCP_Master_Script.R

#Script Summmary : Constructs unigram and bigram features for given dataset 
#                  and saves the corresponding feature data files

#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Shikha Mehta
#Date : 07/08/2017
#E-Mail : shikha.mehta@ufl.edu
#Reviewed By : Madhurima Nath
#Review Date : 
#Reviewer E-Mail : madhurima09@ufl.edu

#----------------------------------------------------------------------------------------------------------------

#Parameter Settings----------------------------------------------------------------------------------------------

# Set the full path where participants' Rdata files are located
DATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Raw Data/Participant Data/Training_Set/"
# Set the number of bins to use for binning participant data
NUMBEROFBINS <- 10

# Set the working directory to the location where the scripts and function R files are located
setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/DataCleanUp")

#----------------------------------------------------------------------------------------------------------------

source("FUN_Construct_Ngrams.R")
participantsList <- dir(DATAFOLDER, pattern = "^.*.Rdata$")
UnigramFeatures.df <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
BigramFeatures.df <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
for(participantFile in participantsList) {
  
  # Retrieve participant ID from file name
  participantID <- strsplit(participantFile, "_")[[1]][[1]]
  
  # Load Rdata file for the current participant
  participantWristData.df <- readRDS(file = paste(DATAFOLDER, participantFile, sep = ""))
  print (paste("Data successfully loaded for Participant: ",participantID))
  
  # Call function to construct features from current participant's data
  participantFeatures.df <- FUN_nGrams.oneParticipant(participantID = participantID,ppt.df = participantWristData.df,binCount=NUMBEROFBINS)
  
  # Merge participant features to the main data frame
  UnigramFeatures.df <- rbind.fill(UnigramFeatures.df, participantFeatures.df[[1]])
  BigramFeatures.df <- rbind.fill(BigramFeatures.df, participantFeatures.df[[2]])
  print (paste("Merged features for Participant: ",participantID))
}

# Preprocess the combined features data
UnigramFeatures.df<-FUN_adjustFeatureSet(UnigramFeatures.df)
BigramFeatures.df<-FUN_adjustFeatureSet(BigramFeatures.df)

# Save the ngram feature files
saveRDS(UnigramFeatures.df, file = paste(DATAFOLDER, "nGram_Files/UnigramFeatures.Rdata", sep = ""))
saveRDS(BigramFeatures.df, file = paste(DATAFOLDER, "nGram_Files/BigramFeatures.Rdata", sep = ""))
