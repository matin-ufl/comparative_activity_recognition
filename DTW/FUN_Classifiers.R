#Script Details -------------------------------------------------------------------------------------------------

#Script Name : FUN_Classifiers.R

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

# Input:
#     1. dataFolder: full path of dtw/ddtw features Rdata files 
#     2. dtwType: dtw type identifier 
#
# Output:
#     Returns a data frame consisting of features and class variables of Sedentary/Non-sedentary & Locomotion/Stationary
#

#dataFolder <- "/home/sumi/Documents/Research_Project/Participant_Data/R_DataFiles/"

FUN_prepareForclassification<-function(dataFolder,dtwType)
{
  if(dtwType=="dtw")
  {
    filename<-dir(dataFolder, pattern = "^.*dtwFeatures.RData$")
  }
  else          #Bigrams
  {
    filename<-dir(dataFolder, pattern = "^.*ddtwFeatures.Rdata$")
  }
  features.df=readRDS(paste(dataFolder, filename, sep = ""))
  features.df$Task <- as.factor(features.df$Task)
  features.df$class.locomotion <- "No"
  features.df$class.locomotion[features.df$Task %in% c("LEISURE WALK", "RAPID WALK", "WALKING AT RPE 1", "WALKING AT RPE 5", "STAIR ASCENT", "STAIR DESCENT")] <- "Yes"
  features.df$class.sedentary <- "No"
  features.df$class.sedentary[features.df$Task %in% c("COMPUTER WORK", "TV WATCHING", "STANDING STILL")] <- "Yes"
  
  # Discarding Task and PID columns
  features.df <- as.data.frame(features.df[ , -which(names(features.df) %in% c("Task","PID"))],stringAsFactors=TRUE)
  
  # Converting the class-label column to factor
  features.df$class.sedentary <- as.factor(features.df$class.sedentary)
  features.df$class.locomotion <- as.factor(features.df$class.locomotion)
  features.df  
}


# Input:
#     1. training.df: data frame consisting of features and class variables to train the Support Vector Machine classifier
#     2. testing.df: data frame consisting of features and class variables to test the Support Vector Machine classifier
#
# Output:
#     Returns a data frame consisting of Precision, Recall and F1-Score metrics
#     of predicting Sedentary and Locomotion classes using Support Vector Machine classifier
#
FUN_svm.classification<-function(training.df,testing.df)
{
  library(e1071)
  
  # Sedentary classification
  svm.model <- svm(data = training.df, class.sedentary ~ .)
  svm.predicted <- predict(svm.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Sedentary data--- #
  confusion.matrix.sedentary <- FUN_getResults(svm.predicted,testing.df$class.sedentary)[[1]]
  View(confusion.matrix.sedentary)
  # --------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Sedentary data
  sedentary.metrics <- FUN_getResults(svm.predicted,testing.df$class.sedentary)[[2]]
  
  # Locomotion classification
  svm.model <- svm(data = training.df, class.locomotion ~ .)
  svm.predicted <- predict(svm.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Locomotion data--- #
  confusion.matrix.locomotion <- FUN_getResults(svm.predicted,testing.df$class.locomotion)[[1]]
  View(confusion.matrix.locomotion)
  # ---------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Locomotion data
  locomotion.metrics <- FUN_getResults(svm.predicted,testing.df$class.locomotion)[[2]]
  
  table <- matrix(c(sedentary.metrics,locomotion.metrics),ncol=3,byrow=TRUE)
  colnames(table) <- c("Precision","Recall","F1-Score")
  rownames(table) <- c("Sedentary","Locomotion")
  output.df <- as.data.frame(table)
  output.df 
}



# Input:
#     1. training.df: data frame consisting of features and class variables to train the Random Forest classifier
#     2. testing.df: data frame consisting of features and class variables to test the Random Forest classifier
#
# Output:
#     Returns a data frame consisting of Precision, Recall and F1-Score metrics
#     of predicting Sedentary and Locomotion classes using Random Forest classifier
#
FUN_randomForest.classification<-function(training.df,testing.df)
{
  library(randomForest)
  set.seed(5855)
  
  # Sedentary classification
  rf.model <- randomForest(data = training.df, class.sedentary ~ .)
  rf.predicted <- predict(rf.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Sedentary data--- #
  confusion.matrix.sedentary <- FUN_getResults(rf.predicted,testing.df$class.sedentary)[[1]]
  View(confusion.matrix.sedentary)
  # --------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Sedentary data
  sedentary.metrics <- FUN_getResults(rf.predicted,testing.df$class.sedentary)[[2]]
  
  # Locomotion classification
  rf.model <- randomForest(data = training.df, class.locomotion ~ .)
  rf.predicted <- predict(rf.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Locomotion data--- #
  confusion.matrix.locomotion <- FUN_getResults(rf.predicted,testing.df$class.locomotion)[[1]]
  View(confusion.matrix.locomotion)
  # ---------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Locomotion data
  locomotion.metrics <- FUN_getResults(rf.predicted,testing.df$class.locomotion)[[2]]
  
  table <- matrix(c(sedentary.metrics,locomotion.metrics),ncol=3,byrow=TRUE)
  colnames(table) <- c("Precision","Recall","F1-Score")
  rownames(table) <- c("Sedentary","Locomotion")
  output.df <- as.data.frame(table)
  output.df
}


# Input:
#     1. predicted: vector of labels predicted by a classifier
#     2. actual: corresponding vector of actual values/class labels
#
# Output:
#     Returns a list consisting of
#     1. confusion matrix from predicted vs actual data
#     2. a vector of Precision, Recall and F1-Score values
#
FUN_getResults<-function(predicted,actual)
{
  library(caret)
  
  # Generate the confusion matrix of the test data
  cf <- confusionMatrix(predicted, actual)
  
  # Generate F1-score, Precision and Sensitivity metrics
  precision <- posPredValue(predicted, actual)
  recall <- sensitivity(predicted, actual)
  F1.score <- (2 * precision * recall) / (precision + recall)
  
  return (list(cf$table,c(precision,recall,F1.score)))
}