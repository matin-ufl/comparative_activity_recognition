
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

#Set the full path of the tasktime Rdata file
taskTimesFileName <- "~/Desktop/Data_Mining_Project/Raw_Data/taskTimes_all.Rdata"

#Set the chunk size 3 or 6
chunksize <- 3

#Load the list of Participants
participants.df <- readRDS(file = taskTimesFileName)

participants <- unique(participants.df$PID)

for (participantID in levels(participants)) {
  
  print (paste("Downsampling data for Participant : ",participantID))
  
  tryCatch(source("SCP_2_DownSampleData_One_Participant.R"), error=function(e){print(e)})
  
}

for (participantID in levels(participants)) {
  
  if (chunksize == 3) {
    
    print (paste("Generating 3s subsequences for Participant : ",participantID))
    
    tryCatch(source("SCP_3_Create_Subsequences_One_Participant.R"), error=function(e){print(e)})
    
  }
  
  if (chunksize == 6) {
    
    print (paste("Generating 6s subsequences for Participant : ",participantID))
    
    tryCatch(source("SCP_3_Create_Subsequences_One_Participant.R"), error=function(e){print(e)})
    
  }
  
  
}

print ("Merging the subsequences for all participants...")

tryCatch(source("SCP_4_Merge_All_Subsequences.R"), error=function(e){print(e)})

print ("Generating CodeBook....")

tryCatch(source("SCP_5_Generate_CodeBook.R"), error=function(e){print(e)})

print ("Generating Word Labels for all participants....")

tryCatch(source("SCP_6_Generate_Word_Labels.R"), error=function(e){print(e)})

print ("Calculating TF-IDF for all participants....")

tryCatch(source("SCP_7_Calculate_TF_IDF.R"), error=function(e){print(e)})


