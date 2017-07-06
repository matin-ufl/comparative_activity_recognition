# Classification results

setwd("C:/Users/shikh/Documents/University of Florida/Activity Recognition/Classification/")
source("Classifiers.R")

dataFolder <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Training_Set/nGram_Files/"
training.df<-prepare_for_classification(dataFolder,"Bigrams")

dataFolder <- "C:/Users/shikh/Documents/University of Florida/Activity Recognition/Datasets/Raw Data/Testing_Set/nGram_Files/"
testing.df<-prepare_for_classification(dataFolder,"Bigrams")

names <- colnames(training.df)
Missing <- setdiff(names, names(testing.df))  # Find names of missing columns in testing.df
testing.df[Missing] <- 0                    # Add them, filled with 0s

# ---Comment this section for SVM as the model may run into zero variability issues--- #
names <- colnames(testing.df)
Missing <- setdiff(names, names(training.df))  # Find names of missing columns in training.df
training.df[Missing] <- 0                    # Add them, filled with 0s
# ------------------------------------------------------------------------------------ #
  
rm(names,Missing)

# SVM =================================================
output_SVM.df<-svm_classify(training.df,testing.df)

# Naive Bayes ========================================
output_NB.df<-naive_bayes_classify(training.df,testing.df)

# Random Forest =========================================
output_RF.df<-random_forest_classify(training.df,testing.df)
