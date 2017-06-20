library(data.table)

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

#Set the full path of the tasktime Rdata file
taskTimesFileName <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

#Set the folder of the log file
logfileFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/Logs/"

if(!file.exists(taskTimesFileName)) {
  stop("No TaskTimes File Found.") 
} else {
  print ("Tasktimes file found")
}

#Load the Tasktimes file

taskTimes.df <- readRDS(file = taskTimesFileName)

#Original and Downsampled Data Directories

downsampledataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/Downsampled_Files/"
originaldataFolder <-  "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/Original_SubSet/"

#Downsampled File List
dwnfilelist <- dir(downsampledataFolder, pattern = "^.*Rdata$")

#Original File List

originalfilelist <- dir(originaldataFolder, pattern = "^.*Rdata$")

#Participant List
ppts <- levels(taskTimes.df$PID)

#Selecting 20 Training Participants
set.seed(5855)
test.idx <- sample.int(n = length(ppts), size = 20)
test.ppts <- sort(ppts[test.idx])
test.ppts

#Copying Downsampled Files
for (curr_file in dwnfilelist)
{
  participantID <- unlist(strsplit(curr_file, "_"))[1]
  
  if (participantID %in% test.ppts)
  {
    file.copy(from=paste(downsampledataFolder,curr_file,sep = ""), to=paste(downsampledataFolder,"Testing_Set/",sep = ""), 
              copy.mode = TRUE)
  } else {
    
    file.copy(from=paste(downsampledataFolder,curr_file,sep = ""), to=paste(downsampledataFolder,"Training_Set/",sep = ""), 
              copy.mode = TRUE)
    
  }
}

#Copying Original Files
for (curr_file in originalfilelist)
{
  participantID <- unlist(strsplit(curr_file, "_"))[1]
  
  if (participantID %in% test.ppts)
  {
    file.copy(from=paste(originaldataFolder,curr_file,sep = ""), to=paste(originaldataFolder,"Testing_Set/",sep = ""), 
              copy.mode = TRUE)
  } else {
    
    file.copy(from=paste(originaldataFolder,curr_file,sep = ""), to=paste(originaldataFolder,"Training_Set/",sep = ""), 
              copy.mode = TRUE)
    
  }
}

message ("File Copy Completed.")