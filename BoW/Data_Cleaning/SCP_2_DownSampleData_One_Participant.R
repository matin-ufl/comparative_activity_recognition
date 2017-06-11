
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

source("FUN_Read_Accelerometer_Data_Files.R")
source("FUN_DownSampling_Data.R")

#Set PID when the script needs to be run as a standalone
#participantID <- "TALI002"

# This is the address of the folder in your computer where participants' accelerometer files are located.
dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/"

if(file.exists(paste(dataFolder, "Downsampled_Files/", participantID, "_downsampled_Data.Rdata", sep = "")))
{
  stop("Downsampling for this particpant already done.")
}

#Set the full path of the tasktime Rdata file
taskTimesFileName <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

if(!file.exists(taskTimesFileName)) {
  stop("No TaskTimes File Found.") 
} else {
  print ("Tasktimes file found")
}

taskTimes.df <- readRDS(file = taskTimesFileName)

# Loading visit files 
data.files <- read.participant.files(dataFolder, participantID)
data.files[[5]] <- taskTimes.df[which(taskTimes.df$PID == participantID),]

# Find Sampling Rate and Downsample Data into dataframe

# Downsample to 10 Hz
options(warn = -1)
for(i in 1:4) {
    if(!is.na(data.files[[i]])) {
       sampling.rate <- find.samplingRate(data.files[[i]])
       print(sampling.rate)
       data.files[[i]] <- downSampleToTenHz(data.files[[i]], sampling.rate)
 }
}

#Store Downsampled Data into a RData File for a single participant

saveRDS(data.files, file = paste(dataFolder, "Downsampled_Files/", participantID, "_downsampled_Data.Rdata", sep = ""))

