
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

source("FUN_BOW_Functions.R")

#Set PID and Chunk Size when the script needs to be run as a standalone

#participantID <- "ADMC021"
#chunksize <- 3

# This is the address of the folder in your computer where participants' accelerometer files are located.
#dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/"

# Window length: indicating each atom has how many seconds of data

if(chunksize == 3)
{
  window.length <- 3 * 10
  dataFolder_windowLength <- "Three-second chunks/"
  
} else if(chunksize == 6) {
  
  window.length <- 6 * 10
  dataFolder_windowLength <- "Six-second chunks/"
}

if(filetype == "Testing_Set")
{
  filedir <- "Downsampled_Files/Testing_Set/"
  outdir <- "Testing_Set/"
  
} else {
  
  filedir <- "Downsampled_Files/Training_Set/"
  outdir <- "Training_Set/"
}



# Load Downsampled Data for one participant

downsampledData.df <- readRDS(file = paste(dataFolder, filedir , participantID, "_downsampled_Data.Rdata", sep = ""))

if(file.exists(paste(dataFolder, "BOW_Files/", dataFolder_windowLength, participantID, "_wrist_BoW.Rdata", sep = "")))
{
  stop("Subsequences for this particpant already created.")
  
} else {
  
  # Constructing bow chunks
  bowChunks.df <- bow.timeSeriesChunks.oneParticipant(participantID = participantID,
                                                      downsampledData.df = downsampledData.df, 
                                                      window.length = window.length)
  
  saveRDS(bowChunks.df, file = paste(dataFolder, "BOW_Files/", dataFolder_windowLength, outdir, participantID, "_wrist_BoW.Rdata", sep = ""))
  
}



