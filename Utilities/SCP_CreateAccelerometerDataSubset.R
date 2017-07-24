#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_CreateAccelerometerDataSubset.R

#Script Summary : This script creates a subset of the original accelerometer data based on 
#                 the task timestamp ranges and saves it to individual files.

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

#Load the Function R Files
source("FUN_Create_Subset_Accelerometer_Data_Files.R")


#Set the full path of the tasktime Rdata file
TASKTIMESFILENAME <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

if(!file.exists(TASKTIMESFILENAME)) {
  stop("No TaskTimes File Found.") 
} else {
  print ("Tasktimes file found")
}

#Uncomment the following line when the script is run standalone for specific patients
#participants <- as.factor("ADAD151")

# This is the address of the folder in your computer where participants' accelerometer files are located.
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/"

# Data Loading and Subsetting-------------------------------------------------------------------------------

taskTimes.df <- readRDS(file = TASKTIMESFILENAME)

#Comment the following line when this script is run standalone for specific patients
participants <- unique(taskTimes.df$PID)

for (participantID in levels(participants)) {
  
  if(length(dir(path = paste(DATAFOLDER,participantID, "/Wrist/", sep = ""), pattern = "^.*csv$")) == 0)
  {
    message(paste("No CSV files present for the Participant :",participantID))
    
  } else if(file.exists(paste(DATAFOLDER, "Original_SubSet/", participantID,"_Subset.Rdata",sep = "")))
  {
    
    message(paste("Skipping Participant as the RData Files for Participant :",participantID," are present."))
    
  } else {
    
    message(paste("Generating Subset Data for Participant : ", participantID))
    
    participant_task.df <- taskTimes.df[which(taskTimes.df$PID == participantID),]
    
    # Loading visit files 
    
    result_final.df <- FUN_Read_Participant_Files(DATAFOLDER, participantID, participant_task.df)

# Saving the Subset Data----------------------------------------------------------------------------------------------------
    
    if(nrow(result_final.df)>0) {
      
      #Save final dataframe into a RData File
      
      saveRDS(result_final.df, file = paste(DATAFOLDER, "Original_SubSet/", participantID,"_Subset.Rdata",sep=""))
      
    } else {
      
      message(paste("No RData File Generated for participant ", participantID))
    }
   
  }
  

}

message("Data sub-setting completed successfully.")