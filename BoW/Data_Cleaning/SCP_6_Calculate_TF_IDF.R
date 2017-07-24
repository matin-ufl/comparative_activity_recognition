#Script Details --------------------------------------------------------------------------------------------------------

#Script Name : SCP_6_Calculate_TF_IDF.R

#Script Summary : This script calculates the term frequency and inverse doc frequency of training and testing data.

#Author & Reviewer Details ---------------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ---------------------------------------------------------------------------------------------------

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

source("FUN_TF_IDF_Functions.R")

#Set CHUNKSIZE = (3 or 6) and FILETYPE = (Training_Set or Testing_Set).
CHUNKSIZE=6
FILETYPE <- "Testing_Set"

#Set the directory where the DTW subsequnces with labels are stored
DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

if(FILETYPE == "Testing_Set")
{
  FILEPREFIX <- "Test_"
  
} else if(FILETYPE == "Training_Set"){
  
  FILEPREFIX <- "Train_"
  
} else {
  
  stop("Invalid FileType value. Please set value as Training_Set or Testing_Set")
  
}



#Data Loading ----------------------------------------------------------------------------------------------------------------

if(CHUNKSIZE == 3)
{
  #Number of atoms
  D <- 32
  
  #Atom List
  atoms <- sapply(1:D, FUN = function(x) {as.character(paste("D", x, sep = ""))})
  
  #Load the word label file for Training or Testing Set based on file type
  if (FILETYPE == "Training_Set")
  {
    train.df <- readRDS(file = paste(DATAFOLDER,"Train_merged_BoW_labeled_W3_D32_dtw.Rdata",sep = ""))
    
    #Outputfilename
    
    IDF_FILENAME <- "Train_IDF_W3_D32.Rdata"
    BOW_FILENAME <- "Train_BoW_W3_D32_dtw.Rdata"
    
    
  } else if (FILETYPE == "Testing_Set") {
   
    test.df <- readRDS(file = paste(DATAFOLDER,"Test_merged_BoW_labeled_W3_D32_dtw.Rdata",sep = "")) 
    
    #Outputfilenames
    
    IDF_FILENAME <- "Train_IDF_W3_D32.Rdata"
    BOW_FILENAME <- "Test_BoW_W3_D32_dtw.Rdata"
    
  } else {
    
    stop("Invalid FileType value. Please set value as Training_Set or Testing_Set")
    
  }
  
} else if (CHUNKSIZE == 6) {
  #Number of atoms
  D <- 64
  
  #Atom List
  atoms <- sapply(1:D, FUN = function(x) {as.character(paste("D", x, sep = ""))})
  
  #Load the word label file for Training or Testing Set based on file type
  if (FILETYPE == "Training_Set")
  {
    train.df <- readRDS(file = paste(DATAFOLDER,"Train_merged_BoW_labeled_W6_D64_dtw.Rdata",sep = ""))
    
    #Outputfilenames
    
    IDF_FILENAME <- "Train_IDF_W6_D64.Rdata"
    BOW_FILENAME <- "Train_BoW_W6_D64_dtw.Rdata"
    
    
  } else if (FILETYPE == "Testing_Set") {
    
    test.df <- readRDS(file = paste(DATAFOLDER,"Test_merged_BoW_labeled_W6_D64_dtw.Rdata",sep = "")) 
    
    #Outputfilename
    IDF_FILENAME <- "Train_IDF_W6_D64.Rdata"
    BOW_FILENAME <- "Test_BoW_W6_D64_dtw.Rdata"
    
  } else {
    
    stop("Invalid FileType value. Please set value as Training_Set or Testing_Set")
    
  }
  
}


# TF-IDF Calculation for Training & Testing Set --------------------------------------------------------------------

if (FILETYPE == "Training_Set") {
  
  # Calculating Term Frequency for each ppt-task
  train_justWords.df <- train.df[, c(1:5, ncol(train.df))]
  
  rm(train.df)
  
  message("Calculating Term Frequency for Training Set....")
  
  train_TF.df <- FUN_Calc_Term_Frequency(train_justWords.df)
  
  message("Calculating IDF for Training Set....")
  
  train_IDF.df <- FUN_Calc_Inverse_Doc_Frequency(train_TF.df,atoms,D)
  
  #Saving IDF File for re-using in case of Testing Set
  saveRDS(train_IDF.df, file = paste(DATAFOLDER,IDF_FILENAME,sep = ""))
  
  #Calculate Final cleaned Training Data
  
  train_bow_dtw.df <- FUN_Calc_BOW_Data(train_TF.df,train_IDF.df, D)
  
  # Dataset is ready! Save it to a file!
  saveRDS(train_bow_dtw.df, file = paste(DATAFOLDER,BOW_FILENAME,sep = ""))
  
  
  
} else if (FILETYPE == "Testing_Set") {
  
  test_justWords.df <- test.df[, c(1:5, ncol(test.df))]
  
  rm(test.df)
  
  message("Calculating Term Frequency for Testing Set....")
  
  test_TF.df <- FUN_Calc_Term_Frequency(test_justWords.df)
  
  if(!file.exists(paste(DATAFOLDER,IDF_FILENAME,sep = "")))
  {
    stop ("IDF File missing for training set. Please compute the TF-IDF for Training Set and then for Testing Set.")
  } 
  else 
  {
    message("Loading the IDF Training File...")
    
    train_IDF.df <- readRDS(file = paste(DATAFOLDER,IDF_FILENAME,sep = ""))
    
    message("Calculating Final BOW Data for testing set...")
    
    test_bow_dtw.df <- FUN_Calc_BOW_Data(test_TF.df,train_IDF.df, D)
    
    # Dataset is ready! Save it to a file!
    saveRDS(test_bow_dtw.df, file = paste(DATAFOLDER,BOW_FILENAME,sep = ""))
    
    
  }
  
}

message(paste(CHUNKSIZE," seconds TF-IDF calculation completed for ",FILETYPE,".",sep = ""))