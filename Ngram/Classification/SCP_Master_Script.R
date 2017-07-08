#Script Details -------------------------------------------------------------------------------------------------

#Script Name : SCP_Master_Script.R

#Script Summmary : Generate Accuracy, Sensitivity and Specificity metrics 
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

# Set the working directory to the location where the scripts and function R files are located
setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/Classification/")

# Set the full path where training set Rdata file is located
TRAININGDATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Training_Set/nGram_Files/"
# Set the full path where test set Rdata file is located
TESTINGDATAFOLDER <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Testing_Set/nGram_Files/"
# Set the type of nGram features to use (Unigrams/Bigrams)
NGRAMTYPE <- "Unigrams"

source("FUN_Classifiers.R")

# Fetch the data sets and add class variables to identify tasks as Sedentary/Non-sedentary & Locomotion/Stationary
training.df<-prepareForclassification(TRAININGDATAFOLDER,NGRAMTYPE)
testing.df<-prepareForclassification(TESTINGDATAFOLDER,NGRAMTYPE)

# Ensure that all feature columns exist in training and testing set
names <- colnames(training.df)
Missing <- setdiff(names, names(testing.df))  # Find names of missing columns in testing.df
testing.df[Missing] <- 0                    # Add them, filled with 0s

# ---Comment this section for SVM as the model may run into zero variability issues--- #
names <- colnames(testing.df)
Missing <- setdiff(names, names(training.df))  # Find names of missing columns in training.df
training.df[Missing] <- 0                    # Add them, filled with 0s
# ------------------------------------------------------------------------------------ #
  
rm(names,Missing)

# Find classification Accuracy, Sensitivity and Specificity of Support Vector Machine 
output_SVM.df<-svm.classification(training.df,testing.df)
View(output_SVM.df)

# Find classification Accuracy, Sensitivity and Specificity of Naive Bayes technique
output_NB.df<-naiveBayes.classification(training.df,testing.df)
View(output_NB.df)

# Find classification Accuracy, Sensitivity and Specificity of Random Forest
output_RF.df<-randomForest.classification(training.df,testing.df)
View(output_RF.df)
