#Script Details --------------------------------------------------------------------------------------------------------

#Script Name : SCP_Check_TaskTimes_Errors.R

#Script Summary : This script checks for errors in the Task times file and writes a log for issues.

#Author & Reviewer Details ---------------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ---------------------------------------------------------------------------------------------------

#Load the libraries
library(data.table)

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the full path of the tasktime Rdata file
TASKTIMESFILENAME <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

#Set the folder of the log file
LOGFILESFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Logs/"

if(!file.exists(TASKTIMESFILENAME)) {
  stop("No TaskTimes File Found.") 
} else {
  print ("Tasktimes file found")
}

#Load the Tasktimes file -------------------------------------------------------------------------------

taskTimes.df <- readRDS(file = TASKTIMESFILENAME)

#Remove the visit without Visit H

taskTimes_filtered.df <- taskTimes.df[which(taskTimes.df$visit != "H"),]


#Grouping visit based on PID and Visit Date
countvisit.df <- setDT(taskTimes_filtered.df)[, .(count = uniqueN(visit)), by = .(PID,visit.date)]

#Grouping Visit Date based on PID and Visit 
countvisitdate.df <- setDT(taskTimes_filtered.df)[, .(count = uniqueN(visit.date)), by = .(PID,visit)]

#Store Erroneous Data
countvisit.df<- countvisit.df[which(countvisit.df$count > 1)]
countvisitdate.df<-countvisitdate.df[which(countvisitdate.df$count > 1)]


#Write errors to a CSV file for visit number

if(nrow(countvisit.df) > 0)
{
  write.csv(countvisit.df, file = paste(LOGFILESFOLDER,"error_visit.csv",sep = ""), row.names = FALSE)
}


#Write errors to a CSV file for visit date

if(nrow(countvisitdate.df) > 0)
{
  write.csv(countvisitdate.df,file = paste(LOGFILESFOLDER,"error_visitdate.csv",sep = ""), row.names = FALSE)
}


if (nrow(countvisit.df) == 0 & nrow(countvisitdate.df) == 0)
{
  message("No errors in tasktime file.")
}

message("Task Times errors checked successfully.")



