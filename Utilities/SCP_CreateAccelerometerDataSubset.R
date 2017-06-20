
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

source("FUN_Create_Subset_Accelerometer_Data_Files.R")


#Set the full path of the tasktime Rdata file
taskTimesFileName <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

if(!file.exists(taskTimesFileName)) {
  stop("No TaskTimes File Found.") 
} else {
  print ("Tasktimes file found")
}

taskTimes.df <- readRDS(file = taskTimesFileName)

#Set PID when the script needs to be run as a standalone
#participants <- as.factor("GRMC032")

# This is the address of the folder in your computer where participants' accelerometer files are located.
dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/"


#Comment this line when this script is run standalone
participants <- unique(taskTimes.df$PID)

for (participantID in levels(participants)) {
  
  if(length(dir(path = paste(dataFolder,participantID, "/Wrist/", sep = ""), pattern = "^.*csv$")) == 0)
  {
    message(paste("No CSV files present for the Participant :",participantID))
    
  } else if(file.exists(paste(dataFolder, "Original_SubSet/", participantID,"_Subset.Rdata",sep = "")))
  {
    
    message(paste("Skipping Participant as the RData Files for Participant :",participantID," are present."))
    
  } else {
    
    message(paste("Generating Subset Data for Participant : ", participantID))
    
    participant_task.df <- taskTimes.df[which(taskTimes.df$PID == participantID),]
    
    # Loading visit files 
    result_final.df <- read.participant.files(dataFolder, participantID, participant_task.df)
    
    if(nrow(result_final.df)>0) {
      
      #Save final dataframe into a RData File
      saveRDS(result_final.df, file = paste(dataFolder, "Original_SubSet/", participantID,"_Subset.Rdata",sep=""))
      
    } else {
      
      message(paste("No RData File Generated for participant ", participantID))
    }
   
  }
  


}