#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_5_Merge_Word_Label_Files.R

#Script Summary : This script merges all the 3s or 6s word labels data into a single file.

#Author & Reviewer Details -------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ----------------------------------------------------------------------------

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")


#Set the directory where the cleaned data files are kept

FILEDIR = "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set).
CHUNKSIZE <- 3
FILETYPE <- "Training_Set"


#Parameters which gets set based on the settings provided above

if (CHUNKSIZE == 3) {
  
  merged.df <- data.frame(matrix(nrow = 0, ncol = 36))

  if(FILETYPE == "Training_Set") {
    
    FOLDERTYPE = "D32/Training_Set/"
    OUTFILENAME <- "Train_merged_BoW_labeled_W3_D32_dtw.Rdata"
    
  } else if (FILETYPE == "Testing_Set") {
    
    FOLDERTYPE = "D32/Testing_Set/"
    OUTFILENAME <- "Test_merged_BoW_labeled_W3_D32_dtw.Rdata"
    
  } else {
    
    stop("Invalid FILETYPE value. Please set to either Training_Set or Testing_Set.")
  }
  
} else if (CHUNKSIZE == 6) {
  
  merged.df <- data.frame(matrix(nrow = 0, ncol = 66))
  
  if(FILETYPE == "Training_Set") {
    
    FOLDERTYPE = "D64/Training_Set/"
    OUTFILENAME <- "Train_merged_BoW_labeled_W6_D64_dtw.Rdata"
    
  } else if (FILETYPE == "Testing_Set") {
    
    FOLDERTYPE = "D64/Testing_Set/"
    OUTFILENAME <- "Test_merged_BoW_labeled_W6_D64_dtw.Rdata"
    
  } else {
    
    stop("Invalid FILETYPE value. Please set to either Training_Set or Testing_Set.")
  }
}


#File Load, Merge and Save BOW Data --------------------------------------------------------------------

filelist <- dir(paste(FILEDIR,FOLDERTYPE,sep=""), pattern = "^.*.Rdata$")


#Loop through each file in the folder and merge into a dataframe

for (curr_file in filelist)
{
  
  message (paste("Loading and Merging Rdata File :",curr_file))
  
  data.df <- readRDS(paste(FILEDIR,FOLDERTYPE,curr_file,sep = ""))
  
  merged.df <- rbind(merged.df,data.df)
  
  
}

#Save the merged dataframe to a Rdata file
saveRDS(merged.df,paste(FILEDIR,OUTFILENAME,sep = ""))


message(paste(CHUNKSIZE," seconds word label merging completed for ", FILETYPE,".",sep = ""))
