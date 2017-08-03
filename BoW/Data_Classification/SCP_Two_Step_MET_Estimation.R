#Script Details -------------------------------------------------------------------------------------

#Script Name : SCP_Two_Step_MET_Estimation.R

#Script Summary : This script predicts the MET Estimation values using a two step process.
#                 Step - 1 - Classifies the test data into Sedentary/Non-Sedentary 
#                            and Locomotion/Stationary categories using training set.
#                 Step - 2 - Predicts the MET data of the test set using the training data frame 
#                            created by the previous step by fitting it to the 
#                            any one of the three Regression Models (RandomForest/DecisionTree/SVM)
#                            based on user input.

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/20/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date :
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ---------------------------------------------------------------------------------

#Clear the environment

rm(list=ls())

#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Codes/Classification/BoW Classification/")

#Load the classification functions

source("FUN_Activity_Data_Classifier_Functions.R")

#Set CHUNKSIZE = (3 or 6) and CLASSIFIER_TYPE =  ("SVM" or "DecisionTree" or "RandomForest")

CHUNKSIZE=6
CLASSIFIER_TYPE <- "RandomForest"


#Set the data directory of the Cleaned Data and the directories of the output files

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"
MODEL_FOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Model_Output/MET_Estimation_Training_Model_Files/"
TESTDATA_OUTPUTFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Model_Output/MET_Estimation_Test_Output_Files/"

#Set the name of the MET Values file
MET_VALUES_FILENAME <- "MET_values.Rdata"

#Filenames selected based on the above settings

if (CHUNKSIZE == 3)
{
  
  TRAINING_DATAFILE <- "Train_BoW_W3_D32_dtw.Rdata"
  TEST_DATAFILE <- "Test_BoW_W3_D32_dtw.Rdata"
  
  if(CLASSIFIER_TYPE == "SVM") {
    
    #Step - 1 Model Files
    
    SDNT_NSDNT_MODEL_FILE <- "TwoStep_Sedentary_Non_Sedentary_3secs_32atoms_SVM_Model.Rdata"
    LCM_STNRY_MODEL_FILE <- "TwoStep_Locomotion_Stationary_3secs_32atoms_SVM_Model.Rdata"
    
    
    #Step - 2 Model Files
    
    MET_MODEL_FILE <- "TwoStep_MET_Estimation_3secs_32atoms_SVM_Model.Rdata"
    
    # Output File
    
    TEST_OUT_FILE <- "TwoStep_MET_Estimation_3secs_32atoms_SVM_Test_Results.csv"
    
    
  } else if (CLASSIFIER_TYPE == "DecisionTree") {
    
    #Step - 1 Model Files
    
    SDNT_NSDNT_MODEL_FILE <- "TwoStep_Sedentary_Non_Sedentary_3secs_32atoms_DecisionTree_Model.Rdata"
    LCM_STNRY_MODEL_FILE <- "TwoStep_Locomotion_Stationary_3secs_32atoms_DecisionTree_Model.Rdata"
    
    #Step - 2 Model Files
    
    MET_MODEL_FILE <- "TwoStep_MET_Estimation_3secs_32atoms_DecisionTree_Model.Rdata"
    
    # Output File
    
    TEST_OUT_FILE <- "TwoStep_MET_Estimation_3secs_32atoms_DecisionTree_Test_Results.csv"
    
    
  } else {
    
    CLASSIFIER_TYPE <- "RandomForest"
    
    #Step - 1 Model Files
    
    SDNT_NSDNT_MODEL_FILE <- "TwoStep_Sedentary_Non_Sedentary_3secs_32atoms_RandomForest_Model.Rdata"
    LCM_STNRY_MODEL_FILE <- "TwoStep_Locomotion_Stationary_3secs_32atoms_RandomForest_Model.Rdata"
    
    #Step - 2 Model Files
    
    MET_MODEL_FILE <- "TwoStep_MET_Estimation_3secs_32atoms_RandomForest_Model.Rdata"
    
    # Output File
    
    TEST_OUT_FILE <- "TwoStep_MET_Estimation_3secs_32atoms_RandomForest_Test_Results.csv"
    
  }
  
} else if (CHUNKSIZE == 6) {
  
  TRAINING_DATAFILE <- "Train_BoW_W6_D64_dtw.Rdata"
  TEST_DATAFILE <- "Test_BoW_W6_D64_dtw.Rdata"
  
  
  if(CLASSIFIER_TYPE == "SVM") {
    
    #Step - 1 Model Files
    
    SDNT_NSDNT_MODEL_FILE <- "TwoStep_Sedentary_Non_Sedentary_6secs_64atoms_SVM_Model.Rdata"
    LCM_STNRY_MODEL_FILE <- "TwoStep_Locomotion_Stationary_6secs_64atoms_SVM_Model.Rdata"
    
    #Step - 2 Model Files
    
    MET_MODEL_FILE <- "TwoStep_MET_Estimation_6secs_64atoms_SVM_Model.Rdata"
    
    # Output File
    
    TEST_OUT_FILE <- "TwoStep_MET_Estimation_6secs_64atoms_SVM_Test_Results.csv"
    
    
  } else if (CLASSIFIER_TYPE == "DecisionTree") {
    
    #Step - 1 Model Files
    
    SDNT_NSDNT_MODEL_FILE <- "TwoStep_Sedentary_Non_Sedentary_6secs_64atoms_DecisionTree_Model.Rdata"
    LCM_STNRY_MODEL_FILE <- "TwoStep_Locomotion_Stationary_6secs_64atoms_DecisionTree_Model.Rdata"
    
    #Step - 2 Model Files
    
    MET_MODEL_FILE <- "TwoStep_MET_Estimation_6secs_64atoms_DecisionTree_Model.Rdata"
    
    # Output File
    
    TEST_OUT_FILE <- "TwoStep_MET_Estimation_6secs_64atoms_DecisionTree_Test_Results.csv"
    
    
  } else {
    
    CLASSIFIER_TYPE <- "RandomForest"
    
    #Step - 1 Model Files
    
    SDNT_NSDNT_MODEL_FILE <- "TwoStep_Sedentary_Non_Sedentary_6secs_64atoms_RandomForest_Model.Rdata"
    LCM_STNRY_MODEL_FILE <- "TwoStep_Locomotion_Stationary_6secs_64atoms_RandomForest_Model.Rdata"

    #Step - 2 Model Files
    
    MET_MODEL_FILE <- "TwoStep_MET_Estimation_6secs_64atoms_RandomForest_Model.Rdata"
    
    # Output File
    
    TEST_OUT_FILE <- "TwoStep_MET_Estimation_6secs_64atoms_RandomForest_Test_Results.csv"
    
  }
  
}

# Data Loading-----------------------------------------------------------------

#Load the MET Values from the RData File

if(file.exists(paste(DATAFOLDER,MET_VALUES_FILENAME,sep = "")))
{
  
  MET_Values.df <- readRDS(paste(DATAFOLDER,MET_VALUES_FILENAME,sep = ""))
  
} else {
  
  stop("No MET Values Data Found.")
  
}

# Load the Training Dataset into data frames

if(file.exists(paste(DATAFOLDER,TRAINING_DATAFILE,sep = "")))
{
  
  all_train.df <- readRDS(paste(DATAFOLDER,TRAINING_DATAFILE,sep = ""))
  
  #Store training data into another dataframe for Training MET Model 
  
  MET_train.df <- all_train.df
  
} else {
  
  stop("No Training Data Found.")
  
}

# Adding Task Labels and Training Step-1 Sedentary/Non-Sedentary Models ------------------------------------------

# Add Task Labels for Sedentary/Non-Sedentary Tasks

message ("Adding Task Labels to training set for Sedentary/Non-Sedentary Classifier...")

all_train.df <- FUN_Add_SDNT_TaskLabels(all_train.df)

message ("Training Model for Sedentary and Non-Sedentary Classifier...")

SDNT_Model <- FUN_SDNT_Train_Classifier(all_train.df,CLASSIFIER_TYPE,CHUNKSIZE)

#Save the Sedentary/Non Sedentary Classification Model

saveRDS(SDNT_Model, paste(MODEL_FOLDER,SDNT_NSDNT_MODEL_FILE,sep = ""))

# Add Task Labels for Locomotion/Stationary Tasks

message ("Adding Task Labels to training set for Locomotion/Stationary Classifier...")

all_train.df <- FUN_Add_LCM_TaskLabels(all_train.df)

message ("Training Model for Locomotion and Stationary Classifier...")

LCM_Model <- FUN_LCM_Train_Classifier(all_train.df,CLASSIFIER_TYPE,CHUNKSIZE)

#Save the Locomotion/Stationary Classification Model

saveRDS(LCM_Model, paste(MODEL_FOLDER,LCM_STNRY_MODEL_FILE,sep = ""))

# Prepare MET Training Set --------------------------------------------------

#Add Sedentary/Non-Sedentary Task Labels
MET_train.df <- FUN_Add_SDNT_TaskLabels(MET_train.df)

#Rename the actual labels columns
colnames(MET_train.df)[which(names(MET_train.df) == "ActualTaskLabel")] <- "Sedentary"

#Add Locomotion/Stationary Task Labels
MET_train.df <- FUN_Add_LCM_TaskLabels(MET_train.df)

#Rename the actual labels columns
colnames(MET_train.df)[which(names(MET_train.df) == "ActualTaskLabel")] <- "Locomotion"

#Add the MET values to the training dataframe

MET_train.df <- merge(x = MET_train.df, y = MET_Values.df[,c("PID","Task","METs")], by = c("PID","Task"))

#Rename the actual labels columns to training set

colnames(MET_train.df)[which(names(MET_train.df) == "METs")] <- "Actual_MET_Values"

#Train the MET Estimation Model -----------------------------------------

MET_Model <- FUN_MET_Estimation_Train_Regressor(MET_train.df,CLASSIFIER_TYPE,CHUNKSIZE)

# Save the trained MET Model

saveRDS(MET_Model,paste(MODEL_FOLDER,MET_MODEL_FILE,sep = ""))


#Test the MET Estimation Model ---------------------------------------------------

#Load the Original Test data set

if(file.exists(paste(DATAFOLDER,TEST_DATAFILE,sep = "")))
{
  
  MET_test.df <- readRDS(paste(DATAFOLDER,TEST_DATAFILE,sep = ""))
  
} else {
  
  stop("No Test Data Found.")
  
}

#Load the Sedentary/Non-Sedentary trained model

if(file.exists(paste(MODEL_FOLDER,SDNT_NSDNT_MODEL_FILE,sep = ""))) {
  
  SDNT_Model <- readRDS(paste(MODEL_FOLDER,SDNT_NSDNT_MODEL_FILE,sep = ""))
  
  #Call the function for predictions
  MET_test.df <- FUN_Evaluate_Classifier(SDNT_Model,MET_test.df, CLASSIFIER_TYPE)
  
  #Rename the predicted output columns
  colnames(MET_test.df)[which(names(MET_test.df) == "PredictedTaskLabel")] <- "Sedentary"
  
  #Convert to Sedentary column to numeric type
  
  MET_test.df$Sedentary <- as.numeric(as.character(MET_test.df$Sedentary))
  
} else {
  
  stop("Sedentary/Non-Sedentary trained model not found.")
  
}

#Load the Locomotion/Stationary trained model

if(file.exists(paste(MODEL_FOLDER,LCM_STNRY_MODEL_FILE,sep = ""))) {
  
  LCM_Model <- readRDS(paste(MODEL_FOLDER,LCM_STNRY_MODEL_FILE,sep = ""))
  
  #Call the function for predictions
  MET_test.df <- FUN_Evaluate_Classifier(LCM_Model,MET_test.df, CLASSIFIER_TYPE)
  
  #Rename the predicted output columns
  colnames(MET_test.df)[which(names(MET_test.df) == "PredictedTaskLabel")] <- "Locomotion"
  
  #Convert to Locomotion column to numeric type
  
  MET_test.df$Locomotion <- as.numeric(as.character(MET_test.df$Locomotion))
  
} else {
  
  stop("Locomotion/Stationary trained model not found.")
  
}


#Add the MET values to the test dataframe

MET_test.df <- merge(x = MET_test.df, y = MET_Values.df[,c("PID","Task","METs")], by = c("PID","Task"))

#Rename the actual labels columns to test data

colnames(MET_test.df)[which(names(MET_test.df) == "METs")] <- "Actual_MET_Values"

#Load the MET Estimation trained model

if(file.exists(paste(MODEL_FOLDER,MET_MODEL_FILE,sep = ""))) {
  
  MET_Model <- readRDS(paste(MODEL_FOLDER,MET_MODEL_FILE,sep = ""))
  
  #Call the function for predictions
  
  MET_test.df <- FUN_Evaluate_MET_Regressor(MET_Model,MET_test.df,CLASSIFIER_TYPE)
  
  #Save the output MET predicted data to the csv file
  
  write.csv(MET_test.df[,c("PID","Task","Actual_MET_Values","Predicted_MET_Values")],
            paste(TESTDATA_OUTPUTFOLDER,TEST_OUT_FILE,sep = ""),row.names = FALSE)
  
} else {
  
  stop("MET Estimation trained model not found.")
  
}


# Compute Model Evaluation Parameters -------------------------------------

# Calculate the R-Squared Values

MET_R2_Score <- 1 - (sum((MET_test.df$Actual_MET_Values-MET_test.df$Predicted_MET_Values)^2)
                     /sum((MET_test.df$Actual_MET_Values-mean(MET_test.df$Actual_MET_Values))^2))

# Calculate the R-Squared Values

MET_RMSE_Score <- sqrt(mean((MET_test.df$Predicted_MET_Values-MET_test.df$Actual_MET_Values)^2))



# Print the Evaluation Values

print(paste("R-Squared Value :",MET_R2_Score))
print(paste("Root Mean Squared Error Value :",MET_RMSE_Score))

