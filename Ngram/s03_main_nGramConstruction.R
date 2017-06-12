# The main script --------------------------------------------------------------------------------
# construct Ngram features for each participant and save into a Rdata file

# This is the address of the folder in your computer where participants' accelerometer files are located.
dataFolder <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Participant Data/"

setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/DataCleanUp")

# To obtain MET scores (energy expenditure) for each task, we have to read 'cosmed_mets.csv' file.
# cosmed.df <- read.csv(file = paste(dataFolder, "../cosmed_mets.csv", sep = ""))

#Set the full path of the tasktime Rdata file
taskTimesFileName <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/DataCleanUp/taskTimes_all.Rdata"
taskTimes.df <- readRDS(file = taskTimesFileName)
message("Tasktimes file found and read.")

source("f03_nGram_one_participant.R")

for(participantID in unique(taskTimes.df$PID))
{
  # Loading visit files 
  data.files <- read.participant.files(dataFolder, participantID)
  
  # Constructing features
  nGramFeatures.df <- nGram.oneParticipant(participantID = participantID,
                                           cosmed.df = cosmed.df,
                                           ppt.v1.df = data.files[[1]], ppt.v2.df = data.files[[2]], ppt.v3.df = data.files[[3]], ppt.v4.df = data.files[[4]],
                                           taskTimes.df = taskTimes.df[taskTimes.df$PID == participantID,])
  
  save(nGramFeatures.df, file = paste(dataFolder, "nGram_Files/", participantID, "_wrist_features.Rdata", sep = ""))
  
}