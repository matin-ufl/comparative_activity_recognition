#Script Details -------------------------------------------------------------------------------------------------

#Script Name : Master_Script.R

#Script Summmary : Constructs unigram and bigram features for given dataset 
#                  and saves the corresponding feature data files

#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Madhurima Nath
#Date : 07/11/2017
#E-Mail : madhurima09@ufl.edu
#Reviewed By : Shikha Mehta
#Review Date : 
#Reviewer E-Mail : shikha.mehta@ufl.edu

#----------------------------------------------------------------------------------------------------------------

#Parameter Settings----------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------------------------------

#Parameter Settings----------------------------------------------------------------------------------------------

# Set the working directory to the location where the scripts and function R files are located
setwd("/home/sumi/Documents/Research_Project/Scripts/")

# Set the full path where training set Rdata file is located
TRAININGDATAFOLDER <- "/home/sumi/Documents/Research_Project/Participant_Data/Training_Data/"
# Set the full path where test set Rdata file is located
TESTINGDATAFOLDER <- "/home/sumi/Documents/Research_Project/Participant_Data/Test_Data/"
# Set the type of nGram features to use (Unigrams/Bigrams)


#----------------------------------------------------------------------------------------------------------------

source("FUN_Classifiers.R")

# Fetch the data sets and add class variables to identify tasks as Sedentary/Non-sedentary & Locomotion/Stationary
training.df<-FUN_prepareForclassification(TRAININGDATAFOLDER,"dtw")
testing.df<-FUN_prepareForclassification(TESTINGDATAFOLDER,"dtw")

# Ensure that all feature columns exist in training and testing set
names <- colnames(training.df)
Missing <- setdiff(names, names(testing.df))  # Find names of missing columns in testing.df
testing.df[Missing] <- 0                    # Add them, filled with 0s

# ------Comment this section for SVM as the model may run into zero variability issues------ #
names <- colnames(testing.df)
Missing <- setdiff(names, names(training.df))  # Find names of missing columns in training.df
training.df[Missing] <- 0                    # Add them, filled with 0s
# ------------------------------------------------------------------------------------------ #

rm(names,Missing)

# Classify and compute Precision, Recall and F1-Score of Support Vector Machine
output_SVM.df<-FUN_svm.classification(training.df,testing.df)
View(output_SVM.df)

# Classify and compute Precision, Recall and F1-Score of Random Forest
output_RF.df<-FUN_randomForest.classification(training.df,testing.df)
View(output_RF.df)