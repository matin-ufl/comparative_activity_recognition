#Script Details -------------------------------------------------------------------------------------------------

#Script Name : SCP_Master_Script.R

#Script Summmary : Generates Precision, Recall and F1-Score metrics 
#                  usings classifiers - SVM, Naive Bayes and Random Forest
#                  on training and test set of ngram features

#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Shikha Mehta
#Date : 07/08/2017
#E-Mail : shikha.mehta@ufl.edu
#Reviewed By : Madhurima Nath
#Review Date : 
#Reviewer E-Mail : madhurima09@ufl.edu

#----------------------------------------------------------------------------------------------------------------

#Parameter Settings----------------------------------------------------------------------------------------------

# Set the working directory to the location where the scripts and function R files are located
setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/Classification/")

# Set the full path where training set Rdata file is located
TRAININGDATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Raw Data/Participant Data/Training_Set/nGram_Files/Bins=30/"
# Set the full path where test set Rdata file is located
TESTINGDATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Raw Data/Participant Data/Testing_Set/nGram_Files/Bins=30/"
# Set the type of nGram features to use (Unigrams/Bigrams)
NGRAMTYPE <- "Bigrams"

#----------------------------------------------------------------------------------------------------------------

source("FUN_Classifiers.R")

# Fetch the data sets and add class variables to identify tasks as Sedentary/Non-sedentary & Locomotion/Stationary
training.df<-FUN_prepareForclassification(TRAININGDATAFOLDER,NGRAMTYPE)
testing.df<-FUN_prepareForclassification(TESTINGDATAFOLDER,NGRAMTYPE)

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

# Classify and compute Precision, Recall and F1-Score of Naive Bayes technique
output_NB.df<-FUN_naiveBayes.classification(training.df,testing.df)
View(output_NB.df)

# Classify and compute Precision, Recall and F1-Score of Random Forest
output_RF.df<-FUN_randomForest.classification(training.df,testing.df)
View(output_RF.df)
