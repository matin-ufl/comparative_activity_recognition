#Script Details -------------------------------------------------------------------------------------------------

#Script Name : FUN_Classifiers.R

#Script Summmary : This script contains five functions required for classification.
#     1. FUN_prepareForclassification: Function to prepare dataset for classification
#     2. FUN_svm.classification: Function to train SVM classifier and predict labels for test data
#     3. FUN_naiveBayes.classification: Function to train Naive Bayes classifier and predict labels for test data
#     4. FUN_randomForest.classification: Function to train Random Forest classifier and predict labels for test data
#     5. FUN_getResults: Function to get the confusion matrix and required metrics from predicted vs actual values

#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Shikha Mehta
#Date : 07/08/2017
#E-Mail : shikha.mehta@ufl.edu
#Reviewed By : Madhurima Nath
#Review Date : 
#Reviewer E-Mail : madhurima09@ufl.edu

#----------------------------------------------------------------------------------------------------------------


# Input:
#     1. dataFolder: full path where Rdata files for ngram features are located
#     2. nGramType: ngram type identifier to determine the features file to read (Unigrams/Bigrams)
#
# Output:
#     Returns a data frame consisting of features and class variables of Sedentary/Non-sedentary & Locomotion/Stationary
#
FUN_prepareForclassification<-function(dataFolder,ngramType)
{
  if(ngramType=="Unigrams")
  {
    filename<-dir(dataFolder, pattern = "^.*UnigramFeatures.Rdata$")
  }
  else          #Bigrams
  {
    filename<-dir(dataFolder, pattern = "^.*BigramFeatures.Rdata$")
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
  # confusion.matrix.sedentary <- FUN_getResults(svm.predicted,testing.df$class.sedentary)[[1]]
  # View(confusion.matrix.sedentary)
  # --------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Sedentary data
  sedentary.metrics <- FUN_getResults(svm.predicted,testing.df$class.sedentary)[[2]]
  
  # Locomotion classification
  svm.model <- svm(data = training.df, class.locomotion ~ .)
  svm.predicted <- predict(svm.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Locomotion data--- #
  # confusion.matrix.locomotion <- FUN_getResults(svm.predicted,testing.df$class.locomotion)[[1]]
  # View(confusion.matrix.locomotion)
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
#     1. training.df: data frame consisting of features and class variables to train the Naive Bayes classifier
#     2. testing.df: data frame consisting of features and class variables to test the Naive Bayes classifier
#
# Output:
#     Returns a data frame consisting of Precision, Recall and F1-Score metrics
#     of predicting Sedentary and Locomotion classes using Naive Bayes classifier
#
FUN_naiveBayes.classification<-function(training.df,testing.df)
{
  library(e1071)
  
  # Sedentary classification
  nb.model <- naiveBayes(data = training.df, class.sedentary ~ .)
  nb.predicted <- predict(nb.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Sedentary data--- #
  # confusion.matrix.sedentary <- FUN_getResults(nb.predicted,testing.df$class.sedentary)[[1]]
  # View(confusion.matrix.sedentary)
  # --------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Sedentary data
  sedentary.metrics <- FUN_getResults(nb.predicted,testing.df$class.sedentary)[[2]]
  
  # Locomotion classification
  nb.model <- naiveBayes(data = training.df, class.locomotion ~ .)
  nb.predicted <- predict(nb.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Locomotion data--- #
  # confusion.matrix.locomotion <- FUN_getResults(nb.predicted,testing.df$class.locomotion)[[1]]
  # View(confusion.matrix.locomotion)
  # ---------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Locomotion data
  locomotion.metrics <- FUN_getResults(nb.predicted,testing.df$class.locomotion)[[2]]
  
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
  # confusion.matrix.sedentary <- FUN_getResults(rf.predicted,testing.df$class.sedentary)[[1]]
  # View(confusion.matrix.sedentary)
  # --------------------------------------------------------------------------------- #
  
  # Get Precision, Recall and F1-Score metrics for Sedentary data
  sedentary.metrics <- FUN_getResults(rf.predicted,testing.df$class.sedentary)[[2]]
  
  # Locomotion classification
  rf.model <- randomForest(data = training.df, class.locomotion ~ .)
  rf.predicted <- predict(rf.model, testing.df)
  
  # ---Uncomment following section to view the confusion matrix for Locomotion data--- #
  # confusion.matrix.locomotion <- FUN_getResults(rf.predicted,testing.df$class.locomotion)[[1]]
  # View(confusion.matrix.locomotion)
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
