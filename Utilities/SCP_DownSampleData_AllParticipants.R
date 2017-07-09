#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_DownSampleData_AllParticipants.R

#Script Summary : This script downsamples the subset data from 30 Hz, 80 Hz & 100 Hz to 10 Hz
#                 and saves it into individual Rdata files.

#Author & Reviewer Details -------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings --------------------------------------------------------------------------

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Load the required function R files

source("FUN_Downsampling_Data.R")

# This is the address of the folder in your computer where participants' accelerometer files are located.
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/"

# Original Subset FileList

files <- dir(paste(DATAFOLDER,"Original_SubSet/",sep = ""),  pattern = "^.*Rdata$")

#Data Loading --------------------------------------------------------------------------------------

#Loop through each subset file

for(curr_file in files)
{
  #Store Current ParticipantID
  participantID <- unlist(strsplit(curr_file, "_"))[1]
  
  #Check if the downsampling file already exists
  
  if(file.exists(paste(DATAFOLDER, "Downsampled_Files/", participantID, "_downsampled_Data.Rdata", sep = "")))
  {
    message("Downsampling for this particpant already done.")
  } 
  else 
  {
    #Load subset file for current patient
    
    result_final.df <- readRDS(paste(DATAFOLDER,"Original_SubSet/",curr_file,sep = "")) 
    time_diff <- as.integer(round((as.POSIXct(as.character(unlist(strsplit(result_final.df$Timestamp[2], split = " "))[2]),format="%H:%M:%OS") - 
                                     as.POSIXct(as.character(unlist(strsplit(result_final.df$Timestamp[1], split = " "))[2]),format="%H:%M:%OS")) * 1000)) 
    
    #Checking the sampling rate for each subset file to be 30Hz, 80Hz or 100Hz
    
    if (time_diff %in% c(10,13,34))
    {
      
      message (paste("Starting Downsampling Process for Participant :",participantID))
      downsampled.df <- data.frame(matrix(nrow = 0, ncol = 7))  
      colnames(downsampled.df) <- c("Timestamp", "X", "Y", "Z","timeOnly","VM","TaskLabel")
      
      #Check sampling rate of the acclerometer file
      
      if (time_diff == 10)
      {
        sampling.rate <- 100
      } 
      else if (time_diff == 13)
      {
        sampling.rate <- 80
        
      } 
      else if (time_diff == 34)
      {
        sampling.rate <- 30
      }
      
      taskList <- unique(result_final.df$TaskLabel)
      
#Downsampling Task Data ---------------------------------------------------------------------------
      
      for (curr_task in taskList)
      {
        message(paste("Downsampling for task :",curr_task))
        temp.df <- result_final.df[which(result_final.df$TaskLabel == curr_task),]
        tempout.df <- FUN_Downsample_To_TenHz(temp.df, sampling.rate)
        downsampled.df <- rbind(downsampled.df,tempout.df)
      }

#Saving the Downsampled Data ---------------------------------------------------------------------- 
      
      if(nrow(downsampled.df)>0)
      {
        #Store Downsampled Data into a RData File for a single participant
        saveRDS(downsampled.df, file = paste(DATAFOLDER, "Downsampled_Files/", participantID, "_downsampled_Data.Rdata", sep = ""))
        message(paste("Downsampling Complete for participant:", participantID))
        
      }
      else
      {
        message(paste("No Downsampling Done for current participant", participantID))
        write(paste("No Downsampling Done for current participant:", participantID),file=paste(DATAFOLDER,"Logs/DownsamplingErrorLog.txt",sep=""),append=TRUE)
        
      }
      
    } else {
      
      message(paste("Sampling Rate in the file ",curr_file,"is not 100Hz."))
      write(paste("Sampling Rate in the file ",curr_file,"is not 100Hz."),file=paste(DATAFOLDER,"Logs/SamplingRateErrorLog.txt",sep=""),append=TRUE)
      
    }
  }
}

message("Downsampling successfully completed.")
