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
prepareForclassification<-function(dataFolder,ngramType)
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
#     Returns a data frame consisting of Accuracy, Sensitivity and Specificity metrics
#     of predicting Sedentary and Locomotion classes using Support Vector Machine classifier
#
svm.classification<-function(training.df,testing.df)
{
  library(e1071)
  svm.model <- svm(data = training.df, class.sedentary ~ .)
  svm.predicted <- predict(svm.model, testing.df)
  svm.outcome <- data.frame(actual = as.character(testing.df$class.sedentary), predicted = as.character(svm.predicted))
  
  confusion.matrix <- table(svm.outcome)
  AccuracyS <- round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2)
  SensitivityS <- round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2)
  SpecificityS <- round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2)
  
  paste("SVM: AccuracyS (", round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2), ") & ",
        "SensitivityS (", round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2), ") & ",
        "SpecificityS (", round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2), ")", sep = "")
  
  svm.model <- svm(data = training.df, class.locomotion ~ .)
  svm.predicted <- predict(svm.model, testing.df)
  svm.outcome <- data.frame(actual = as.character(testing.df$class.locomotion), predicted = as.character(svm.predicted))
  
  confusion.matrix <- table(svm.outcome)
  AccuracyL <- round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2)
  SensitivityL <- round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2)
  SpecificityL <- round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2)
  
  paste("SVM: AccuracyL (", round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2), ") & ",
        "SensitivityL (", round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2), ") & ",
        "SpecificityL (", round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2), ")", sep = "")
  
  table <- matrix(c(AccuracyS,SensitivityS,SpecificityS,AccuracyL,SensitivityL,SpecificityL),ncol=3,byrow=TRUE)
  colnames(table) <- c("Accuracy","Sensitivity","Specificity")
  rownames(table) <- c("Sedentary","Locomotion")
  output.df <- as.data.frame(table)
  output.df 
}


# Input:
#     1. training.df: data frame consisting of features and class variables to train the Naive Bayes classifier
#     2. testing.df: data frame consisting of features and class variables to test the Naive Bayes classifier
#
# Output:
#     Returns a data frame consisting of Accuracy, Sensitivity and Specificity metrics
#     of predicting Sedentary and Locomotion classes using Naive Bayes classifier
#
naiveBayes.classification<-function(training.df,testing.df)
{
  library(e1071)
  nb.model <- naiveBayes(data = training.df, class.sedentary ~ .)
  nb.predicted <- predict(nb.model, testing.df)
  nb.outcome <- data.frame(actual = as.character(testing.df$class.sedentary), predicted = as.character(nb.predicted))
  
  confusion.matrix <- table(nb.outcome)
  AccuracyS <- round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2)
  SensitivityS <- round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2)
  SpecificityS <- round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2)
  
  paste("Naive Bayes: AccuracyS (", round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2), ") & ",
        "SensitivityS (", round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2), ") & ",
        "SpecificityS (", round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2), ")", sep = "")
  
  nb.model <- naiveBayes(data = training.df, class.locomotion ~ .)
  nb.predicted <- predict(nb.model, testing.df)
  nb.outcome <- data.frame(actual = as.character(testing.df$class.locomotion), predicted = as.character(nb.predicted))
  
  confusion.matrix <- table(nb.outcome)
  AccuracyL <- round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2)
  SensitivityL <- round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2)
  SpecificityL <- round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2)
  
  paste("Naive Bayes: AccuracyL (", round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2), ") & ",
        "SensitivityL (", round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2), ") & ",
        "SpecificityL (", round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2), ")", sep = "")
  
  table <- matrix(c(AccuracyS,SensitivityS,SpecificityS,AccuracyL,SensitivityL,SpecificityL),ncol=3,byrow=TRUE)
  colnames(table) <- c("Accuracy","Sensitivity","Specificity")
  rownames(table) <- c("Sedentary","Locomotion")
  output.df <- as.data.frame(table)
  output.df 
}


# Input:
#     1. training.df: data frame consisting of features and class variables to train the Random Forest classifier
#     2. testing.df: data frame consisting of features and class variables to test the Random Forest classifier
#
# Output:
#     Returns a data frame consisting of Accuracy, Sensitivity and Specificity metrics
#     of predicting Sedentary and Locomotion classes using Random Forest classifier
#
randomForest.classification<-function(training.df,testing.df)
{
  library(randomForest)
  set.seed(5855)
  
  # Sedentary classification --------------------------
  rf.model <- randomForest(data = training.df, class.sedentary ~ .)
  rf.predicted <- predict(rf.model, testing.df)
  rf.outcome <- data.frame(actual = as.character(testing.df$class.sedentary), predicted = as.character(rf.predicted))
  
  confusion.matrix <- table(rf.outcome)
  AccuracyS <- round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2)
  SensitivityS <- round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2)
  SpecificityS <- round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2)
  
  paste("Random Forest: AccuracyS (", round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2), ") & ",
        "SensitivityS (", round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2), ") & ",
        "SpecificityS (", round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2), ")", sep = "")
  
  # Locomotion classification --------------------------
  rf.model <- randomForest(data = training.df, class.locomotion ~ .)
  rf.predicted <- predict(rf.model, testing.df)
  rf.outcome <- data.frame(actual = as.character(testing.df$class.locomotion), predicted = as.character(rf.predicted))
  
  confusion.matrix <- table(rf.outcome)
  AccuracyL <- round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2)
  SensitivityL <- round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2)
  SpecificityL <- round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2)
  
  paste("Random Forest: AccuracyL (", round((confusion.matrix[1, 1] + confusion.matrix[2, 2]) / sum(confusion.matrix) * 100, digits = 2), ") & ",
        "SensitivityL (", round((confusion.matrix[2, 2]) / sum(confusion.matrix[, 2]), digits = 2), ") & ",
        "SpecificityL (", round((confusion.matrix[1, 1]) / sum(confusion.matrix[, 1]), digits = 2), ")", sep = "")

  table <- matrix(c(AccuracyS,SensitivityS,SpecificityS,AccuracyL,SensitivityL,SpecificityL),ncol=3,byrow=TRUE)
  colnames(table) <- c("Accuracy","Sensitivity","Specificity")
  rownames(table) <- c("Sedentary","Locomotion")
  output.df <- as.data.frame(table)
  output.df
}
