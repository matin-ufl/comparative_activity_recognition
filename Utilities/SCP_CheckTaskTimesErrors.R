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

#Remove the visit without Visit H

taskTimes_filtered.df <- taskTimes.df[which(taskTimes.df$visit != "H"),]


#Grouping visit based on PID and Visit Date
countvisit.df <- setDT(taskTimes_filtered.df)[, .(count = uniqueN(visit)), by = .(PID,visit.date)]

#Grouping visit based on PID and Visit 
countvisitdate.df <- setDT(taskTimes_filtered.df)[, .(count = uniqueN(visit.date)), by = .(PID,visit)]

#Store Erroneous Data
countvisit.df<- countvisit.df[which(countvisit.df$count > 1)]
countvisitdate.df<-countvisitdate.df[which(countvisitdate.df$count > 1)]


#Write errors to a CSV file for visit number

if(nrow(countvisit.df) > 0)
{
  write.csv(countvisit.df, file = paste(logfileFolder,"error_visit.csv"), row.names = FALSE)
}


#Write errors to a CSV file for visit date

if(nrow(countvisitdate.df) > 0)
{
  write.csv(countvisitdate.df,file = paste(logfileFolder,"error_visitdate.csv"), row.names = FALSE)
}


if (nrow(countvisit.df) == 0 & nrow(countvisitdate.df) == 0)
{
  message("No errors in tasktime file.")
}



