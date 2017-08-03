#Script Details -------------------------------------------------------------------------------------------------------------

#Script Name : SCP_Demo_Script.R

#Script Summary : This script runs an end to end list of Data Cleaning and Activity Recognition tasks.

#Script execution sequence : 

#       1.  SCP_ConvertTaskTimeFile.R -- This script converts the taskTimes_all.csv to taskTimes_all.Rdata.
#       2.  SCP_Check_TaskTimes_Errors.R -- This script logs issues present in the taskTimes_all.Rdata file.
#       3.  SCP_CreateAccelerometerDataSubset.R -- This script creates subset of the raw accelerometer data.
#       4.  SCP_DownSampleData_AllParticipants.R -- This script creates downsampled subset data to 10Hz.
#       5.  SCP_Split_Train_Test_Participants.R -- This script splits the subset and the downsampled files into 
#                                                  training and testing set.
#       6.  SCP_1_Create_Subsequences_AllParticipants.R -- This script generates the 3s or 6s subsequences 
#                                                          for the training and testing downsampled files.
#       7.  SCP_2_Merge_All_Subsequences.R -- This script merges all the sub-sequences (3s or 6s) 
#                                             for the training and testing BOW files.
#       8.  SCP_3_Generate_CodeBook.R -- This script generates the codebook for 3s and 6s training set sub-sequences.
#       9.  SCP_4_Generate_Word_Labels.R -- This script generates the BOW word labels for 3s and 6s 
#                                           training and testing sub-sequences.
#      10.  SCP_5_Merge_Word_Label_Files.R -- This script merges all BOW word labels for 3s or 6s training 
#                                             and testing sub-sequences.
#      11.  SCP_6_Calculate_TF_IDF.R -- This script calculates the TF_IDF of 3s or 6s training and testing data set.
#      12.  SCP_Task_Category_Data_Classification.R -- This script classifies the cleaned data into two classes based on user input.
#      13.  SCP_Task_Level_Data_Classification.R -- This script classifies the cleaned data into sub-classes of the two main
#                                                   classes based on user input.
#      14.  SCP_One_Step_MET_Estimation.R -- This script calculates the MET estimated values using one step process 
#                                            based on user input.
#      15.  SCP_Two_Step_MET_Estimation.R -- This script calculates the MET estimated values using two step process 
#                                            based on user input.
#      16.  SCP_Three_Step_MET_Estimation.R -- This script calculates the MET estimated values using three step process 
#                                            based on user input.

#Script execution notes : --------------------------------------------------------------------------------------------------
#
#         1.Please ensure all that all the required parameters are set in each of the scripts before execution.
#
#         2.Please ensure the following directory structure :-
#
#                 a) Participant_Data - Store the raw accelerometer data folders for each participant in this folder.
#
#                         Inside Participant_Data Folder create the following folder structure :
#
#                             i) Original_SubSet   |-> Training_Set
#                                                  |-> Testing_Set 
#                             ii) Downsampled_Files |-> Training_Set
#                                                   |-> Testing_Set 
#                            iii) BOW_Files         |-> Three-second chunks |-> Training_Set
#                                                                           |-> Testing_Set 
#                                                   |-> Six-second chunks |-> Training_Set
#                                                                         |-> Testing_Set 
#                             iv) Cleaned_Data      |-> D32 |-> Training_Set
#                                                           |-> Testing_Set 
#                                                   |-> D64 |-> Training_Set
#                                                           |-> Testing_Set 
#                             v) Model_Output     |-> TaskCategory_Classification_Training_Model_Files
#                                                 |-> TaskCategory_Classification_Test_Output_Files 
#                                                 |-> Tasks_Classification_Training_Model_Files 
#                                                 |-> Tasks_Classification_Test_Output_Files 
#                                                 |-> MET_Estimation_Training_Model_Files 
#                                                 |-> MET_Estimation_Test_Output_Files 
#                              v) Logs
#
#       3. Please keep the taskTimes_all.csv file outside the folder Participant_Data.
#       4. Please keep the MET_values.Rdata in the Cleaned_Data folder.

#Author & Reviewer Details ---------------------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/21/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings ---------------------------------------------------------------------------------------------------

#Set the working directory to the location where this script is located. 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Task Times File Conversion and Issue Log Generation ------------------------------------------------------------------

#Sript 1 - SCP_ConvertTaskTimeFile.R

tryCatch(source("SCP_ConvertTaskTimeFile.R"), error=function(e){print(e)})

#Sript 2 - SCP_Check_TaskTimes_Errors.R

tryCatch(source("SCP_Check_TaskTimes_Errors.R"), error=function(e){print(e)})

#Important Note : After the execution of above two scripts, check the log files in the Logs folder 
#                 and correct the issues manually (if any) in the taskTimes_all.csv file and re-run Script 1 and 2 again.

#Data Subsetting and Downsampling Scripts -----------------------------------------------------------------------------

#Sript 3 - SCP_CreateAccelerometerDataSubset.R

tryCatch(source("SCP_CreateAccelerometerDataSubset.R"), error=function(e){print(e)})

#Sript 4 - SCP_DownSampleData_AllParticipants.R

tryCatch(source("SCP_DownSampleData_AllParticipants.R"), error=function(e){print(e)})

#Sript 5 - SCP_Split_Train_Test_Participants.R

tryCatch(source("SCP_Split_Train_Test_Participants.R"), error=function(e){print(e)})

# Bag of Words Sub-sequencing Generation Scripts ----------------------------------------------------------------------------

#Important Note : Run all the following scripts in this section for all the following combinations 
#                 of the two parameters CHUNKSIZE & FILETYPE :
#
#                 List of Valid Combinations:
#                                      a) CHUNKSIZE = 3 and FILETYPE = "Training_Set"
#                                      b) CHUNKSIZE = 3 and FILETYPE = "Testing_Set"
#                                      c) CHUNKSIZE = 6 and FILETYPE = "Training_Set"
#                                      d) CHUNKSIZE = 6 and FILETYPE = "Testing_Set"


#Sript 6 - SCP_1_Create_Subsequences_AllParticipants.R

tryCatch(source("SCP_1_Create_Subsequences_AllParticipants.R"), error=function(e){print(e)})

#Sript 7 - SCP_2_Merge_All_Subsequences.R

tryCatch(source("SCP_2_Merge_All_Subsequences.R"), error=function(e){print(e)})

# Codebook Learning & Generation Script ----------------------------------------------------------------------------

#Important Note : Run the following script in this section for all the following combinations 
#                 of the parameter CHUNKSIZE :
#
#                 List of Valid Combinations:
#                                      a) CHUNKSIZE = 3
#                                      b) CHUNKSIZE = 6

#Sript 8 - SCP_3_Generate_CodeBook.R

tryCatch(source("SCP_3_Generate_CodeBook.R"), error=function(e){print(e)})

# Bag of Words Label Generation Scripts ----------------------------------------------------------------------------

#Important Note : Run all the following scripts in this section for all the following combinations 
#                 of the two parameters CHUNKSIZE & FILETYPE :
#
#                 List of Valid Combinations:
#                                      a) CHUNKSIZE = 3 and FILETYPE = "Training_Set"
#                                      b) CHUNKSIZE = 3 and FILETYPE = "Testing_Set"
#                                      c) CHUNKSIZE = 6 and FILETYPE = "Training_Set"
#                                      d) CHUNKSIZE = 6 and FILETYPE = "Testing_Set"

#Sript 9 - SCP_4_Generate_Word_Labels.R

tryCatch(source("SCP_4_Generate_Word_Labels.R"), error=function(e){print(e)})

#Sript 10 - SCP_5_Merge_Word_Label_Files.R

tryCatch(source("SCP_5_Merge_Word_Label_Files.R"), error=function(e){print(e)})

# TF-IDF Calculation Script ----------------------------------------------------------------------------

#Important Note : Run all the following scripts in this section for all the following combinations 
#                 of the two parameters CHUNKSIZE & FILETYPE :
#
#                 List of Valid Combinations:
#                                      a) CHUNKSIZE = 3 and FILETYPE = "Training_Set"
#                                      b) CHUNKSIZE = 3 and FILETYPE = "Testing_Set"
#                                      c) CHUNKSIZE = 6 and FILETYPE = "Training_Set"
#                                      d) CHUNKSIZE = 6 and FILETYPE = "Testing_Set"
# In this script, the order of the combination is important. First execute for Training Set and then for Testing Set.

#Sript 11 - SCP_6_Calculate_TF_IDF.R

tryCatch(source("SCP_6_Calculate_TF_IDF.R"), error=function(e){print(e)})


# Activity Data Classification Scripts ----------------------------------------------------------------------------

# Important Note : Run the Script 12 in this section using the following combinations of CHUNKSIZE, CLASS_CATEGORY
#                  and CLASSIFIER_TYPE parameters :
#                  List of valid combinations :
#                             a) CHUNKSIZE = 3, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "SVM"
#                             b) CHUNKSIZE = 3, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "DecisionTree"
#                             c) CHUNKSIZE = 3, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "RandomForest"
#                             d) CHUNKSIZE = 6, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "SVM"
#                             e) CHUNKSIZE = 6, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "DecisionTree"
#                             f) CHUNKSIZE = 6, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "RandomForest"
#                             g) CHUNKSIZE = 3, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "SVM"
#                             h) CHUNKSIZE = 3, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "DecisionTree"
#                             i) CHUNKSIZE = 3, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "RandomForest"
#                             j) CHUNKSIZE = 6, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "SVM"
#                             k) CHUNKSIZE = 6, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "DecisionTree"
#                             l) CHUNKSIZE = 6, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "RandomForest"

# Run the Script 13 in this section using the following combinations of CHUNKSIZE, CLASS_CATEGORY and CLASSIFIER_TYPE parameters :
#                  List of valid combinations :
#                             a) CHUNKSIZE = 3, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "SVM"
#                             b) CHUNKSIZE = 3, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "DecisionTree"
#                             c) CHUNKSIZE = 3, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "RandomForest"
#                             d) CHUNKSIZE = 6, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "SVM"
#                             e) CHUNKSIZE = 6, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "DecisionTree"
#                             f) CHUNKSIZE = 6, CLASS_CATEGORY = "Sedentary", CLASSIFIER_TYPE = "RandomForest"
#                             g) CHUNKSIZE = 3, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "SVM"
#                             h) CHUNKSIZE = 3, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "DecisionTree"
#                             i) CHUNKSIZE = 3, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "RandomForest"
#                             j) CHUNKSIZE = 6, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "SVM"
#                             k) CHUNKSIZE = 6, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "DecisionTree"
#                             l) CHUNKSIZE = 6, CLASS_CATEGORY = "Locomotion", CLASSIFIER_TYPE = "RandomForest"

# Run the Script 14 in this section using the following combinations of CHUNKSIZE and CLASSIFIER_TYPE parameters :
#                             a) CHUNKSIZE = 3, CLASSIFIER_TYPE = "SVM"
#                             b) CHUNKSIZE = 3, CLASSIFIER_TYPE = "DecisionTree"
#                             c) CHUNKSIZE = 3, CLASSIFIER_TYPE = "RandomForest"
#                             d) CHUNKSIZE = 6, CLASSIFIER_TYPE = "SVM"
#                             e) CHUNKSIZE = 6, CLASSIFIER_TYPE = "DecisionTree"
#                             f) CHUNKSIZE = 6, CLASSIFIER_TYPE = "RandomForest"


#Sript 12 - SCP_Task_Category_Data_Classification.R

tryCatch(source("SCP_Task_Category_Data_Classification.R"), error=function(e){print(e)})

#Sript 13 - SCP_Task_Level_Data_Classification.R

tryCatch(source("SCP_Task_Level_Data_Classification.R"), error=function(e){print(e)})

#Sript 14 - SCP_One_Step_MET_Estimation.R

tryCatch(source("SCP_One_Step_MET_Estimation.R"), error=function(e){print(e)})

#Sript 15 - SCP_Two_Step_MET_Estimation.R

tryCatch(source("SCP_Two_Step_MET_Estimation.R"), error=function(e){print(e)})

#Sript 16 - SCP_Three_Step_MET_Estimation.R

tryCatch(source("SCP_Three_Step_MET_Estimation.R"), error=function(e){print(e)})

