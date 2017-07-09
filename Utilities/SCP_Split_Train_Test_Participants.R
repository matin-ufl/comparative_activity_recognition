#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_Split_Train_Test_Participants.R

#Script Summary : This script splits the subset and downsampled data files into Training and 
#                 Testing Set and moves them into their respective folders.

#Author & Reviewer Details -------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings --------------------------------------------------------------------------

#Load the required libraries

library(data.table)

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the full path of the tasktime Rdata file
TASKTIMESFILENAME <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

#Set the folder of the log file
LOGFILEFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Logs/"

#Original and Downsampled Data Directories

DOWNSAMPLEDATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Downsampled_Files/"
ORIGINALDATAFOLDER <-  "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Original_SubSet/"


#Set the Number of Test Set
TESTSETSIZE = 20

# Data Loading ------------------------------------------------------------------------------------------

if(!file.exists(TASKTIMESFILENAME)) {
  stop("No TaskTimes File Found.") 
} else {
  print ("Tasktimes file found")
}

#Load the Tasktimes file

taskTimes.df <- readRDS(file = TASKTIMESFILENAME)


#Downsampled File List
dwnfilelist <- dir(DOWNSAMPLEDATAFOLDER, pattern = "^.*Rdata$")

#Original File List

originalfilelist <- dir(ORIGINALDATAFOLDER, pattern = "^.*Rdata$")

#Participant List
ppts <- levels(taskTimes.df$PID)

#Training and Testing Set Split --------------------------------------------------------------------------

#Selecting 20 Training Participants
set.seed(5855)
test.idx <- sample.int(n = length(ppts), size = TESTSETSIZE)
test.ppts <- sort(ppts[test.idx])
test.ppts

#Copying Files -------------------------------------------------------------------------------------------------------------

#Copying Downsampled Files

for (curr_file in dwnfilelist)
{
  participantID <- unlist(strsplit(curr_file, "_"))[1]
  
  if (participantID %in% test.ppts)
  {
    file.copy(from=paste(DOWNSAMPLEDATAFOLDER,curr_file,sep = ""), to=paste(DOWNSAMPLEDATAFOLDER,"Testing_Set/",sep = ""), 
              copy.mode = TRUE)
  } else {
    
    file.copy(from=paste(DOWNSAMPLEDATAFOLDER,curr_file,sep = ""), to=paste(DOWNSAMPLEDATAFOLDER,"Training_Set/",sep = ""), 
              copy.mode = TRUE)
    
  }
  
  #Remove  the file from the original location after copying
  file.remove(paste(DOWNSAMPLEDATAFOLDER,curr_file,sep = ""))
}

#Copying Original Files
for (curr_file in originalfilelist)
{
  participantID <- unlist(strsplit(curr_file, "_"))[1]
  
  if (participantID %in% test.ppts)
  {
    file.copy(from=paste(ORIGINALDATAFOLDER,curr_file,sep = ""), to=paste(ORIGINALDATAFOLDER,"Testing_Set/",sep = ""), 
              copy.mode = TRUE)
  } else {
    
    file.copy(from=paste(ORIGINALDATAFOLDER,curr_file,sep = ""), to=paste(ORIGINALDATAFOLDER,"Training_Set/",sep = ""), 
              copy.mode = TRUE)
    
  }
  
  #Remove  the file from the original location after copying
  file.remove(paste(ORIGINALDATAFOLDER,curr_file,sep = ""))
  
}

message ("File Copy Completed.")