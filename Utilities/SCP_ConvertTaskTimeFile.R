#Script Details --------------------------------------------------------------------------------------------------------

#Script Name : SCP_ConvertTaskTimeFile.R

#Script Summary : This script converts the taskTimes_all.csv file into taskTimes_all.Rdata file 
#                 by including only the necessary columns required for the analysis.

#Author & Reviewer Details ---------------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu


#Parameter Settings ---------------------------------------------------------------------------------------------------


#Set the working directory to the loaction where this script is located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Load the function file

source("FUN_ConvertToMilitaryTime.R")

#Set the directory to the location where the taskTimes_all.csv file is located

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/"

TASKTIMESFILENAME <- paste(DATAFOLDER,"taskTimes_all.csv", sep = "")
  
#Check if the file exists in the given directory. 

if(!file.exists(TASKTIMESFILENAME)) {
  stop("No TaskTimes csv file found.") 
} else {
  print ("Tasktimes csv file found. Converting csv into Rdata file....")
}

#CSV TaskTimes Data Loading ---------------------------------------------------------------------------------------

#Load the taskTimes file into a R dataFrame 
taskTimes.df <- read.csv(file = TASKTIMESFILENAME, header = T)
colnames(taskTimes.df) <- c("task", "cosmed.start", "cosmed.end", "phone.start", "phone.end", "PID", "visit", "visit.date")

#TaskTimes Data Conversion ---------------------------------------------------------------------------------------

taskTimes.df$start.time <- sapply(taskTimes.df$phone.start, FUN = FUN_ConvertToMilitaryTime)
taskTimes.df$end.time <- sapply(taskTimes.df$phone.end, FUN = FUN_ConvertToMilitaryTime)
taskTimes.df <- taskTimes.df[, c(1,6:10)]
taskTimes.df <- taskTimes.df[complete.cases(taskTimes.df), ]
taskTimes.df <- taskTimes.df[which(taskTimes.df$start.time < taskTimes.df$end.time), ]


#Saving TaskTimes Data to RData File ---------------------------------------------------------------------------------------

#Save the R dataframe into a Rdata file 
saveRDS(taskTimes.df, file = paste(DATAFOLDER,"taskTimes_all.Rdata",sep = ""))

rm(taskTimes.df)

message("Tasktimes csv file read and converted into a Rdata file.")
