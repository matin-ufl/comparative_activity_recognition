#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_4_Generate_Word_Labels.R

#Script Summary : This script generates the BOW labels for 3s and 6s subsequences of the data 
#                 based on the codebook values and dynamic time warping (DTW) technique.

#Author & Reviewer Details -------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings --------------------------------------------------------------------------

#Load the libraries
library(dplyr)
library(pbapply)

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

source("FUN_DTW_Functions.R")

#Set the directory to the location where the merged subsequence files are present
ALLCHUNKSFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/BOW_Files/"

#Set the directory where the codebook is stored
CODEBOOKFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set).
CHUNKSIZE <- 3
FILETYPE <- "Training_Set"


if(FILETYPE == "Testing_Set")
{
  FILEPREFIX <- "Test_"
  
} else {
  
  FILEPREFIX <- "Train_"
}

# Data Loading 3s chunks-----------------------------------------------------------------------------------------------------

if(CHUNKSIZE == 3) {
  
  #Number of atoms in codebook
  D<-32
  
  #Load All the 3s Data Chunks
  all_3s_chunks.df <- readRDS(file = paste(ALLCHUNKSFOLDER,FILEPREFIX,"All_3s_Chunks.Rdata",sep = ""))
  
  #Load the codebook
  codebook.df <- readRDS(file = paste(CODEBOOKFOLDER,"codebook_W3_D32_dtw.Rdata",sep = ""))
  
  #Participants List
  participants <- unique(all_3s_chunks.df$PID)
  
  #Initialize the dataframes
  merged.df <- data.frame(matrix(nrow = 0, ncol = 36))
  
# BOW Labels Generation and Saving 3s chunks--------------------------------------------------------------------------------------------  
  
  for(participantID in participants)
  {
    
    #Load the data into a different dataframe for a single patient
    subset.df <- all_3s_chunks.df[which(all_3s_chunks.df$PID == participantID),]
    
    if(nrow(subset.df) > 0){
      
      
      #Remove the participant data from original dataframe inorder to reduce the memory
      all_3s_chunks.df<- all_3s_chunks.df[which(all_3s_chunks.df$PID != participantID),]
      
      #Laod the vector V1 to V30
      vector.df <- subset.df[,cbind(startsWith(colnames(subset.df), "V"))]
      
      print(paste("Applying mutate function for participant: ", participantID))
      
      #Generating Word Labels for each participant
      subset.df <- mutate(subset.df, Word = pbapply(vector.df, FUN = FUN_WhichCluster, MARGIN = 1,codebook.df))
      
      saveRDS(subset.df, file = paste(CODEBOOKFOLDER,"D32/",FILETYPE,"/",participantID,"_BoW_labeled_W3_D32_dtw.Rdata",sep = ""))
    }
    
  }
  
  
} else if(CHUNKSIZE == 6) {
  
# Data Loading 6s chunks--------------------------------------------------------------------------------------------
  
  #Number of atoms in codebook
  D<-64
  
  #Load All the 6s Data Chunks
  all_6s_chunks.df <- readRDS(file = paste(ALLCHUNKSFOLDER,FILEPREFIX,"All_6s_Chunks.Rdata",sep = ""))
  
  #Load the codebook
  codebook.df <- readRDS(file = paste(CODEBOOKFOLDER,"codebook_W6_D64_dtw.Rdata",sep = ""))
  
  #Participants List
  participants <- unique(all_6s_chunks.df$PID)

# BOW Labels Generation & Saving 6s chunks--------------------------------------------------------------------------------------------
  
  for(participantID in participants)
  {
    #Load the data into a different dataframe for a single patient
    subset.df <- all_6s_chunks.df[which(all_6s_chunks.df$PID == participantID),]
    
    if(nrow(subset.df) > 0){
      
      #Remove the participant data from original dataframe inorder to reduce the memory
      all_6s_chunks.df<- all_6s_chunks.df[which(all_6s_chunks.df$PID != participantID),]
      
      #Laod the vector V1 to V60
      vector.df <- subset.df[,cbind(startsWith(colnames(subset.df), "V"))]
      
      print(paste("Applying mutate function for participant: ", participantID))
      
      #Generating Word Labels for each participant
      subset.df <- mutate(subset.df, Word = pbapply(vector.df, FUN = FUN_WhichCluster,MARGIN = 1,codebook.df))
      
      saveRDS(subset.df, file = paste(CODEBOOKFOLDER,"D64/",FILETYPE,"/",participantID,"_BoW_labeled_W6_D64_dtw.Rdata",sep = ""))
      
    }
    
  }
}

message(paste(CHUNKSIZE," seconds word label generation completed for ", FILETYPE,".",sep = ""))

