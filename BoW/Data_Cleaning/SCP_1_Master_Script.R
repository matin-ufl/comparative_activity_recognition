
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

#Set the chunk size 3 or 6
chunksize <- 6

#Set the directory where the downsampled files are stored

dataFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/"

#Set the value of filetype to Testing_Set or Training_Set

filetype <- "Testing_Set"

#Load the downsampled File List for Training or Testing Set

if (filetype== "Testing_Set")
{
  filelist <- dir(paste(dataFolder,"Downsampled_Files/Testing_Set/",sep=""), pattern = "^*.*Rdata$")
  
} else {
  
  filelist <- dir(paste(dataFolder,"Downsampled_Files/Training_Set/",sep=""), pattern = "^*.*Rdata$")
  
}



for (curr_file in filelist) {
  
  #Store Current ParticipantID
  participantID <- unlist(strsplit(curr_file, "_"))[1]
  
  if (chunksize == 3) {
    
    print (paste("Generating 3s subsequences for Participant : ",participantID))
    
    tryCatch(source("SCP_2_Create_Subsequences_One_Participant.R"), error=function(e){print(e)})
    
  }
  
  if (chunksize == 6) {
    
    print (paste("Generating 6s subsequences for Participant : ",participantID))
    
    tryCatch(source("SCP_2_Create_Subsequences_One_Participant.R"), error=function(e){print(e)})
    
  }
  
  
}

print ("Merging the subsequences for all participants...")

tryCatch(source("SCP_3_Merge_All_Subsequences.R"), error=function(e){print(e)})

if (filetype== "Training_Set")
{

  print ("Generating CodeBook....")

  tryCatch(source("SCP_4_Generate_CodeBook.R"), error=function(e){print(e)})
  
} else {
  
  print ("Generating Word Labels for all participants....")
  
  tryCatch(source("SCP_5_Generate_Word_Labels.R"), error=function(e){print(e)})
  
  print ("Calculating TF-IDF for all participants....")
  
  tryCatch(source("SCP_6_Calculate_TF_IDF.R"), error=function(e){print(e)})
  
}



