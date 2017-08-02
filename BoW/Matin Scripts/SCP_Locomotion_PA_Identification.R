# ______________________________________________________
# Locomotion vs Stationary classification using
# statistical variables.
#
# Classifiers used in this script:
#     1. SVM
#     2. Decision Tree
#     3. Random Forest
#
# ______________
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)
# ______________________________________________________
setwd("~/Workspaces/R workspace/Comparative Activity Recognition/BoW/Matin Scripts/")
LOCOMOTION_LABEL <- "Loc"
STATIONARY_LABEL <- "Sta"



training.df <- readRDS(file.choose())
test.df <- readRDS(file.choose())

# Class labels ----------------------
source("../../Utilities/FUN_PA_Labels_and_METs.R")
training.df$Locomotion <- sapply(as.character(training.df$Task), FUN = giveClassLabel_locomotion)
test.df$Locomotion <- sapply(as.character(test.df$Task), FUN = giveClassLabel_locomotion)
rm(giveClassLabel_sedentary, giveClassLabel_locomotion, giveMETIntensity, giveMETValue)


# Training phase --------------------
# SVM ========
library(e1071)
library(kernlab)
x <- training.df[, -c(1:2, ncol(training.df))]
y <- sapply(training.df$Locomotion, FUN = function(x) {if(x){return(LOCOMOTION_LABEL)}else{return(STATIONARY_LABEL)}})
y <- factor(y, levels = c(LOCOMOTION_LABEL, STATIONARY_LABEL))

# Finding the best fit ###############
set.seed(5855)
ctrl <- trainControl(method = "LOOCV", classProbs = T) # Leave-one-out-cross-validation is used for training.
svm.locomotion.tuned <- train(x = x,
                              y = y,
                              trControl = ctrl,
                              method = "svmLinear",
                              metric = "Kappa") # Using Kappa as the metric to be maximized, since the dataset is not balanced.

# Saving the trained classifier for future use
save(svm.locomotion.tuned, file = "Trained models/locomotion_SVM.Rdata")

# Evaluation on test set #############
svm.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$Locomotion, Predicted = NA)
svm.out$Actual <- sapply(svm.out$Actual, FUN = function(x) {if(x){return(LOCOMOTION_LABEL)}else{return(STATIONARY_LABEL)}})
svm.out$Predicted <- predict(svm.locomotion.tuned, test.df[, -c(1:2, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(svm.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/Locomotion_SVM.csv", row.names = F)

source("../../Utilities/FUN_Evaluation_Metrics.R")
paste("Locomotion - SVM: Accuracy (", round(calculate.accuracy(svm.out$Actual, svm.out$Predicted), digits = 2), "), ",
      "Sensitivty (", round(calculate.sensitivity(svm.out$Actual, svm.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), "), ",
      "Precision (", round(calculate.precision(svm.out$Actual, svm.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), "), ",
      "F1-score (", round(calculate.f1score(svm.out$Actual, svm.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), ")", sep = "")



# Decision Tree =========
library(rpart)
x <- training.df[, -c(1:2, ncol(training.df))]
y <- sapply(training.df$Locomotion, FUN = function(x) {if(x){return(LOCOMOTION_LABEL)}else{return(STATIONARY_LABEL)}})
y <- factor(y, levels = c(LOCOMOTION_LABEL, STATIONARY_LABEL))

# Finding the best fit ###########
set.seed(5855)
ctrl <- trainControl(method = "LOOCV", classProbs = T)
decisionTree.locomotion.tuned <- train(x = x, y = y,
                                       trControl = ctrl,
                                       method = "rpart",
                                       metric = "Kappa") # Using Kappa as the metric to be optimized, since the dataset is not balanced.

# Saving the trained classifier for future use
save(decisionTree.locomotion.tuned, file = "Trained models/locomotion_decisionTree.Rdata")

# Evaluation on test set #############
decisionTree.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$Locomotion, Predicted = NA)
decisionTree.out$Actual <- sapply(decisionTree.out$Actual, FUN = function(x) {if(x){return(LOCOMOTION_LABEL)}else{return(STATIONARY_LABEL)}})
decisionTree.out$Predicted <- predict(decisionTree.locomotion.tuned, test.df[, -c(1:2, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(decisionTree.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/Locomotion_decisionTree.csv", row.names = F)

source("../../Utilities/FUN_Evaluation_Metrics.R")
paste("Locomotion - Decision Tree: Accuracy (", round(calculate.accuracy(decisionTree.out$Actual, decisionTree.out$Predicted), digits = 2), "), ",
      "Sensitivty (", round(calculate.sensitivity(decisionTree.out$Actual, decisionTree.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), "), ",
      "Precision (", round(calculate.precision(decisionTree.out$Actual, decisionTree.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), "), ",
      "F1-score (", round(calculate.f1score(decisionTree.out$Actual, decisionTree.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), ")", sep = "")



# Random Forest =========
library(randomForest)
x <- training.df[, -c(1:2, ncol(training.df))]
y <- sapply(training.df$Locomotion, FUN = function(x) {if(x){return(LOCOMOTION_LABEL)}else{return(STATIONARY_LABEL)}})
y <- factor(y, levels = c(LOCOMOTION_LABEL, STATIONARY_LABEL))

# Finding the best fit #########

ctrl <- trainControl(method = "oob", classProbs = T)
nTree <- 5000 # This is altered to find the best combination (ntree, mtry)
mtry <- 2:4
tunegrid <- expand.grid(.mtry=mtry)
set.seed(5855)
randomForest.locomotion.tuned <- train(x = x, y = y, method = "rf", metric = "Kappa", tuneGrid = tunegrid, trControl = ctrl, ntree = nTree)

# The best model was found for ntree = 5000 and mtry = 4
save(randomForest.locomotion.tuned, file = "Trained models/locomotion_randomForest.Rdata")

# Evaluation on test set ########
randomForest.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$Locomotion, Predicted = NA)
randomForest.out$Actual <- sapply(randomForest.out$Actual, FUN = function(x) {if(x){return(LOCOMOTION_LABEL)}else{return(STATIONARY_LABEL)}})
randomForest.out$Predicted <- predict(randomForest.locomotion.tuned, test.df[, -c(1:2, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(randomForest.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/Locomotion_randomForest.csv", row.names = F)

source("../../Utilities/FUN_Evaluation_Metrics.R")
paste("Locomotion - Random Forest: Accuracy (", round(calculate.accuracy(randomForest.out$Actual, randomForest.out$Predicted), digits = 2), "), ",
      "Sensitivty (", round(calculate.sensitivity(randomForest.out$Actual, randomForest.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), "), ",
      "Precision (", round(calculate.precision(randomForest.out$Actual, randomForest.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), "), ",
      "F1-score (", round(calculate.f1score(randomForest.out$Actual, randomForest.out$Predicted, positive.class = LOCOMOTION_LABEL), digits = 2), ")", sep = "")

