#Script Details -------------------------------------------------------------------------------------------------

#Script Name : SCP_Master_Script.R

#Script Summmary : Constructs unigram and bigram features for given dataset 
#                  and saves the corresponding feature data files

#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Madhurima Nath
#Date : 07/11/2017
#E-Mail : madhurima09@ufl.edu
#Reviewed By : Shikha Mehta
#Review Date : 
#Reviewer E-Mail : shikha.mehta@ufl.edu

#----------------------------------------------------------------------------------------------------------------

#Parameter Settings----------------------------------------------------------------------------------------------

# Set the full path where participants' Rdata files are located
TRAININGDATAFOLDER <- "/home/sumi/Documents/Research_Project/Participant_Data/Training_Data/"
# Set the full path where test set Rdata file is located
TESTINGDATAFOLDER <- "/home/sumi/Documents/Research_Project/Participant_Data/Test_Data/"

DATAFOLDER <- "/home/sumi/Documents/Research_Project/Participant_Data/R_DataFiles/"

library("reshape") 
require(plyr)

# Set the working directory to the location where the scripts and function R files are located
setwd("/home/sumi/Documents/Research_Project/Scripts/")

#----------------------------------------------------------------------------------------------------------------

source("DTWFeatureConstruction.R")
trainParticipantsList <- dir(TRAININGDATAFOLDER, pattern = "^.*.Rdata$")
testParticipantsList <- dir(TESTINGDATAFOLDER, pattern = "^.*.Rdata$")

dtw.df <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
ddtw.df <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)

for(test in testParticipantsList)
{
  for(participantFile in trainParticipantsList) {
    
    # Retrieve participant ID from file name
    participantID <- strsplit(participantFile, "_")[[1]][[1]]
    
    # Load Rdata file for the current participant
    participantWristData.df <- readRDS(file = paste(DATAFOLDER, participantFile, sep = ""))
    print (paste("Data successfully loaded for Participant: ",participantID))
    
    # Call function to construct features from current participant's data
    participantDTWFeatures.df <- DTWFeature.OneParticipant(test,participantWristData.df)
    participantDDTWFeatures.df <- DDTWFeature.OneParticipant(test,participantWristData.df)
    
    dtw.df <- rbind.fill(dtw.df, participantFeatures.df)
    ddtw.df <- rbind.fill(ddtw.df, participantFeatures.df)

    print (paste("Merged features for Participant: ",participantID))
    
  }
}

saveRDS(dtw.df, file = paste(DATAFOLDER, "dtwFeatures.Rdata", sep = ""))
saveRDS(ddtw.df, file = paste(DATAFOLDER, "ddtwFeatures.Rdata", sep = ""))

