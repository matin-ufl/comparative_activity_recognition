#Script Details ---------------------------------------------------------------------------------------------------

#Script Name : SCP_1_Create_Subsequences_AllParticipants.R

#Script Summary : This script generates the sub-sequences (3s or 6s) from the downsampled data files
#                 and saves it into individual Rdata files. 

#Author & Reviewer Details ----------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ---------------------------------------------------------------------------------------------------

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Load the required function R files

source("FUN_BOW_Functions.R")

#Uncomment the following line and Set selected downsampled filenames when the script needs to be executed
#filelist <- as.factor("ADMC021_downsampled_Data.Rdata")

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set)
CHUNKSIZE <- 3
FILETYPE <- "Testing_Set"

# This is the address of the folder in your computer where participants' accelerometer files are located.

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/"

# Window length: indicating each atom has how many seconds of data

if(CHUNKSIZE == 3)
{
  WINDOW_LENGTH <- 3 * 10
  DATAFOLDER_WINDOWLENGTH <- "Three-second chunks/"
  
} else if(CHUNKSIZE == 6) {
  
  WINDOW_LENGTH <- 6 * 10
  DATAFOLDER_WINDOWLENGTH <- "Six-second chunks/"
}

#Set the directory structure based on the filetype

if(FILETYPE == "Testing_Set")
{
  FILEDIR <- "Downsampled_Files/Testing_Set/"
  OUTDIR <- "Testing_Set/"
  
  #Comment the following line in case only specific files need to be executed
  filelist <- dir(paste(DATAFOLDER,FILEDIR,sep=""), pattern = "^*.*Rdata$")
  
} else if (FILETYPE == "Training_Set") {
  
  FILEDIR <- "Downsampled_Files/Training_Set/"
  OUTDIR <- "Training_Set/"
  
  #Comment the follwoing line in case only specific files need to be executed
  filelist <- dir(paste(DATAFOLDER,FILEDIR,sep=""), pattern = "^*.*Rdata$")
}

#Data Loading --------------------------------------------------------------------------------------------------------------------

for (curr_file in filelist) {
  
  #Store Current ParticipantID
  participantID <- unlist(strsplit(curr_file, "_"))[1]

  # Load Downsampled Data for one participant

  downsampledData.df <- readRDS(file = paste(DATAFOLDER, FILEDIR , participantID, "_downsampled_Data.Rdata", sep = ""))

#Data Sub-sequencing --------------------------------------------------------------------------------------------------------------
  
  if(file.exists(paste(DATAFOLDER, "BOW_Files/", DATAFOLDER_WINDOWLENGTH, participantID, "_wrist_BoW.Rdata", sep = "")))
  {
    stop("Subsequences for this particpant already created.")
  
  } else {
  
    # Constructing bow chunks
    bowChunks.df <- FUN_BOW_TimeSeriesChunks_OneParticipant(participantID = participantID,
                                                      downsampledData.df = downsampledData.df, 
                                                      window.length = WINDOW_LENGTH)

#Saving the sub-sequences data ------------------------------------------------------------------------------------------------------
    
    saveRDS(bowChunks.df, file = paste(DATAFOLDER, "BOW_Files/", DATAFOLDER_WINDOWLENGTH, OUTDIR, 
                                       participantID, "_wrist_BoW.Rdata", sep = ""))
  
  }
}

message(paste(CHUNKSIZE,"seconds data sub-sequencing completed successfully for",FILETYPE,"."))
