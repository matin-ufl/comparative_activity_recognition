#This script converts the taskTimes_all.csv file into taskTimes_all.Rdata file 
#by including only the necessary columns required for the analysis


#Set the working directory to the loaction where this script is located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

#Load the function file

source("FUN_ConvertToMilitaryTime.R")

#Set the directory to the location where the taskTimes_all.csv file is located

dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/"

taskTimesFileName <- paste(dataFolder,"taskTimes_all.csv", sep = "")
  
#Check if the file exists in the given directory. 

if(!file.exists(taskTimesFileName)) {
  stop("No TaskTimes csv file found.") 
} else {
  print ("Tasktimes csv file found. Converting csv into Rdata file....")
}

#Load the taskTimes file into a R dataFrame 
taskTimes.df <- read.csv(file = taskTimesFileName, header = T)
colnames(taskTimes.df) <- c("task", "cosmed.start", "cosmed.end", "phone.start", "phone.end", "PID", "visit", "visit.date")
taskTimes.df$start.time <- sapply(taskTimes.df$phone.start, FUN = ConvertToMilitaryTime)
taskTimes.df$end.time <- sapply(taskTimes.df$phone.end, FUN = ConvertToMilitaryTime)
taskTimes.df <- taskTimes.df[, c(1,6:10)]
taskTimes.df <- taskTimes.df[complete.cases(taskTimes.df), ]

#Save the R dataframe into a Rdata file 
saveRDS(taskTimes.df, file = paste(dataFolder,"taskTimes_all.Rdata",sep = ""))

rm(taskTimes.df)

message("Tasktimes csv file read and converted into a Rdata file.") 
