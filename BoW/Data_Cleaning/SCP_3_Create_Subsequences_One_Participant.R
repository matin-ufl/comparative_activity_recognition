
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

source("FUN_BOW_Functions.R")

#Set PID and Chunk Size when the script needs to be run as a standalone

#participantID <- "DAGO046"
#chunksize <- 3

# This is the address of the folder in your computer where participants' accelerometer files are located.
dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/"

# Window length: indicating each atom has how many seconds of data

if(chunksize == 3)
{
  window.length <- 3 * 10
  dataFolder_windowLength <- "Three-second chunks/"
  
} else if(chunksize == 6) {
  
  window.length <- 6 * 10
  dataFolder_windowLength <- "Six-second chunks/"
}



# Load Downsampled Data for one participant

downsampledData.list <- readRDS(file = paste(dataFolder, "Downsampled_Files/", participantID, "_downsampled_Data.Rdata", sep = ""))

if(file.exists(paste(dataFolder, "BOW_Files/", dataFolder_windowLength, participantID, "_wrist_BoW.Rdata", sep = "")))
{
  stop("Subsequences for this particpant already created.")
  
} else {
  
  # Constructing bow chunks
  bowChunks.df <- bow.timeSeriesChunks.oneParticipant(participantID = participantID,
                                                      ppt.v1.df = downsampledData.list[[1]], 
                                                      ppt.v2.df = downsampledData.list[[2]], 
                                                      ppt.v3.df = downsampledData.list[[3]], 
                                                      ppt.v4.df = downsampledData.list[[4]],
                                                      taskTimes.df = downsampledData.list[[5]],
                                                      window.length = window.length)
  
  saveRDS(bowChunks.df, file = paste(dataFolder, "BOW_Files/", dataFolder_windowLength, participantID, "_wrist_BoW.Rdata", sep = ""))
  
}





