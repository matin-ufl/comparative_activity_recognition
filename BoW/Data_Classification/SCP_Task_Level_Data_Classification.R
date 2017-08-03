#Script Details -------------------------------------------------------------------------------------

#Script Name : SCP_Task_Level_Data_Classification.R

#Script Summary : This script classifies the cleaned data into sub-classes of two classes based on user input.
#                 There are two types of classification as given below :
#                 1. Sedentary Tasks : COMPUTER WORK, STANDING STILL and TV WATCHING
#                 2. Locomotion Tasks : LEISURE WALK, RAPID WALK, STAIR ASCENT, STAIR DESCENT, 
#                                       WALKING AT RPE 1 and WALKING AT RPE 5

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/21/2017
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
#CLASSIFIER_TYPE =  ("SVM" or "DecisionTree" or "RandomForest")

CHUNKSIZE=3
CLASS_CATEGORY <- "Sedentary"
CLASSIFIER_TYPE <- "RandomForest"


#Set the data directory of the Cleaned Data

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"
MODEL_FOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Model_Output/Tasks_Classification_Training_Model_Files/"
TESTDATA_OUTPUTFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Model_Output/Tasks_Classification_Test_Output_Files/"



#Filenames selected based on the above settings

if (CHUNKSIZE == 3)
{
  
  TRAINING_DATAFILE <- "Train_BoW_W3_D32_dtw.Rdata"
  TEST_DATAFILE <- "Test_BoW_W3_D32_dtw.Rdata"
  
  if (CLASS_CATEGORY == "Sedentary") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "SedentaryTasks_3secs_32atoms_SVM_Model.Rdata"
      TEST_OUT_FILE <- "SedentaryTasksRecognition_3secs_32atoms_SVM_Test_Results.csv"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "SedentaryTasks_3secs_32atoms_DecisionTree_Model.Rdata"
      TEST_OUT_FILE <- "SedentaryTasksRecognition_3secs_32atoms_DecisionTree_Test_Results.csv"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "SedentaryTasks_3secs_32atoms_RandomForest_Model.Rdata"
      TEST_OUT_FILE <- "SedentaryTasksRecognition_3secs_32atoms_RandomForest_Test_Results.csv"
      
    }
    
  } else if (CLASS_CATEGORY == "Locomotion") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "LocomotionTasks_3secs_32atoms_SVM_Model.Rdata"
      TEST_OUT_FILE <- "LocomotionTasksRecognition_3secs_32atoms_SVM_Test_Results.csv"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "LocomotionTasks_3secs_32atoms_DecisionTree_Model.Rdata"
      TEST_OUT_FILE <- "LocomotionTasksRecognition_3secs_32atoms_DecisionTree_Test_Results.csv"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "LocomotionTasks_3secs_32atoms_RandomForest_Model.Rdata"
      TEST_OUT_FILE <- "LocomotionTasksRecognition_3secs_32atoms_RandomForest_Test_Results.csv"
      
    }
    
  }
  
} else if (CHUNKSIZE == 6) {
  
  TRAINING_DATAFILE <- "Train_BoW_W6_D64_dtw.Rdata"
  TEST_DATAFILE <- "Test_BoW_W6_D64_dtw.Rdata"
  
  if (CLASS_CATEGORY == "Sedentary") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "SedentaryTasks_6secs_64atoms_SVM_Model.Rdata"
      TEST_OUT_FILE <- "SedentaryTasksRecognition_6secs_64atoms_SVM_Test_Results.csv"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "SedentaryTasks_6secs_64atoms_DecisionTree_Model.Rdata"
      TEST_OUT_FILE <- "SedentaryTasksRecognition_6secs_64atoms_DecisionTree_Test_Results.csv"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "SedentaryTasks_6secs_64atoms_RandomForest_Model.Rdata"
      TEST_OUT_FILE <- "SedentaryTasksRecognition_6secs_64atoms_RandomForest_Test_Results.csv"
      
    }
    
  } else if (CLASS_CATEGORY == "Locomotion") {
    
    if(CLASSIFIER_TYPE == "SVM") {
      
      MODEL_FILE <- "LocomotionTasks_6secs_64atoms_SVM_Model.Rdata"
      TEST_OUT_FILE <- "LocomotionTasksRecognition_6secs_64atoms_SVM_Test_Results.csv"
      
    } else if (CLASSIFIER_TYPE == "DecisionTree") {
      
      MODEL_FILE <- "LocomotionTasks_6secs_64atoms_DecisionTree_Model.Rdata"
      TEST_OUT_FILE <- "LocomotionTasksRecognition_6secs_64atoms_DecisionTree_Test_Results.csv"
      
    } else {
      
      CLASSIFIER_TYPE <- "RandomForest"
      MODEL_FILE <- "LocomotionTasks_6secs_64atoms_RandomForest_Model.Rdata"
      TEST_OUT_FILE <- "LocomotionTasksRecognition_6secs_64atoms_RandomForest_Test_Results.csv"
      
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
  
  #Select the sedentary task rows
  
  subset_train_df <- train.df[which(train.df$ActualTaskLabel==1),]
  
  #Set the task names as the Actual labels
  
  subset_train_df$ActualTaskLabel <- subset_train_df$Task
  
  
} else if  (CLASS_CATEGORY == "Locomotion") {
  
  message ("Adding Task Labels to training set Locomotion and Stationary Classifier...")
  
  train.df <- FUN_Add_LCM_TaskLabels(train.df)
  
  #Select the locomotion task rows
  
  subset_train_df <- train.df[which(train.df$ActualTaskLabel==1),]
  
  #Set the task names as the Actual labels
  
  subset_train_df$ActualTaskLabel <- subset_train_df$Task
  
} else {
  
  stop("Please set the correct classifier type.")
  
}

message ("Task Labels Added.....")

#Training the model ---------------------------------------------------

# Train the model based on classifier type

if (CLASS_CATEGORY == "Sedentary") {
  
  message ("Training Model for Sedentary Tasks Classifier...")
  
  SDNT_Task_Model <- FUN_SDNT_Train_Classifier(subset_train_df,CLASSIFIER_TYPE,CHUNKSIZE)
  
  #Save the trained model
  
  saveRDS(SDNT_Task_Model, paste(MODEL_FOLDER,MODEL_FILE,sep = ""))
  
} else if (CLASS_CATEGORY == "Locomotion") {
  
  message ("Training Model for Locomotion Tasks Classifier...")
  
  LCM_Task_Model <- FUN_LCM_Train_Classifier(subset_train_df,CLASSIFIER_TYPE,CHUNKSIZE)
  
  #Save the trained model
  
  saveRDS(LCM_Task_Model, paste(MODEL_FOLDER,MODEL_FILE,sep = ""))
  
}



#Test the model ---------------------------------------------------

#Load the Original Test data set

if(file.exists(paste(DATAFOLDER,TEST_DATAFILE,sep = "")))
{
  
  original_test.df <- readRDS(paste(DATAFOLDER,TEST_DATAFILE,sep = ""))
  
} else {
  
  stop("No Original Test Data Found.")
  
}

#Add Actual Task Lables for Task Categories to the test data

if (CLASS_CATEGORY == "Sedentary") {
  
  original_test.df <- FUN_Add_SDNT_TaskLabels(original_test.df)
  
} else if (CLASS_CATEGORY == "Locomotion") {
  
  original_test.df <- FUN_Add_LCM_TaskLabels(original_test.df)
  
}


#Filter the Sedentary or Locomotion Tasks data only

test.df <- original_test.df[which(original_test.df$ActualTaskLabel == 1),]


#Load the trained model

if(file.exists(paste(MODEL_FOLDER,MODEL_FILE,sep = ""))) {
  
  model <- readRDS(paste(MODEL_FOLDER,MODEL_FILE,sep = ""))
  
  if (CLASS_CATEGORY == "Sedentary") {
    
    #Add Task Names as Actual Task Labels to the test data set
    test.df$ActualTaskLabel <- test.df$Task
    
  } else if (CLASS_CATEGORY == "Locomotion") {
    
    #Add Task Names as Actual Task Labels to the test data set
    test.df$ActualTaskLabel <- test.df$Task
    
  }
  
  #Call the function for predictions
  test.df <- FUN_Evaluate_Classifier(model,test.df, CLASSIFIER_TYPE)
  
  #Save the test dataset after evaluation
  
  write.csv(test.df[,c('PID', 'Task', 'ActualTaskLabel', 'PredictedTaskLabel')], 
            paste(TESTDATA_OUTPUTFOLDER,TEST_OUT_FILE,sep = ""),row.names = FALSE)
  
  
} else {
  
  stop("Trained model not found.")
  
}

# Compute Model Evaluation Parameters -------------------------------------

#Display Test Data Evaluation Summary 

cf <- FUN_Display_Classifier_Stats(test.df)

#Print the overall summary
cf$overall

#Print the summary by class
cf$byClass

#Print the confusion matrix
cf$table

message ("Data Classification Process Completed.")
