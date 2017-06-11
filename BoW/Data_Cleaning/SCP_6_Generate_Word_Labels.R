#Load the libraries
library(dplyr)

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")

source("FUN_DTW_Functions.R")

#Set the directory to the location where the subsequence files are present
AllChunksFolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/BOW_Files/"

#Set the directory where the codebook is stored
codebookfolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/Cleaned_Data/"

#Set chunk size when the script needs to be run as a standalone
#chunksize <- 6

if(chunksize == 3) {
  
  #Number of atoms in codebook
  d<-32
  
  #Load All the 3s Data Chunks
  all_3s_chunks.df <- read.csv(file = paste(AllChunksFolder,"All_3s_Chunks.csv",sep = ""))
  
  #Load the codebook
  codebook <- readRDS(file = paste(codebookfolder,"codebook_W3_D32_dtw.Rdata",sep = ""))
  
  #Participants List
  participants <- unique(all_3s_chunks.df$PID)
  
  #Create a merged dataframe
  merged.df <- data.frame(matrix(nrow = 0, ncol = 36))
  
  for(participantID in levels(as.factor(participants)))
  {
    subset.df <- all_3s_chunks.df[which(all_3s_chunks.df$PID == participantID),]
    
    if(nrow(subset.df) > 0){
      
      print(paste("Applying mutate function for participant: ", participantID))
      
      subset.df <- mutate(subset.df, Word = whichCluster(cbind(subset.df$V1,subset.df$V2,subset.df$V3,
                                                               subset.df$V4,subset.df$V5,subset.df$V6,
                                                               subset.df$V7,subset.df$V8,subset.df$V9,
                                                               subset.df$V10,subset.df$V11,subset.df$V12,
                                                               subset.df$V13,subset.df$V14,subset.df$V15,
                                                               subset.df$V16,subset.df$V17,subset.df$V18,
                                                               subset.df$V19,subset.df$V20,subset.df$V21,
                                                               subset.df$V22,subset.df$V23,subset.df$V24,
                                                               subset.df$V25,subset.df$V26,subset.df$V27,
                                                               subset.df$V28,subset.df$V29,subset.df$V30), codebook))
      
      merged.df <- rbind(merged.df,subset.df)
    }
    
  }
  
saveRDS(merged.df, file = paste(codebookfolder, "merged_BoW_labeled_W3_D32_dtw.Rdata",sep = ""))

} else if(chunksize == 6) {
  
  #Number of atoms in codebook
  d<-64
  
  #Load All the 6s Data Chunks
  all_6s_chunks.df <- read.csv(file = paste(AllChunksFolder,"All_6s_Chunks.csv",sep = ""))
  
  #Load the codebook
  codebook <- readRDS(file = paste(codebookfolder,"codebook_W6_D64_dtw.Rdata",sep = ""))
  
  #Participants List
  participants <- unique(all_6s_chunks.df$PID)
  
  #Create a merged dataframe
  merged.df <- data.frame(matrix(nrow = 0, ncol = 66))
  
  for(participantID in levels(as.factor(participants)))
  {
    subset.df <- all_6s_chunks.df[which(all_6s_chunks.df$PID == participantID),]
    
    if(nrow(subset.df) > 0){
      
      print(paste("Applying mutate function for participant: ", participantID))
      
      #Generating Word Labels for each Participant
      subset.df <- mutate(subset.df, Word = whichCluster(cbind(subset.df$V1,subset.df$V2,subset.df$V3,
                                                               subset.df$V4,subset.df$V5,subset.df$V6,
                                                               subset.df$V7,subset.df$V8,subset.df$V9,
                                                               subset.df$V10,subset.df$V11,subset.df$V12,
                                                               subset.df$V13,subset.df$V14,subset.df$V15,
                                                               subset.df$V16,subset.df$V17,subset.df$V18,
                                                               subset.df$V19,subset.df$V20,subset.df$V21,
                                                               subset.df$V22,subset.df$V23,subset.df$V24,
                                                               subset.df$V25,subset.df$V26,subset.df$V27,
                                                               subset.df$V28,subset.df$V29,subset.df$V30,
                                                               subset.df$V31,subset.df$V32,subset.df$V33,
                                                               subset.df$V34,subset.df$V35,subset.df$V36,
                                                               subset.df$V37,subset.df$V38,subset.df$V39,
                                                               subset.df$V40,subset.df$V41,subset.df$V42,
                                                               subset.df$V43,subset.df$V44,subset.df$V45,
                                                               subset.df$V46,subset.df$V47,subset.df$V48,
                                                               subset.df$V49,subset.df$V50,subset.df$V51,
                                                               subset.df$V52,subset.df$V53,subset.df$V54,
                                                               subset.df$V55,subset.df$V56,subset.df$V57,
                                                               subset.df$V58,subset.df$V59,subset.df$V60), codebook))
      
      merged.df <- rbind(merged.df,subset.df)
    }
    
  }
  
saveRDS(merged.df, file = paste(codebookfolder, "merged_BoW_labeled_W6_D64_dtw.Rdata",sep = ""))
  
}



