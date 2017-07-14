#Script Details -------------------------------------------------------------------------------------

#Script Name : SCP_Activity_Data_Classification.R

#Script Summary : This script classifies the cleaned data into two classes based on user input.
#                 There are two types of classification as given below :
#                 1. Sedentary and Non-Sedentary : 1 as Sedentary and 0 as Non-Sedentary.
#                 2. Locomotion and Stationary : 1 as Locomotion and 0 as Stationary.

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/14/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date :
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ---------------------------------------------------------------------------------

#Clear the environment

rm(list=ls())

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Classification/")

#Load the classification functions

source("FUN_Activity_Data_Classifier_Functions.R")

#Set CLASS_CATEGORY = ("Sedentary" or "Locomotion"), CHUNKSIZE = (3 or 6) and
#CLASSIFIER_TYPE =  ("SVM" or "DecisionTree" or "RandomForest" or "LDA")

CHUNKSIZE=3
CLASS_CATEGORY <- "Sedentary"
CLASSIFIER_TYPE <- "RandomForest"


#Set the data directory of the Cleaned Data

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"
OUTPUTFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/Model_Output/"

#Filenames selected based on the above settings

if (CHUNKSIZE == 3)
{
  
  TRAINING_DATAFILE <- "Train_BoW_W3_D32_dtw.Rdata"
  TEST_DATAFILE <- "Test_BoW_W3_D32_dtw.Rdata"
  
  if (CLASS_CATEGORY == "Sedentary") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "SDNT_SVM_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "SDNT_SVM_Test_Out_BoW_W3_D32.Rdata"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "SDNT_DT_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "SDNT_DT_Test_Out_BoW_W3_D32.Rdata"
      
    }  else if (CLASSIFIER_TYPE == "LDA") {
      
      MODEL_FILE <- "SDNT_LDA_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "SDNT_LDA_Test_Out_BoW_W3_D32.Rdata"
      
    } else {
      
        CLASSIFIER_TYPE <- "RandomForest"
        MODEL_FILE <- "SDNT_RF_Model_BoW_W3_D32.Rdata"
        TEST_OUT_FILE <- "SDNT_RF_Test_Out_BoW_W3_D32.Rdata"
      
    }
    
} else if (CLASS_CATEGORY == "Locomotion") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "LCM_SVM_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "LCM_SVM_Test_Out_BoW_W3_D32.Rdata"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "LCM_DT_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "LCM_DT_Test_Out_BoW_W3_D32.Rdata"
      
    } else if (CLASSIFIER_TYPE == "LDA") {
      
      MODEL_FILE <- "LCM_LDA_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "LCM_LDA_Test_Out_BoW_W3_D32.Rdata"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "LCM_RF_Model_BoW_W3_D32.Rdata"
      TEST_OUT_FILE <- "LCM_RF_Test_Out_BoW_W3_D32.Rdata"
      
    }
    
  }
  
} else if (CHUNKSIZE == 6) {
  
  TRAINING_DATAFILE <- "Train_BoW_W6_D64_dtw.Rdata"
  TEST_DATAFILE <- "Test_BoW_W6_D64_dtw.Rdata"
  
  if (CLASS_CATEGORY == "Sedentary") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "SDNT_SVM_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "SDNT_SVM_Test_Out_BoW_W6_D64.Rdata"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "SDNT_DT_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "SDNT_DT_Test_Out_BoW_W6_D64.Rdata"
      
    } else if (CLASSIFIER_TYPE == "RandomForest") {
      
      MODEL_FILE <- "SDNT_RF_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "SDNT_RF_Test_Out_BoW_W6_D64.Rdata"
      
    } else if (CLASSIFIER_TYPE == "LDA") {
      
      MODEL_FILE <- "SDNT_LDA_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "SDNT_LDA_Test_Out_BoW_W6_D64.Rdata"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "SDNT_RF_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "SDNT_RF_Test_Out_BoW_W6_D64.Rdata"
      
    }
    
} else if (CLASS_CATEGORY == "Locomotion") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "LCM_SVM_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "LCM_SVM_Test_Out_BoW_W6_D64.Rdata"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "LCM_DT_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "LCM_DT_Test_Out_BoW_W6_D64.Rdata"
      
    } else if (CLASSIFIER_TYPE == "LDA") {
      
      MODEL_FILE <- "LCM_LDA_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "LCM_LDA_Test_Out_BoW_W6_D64.Rdata"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "LCM_RF_Model_BoW_W6_D64.Rdata"
      TEST_OUT_FILE <- "LCM_RF_Test_Out_BoW_W6_D64.Rdata"
      
    }
    
  }
  
}


# Data Loading and Adding Task Labels -----------------------------------------------------------------

# Load the Training and Testing Set into data frames
  
  if(file.exists(paste(DATAFOLDER,TRAINING_DATAFILE,sep = "")))
  {
    
    train.df <- readRDS(paste(DATAFOLDER,TRAINING_DATAFILE,sep = ""))
    
  } else {
    
    warning("No Training Data Found.")
    
  }
  

# Add Task Labels based on classifier type

  if (CLASS_CATEGORY == "Sedentary")
  {
    message ("Adding Task Labels to training set for Sedentary and Non-Sedentary Classifier...")
    
    train.df <- FUN_Add_SDNT_TaskLabels(train.df)
    
  } else if  (CLASS_CATEGORY == "Locomotion") {
    
    message ("Adding Task Labels to training set Locomotion and Stationary Classifier...")
    
    train.df <- FUN_Add_LCM_TaskLabels(train.df)
    
  } else {
    
    stop("Please set the correct classifier type.")
  
  }

message ("Task Labels Added.....")

#Training the model ---------------------------------------------------

# Train the model based on classifier type

if (CLASS_CATEGORY == "Sedentary") {
  
  message ("Training Model for Sedentary and Non-Sedentary Classifier...")
  
  model <- FUN_SDNT_Train_Classifier(train.df,CLASSIFIER_TYPE,CHUNKSIZE)
  
} else if (CLASS_CATEGORY == "Locomotion") {
  
  message ("Training Model for Locomotion and Stationary Classifier...")
  
  model <- FUN_LCM_Train_Classifier(train.df,CLASSIFIER_TYPE,CHUNKSIZE)

}

#Save the trained model

saveRDS(model, paste(OUTPUTFOLDER,MODEL_FILE,sep = ""))

#Test the model ---------------------------------------------------

#Load the Test data set

if(file.exists(paste(DATAFOLDER,TEST_DATAFILE,sep = "")))
{
  
  test.df <- readRDS(paste(DATAFOLDER,TEST_DATAFILE,sep = ""))
  
} else {
  
  stop("No Test Data Found.")
  
}

#Load the trained model

if(file.exists(paste(OUTPUTFOLDER,MODEL_FILE,sep = ""))) {
  
  model <- readRDS(paste(OUTPUTFOLDER,MODEL_FILE,sep = ""))
  
  if (CLASS_CATEGORY == "Sedentary") {
    
  #Add Actual Task Labels to the test data set
  test.df <- FUN_Add_SDNT_TaskLabels(test.df)
 
  } else if (CLASS_CATEGORY == "Locomotion") {
     
    #Add Actual Task Labels to the test data set
    test.df <- FUN_Add_LCM_TaskLabels(test.df)
    
  }
  
  #Call the function for predictions
  test.df <- FUN_Evaluate_Classifier(model,test.df, CLASSIFIER_TYPE)
  
  #Save the test dataset after evaluation
  
  saveRDS(test.df, paste(OUTPUTFOLDER,TEST_OUT_FILE,sep = ""))
  
  
} else {
  
  stop("Trained model not found.")
  
}

#Display Test Data Evaluation Summary 

cf <- FUN_Display_Classifier_Stats(test.df)

#Print the overall summary
cf$overall

#Print the summary by class
cf$byClass

#Print the confusion matrix
cf$table

message ("Data Classification Process Completed.")
