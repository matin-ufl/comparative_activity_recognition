# ______________________________________________________
# Exact activity type identification inside Sedentary
# class.
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

training.df <- readRDS(file.choose())
test.df <- readRDS(file.choose())

# Class labels ----------------------
source("../../Utilities/FUN_PA_Labels_and_METs.R")
training.df$Locomotion <- sapply(as.character(training.df$Task), FUN = giveClassLabel_locomotion)
test.df$Locomotion <- sapply(as.character(test.df$Task), FUN = giveClassLabel_locomotion)
rm(giveClassLabel_sedentary, giveClassLabel_locomotion, giveMETIntensity, giveMETValue)

training.df <- training.df[training.df$Locomotion, -ncol(training.df)]
training.df$Task <- gsub(x = training.df$Task, pattern = " ", replacement = ".")
training.df$Task <- factor(training.df$Task, levels = levels(as.factor(as.character(training.df$Task))))
test.df <- test.df[test.df$Locomotion, -ncol(test.df)]
test.df$Task <- gsub(test.df$Task, pattern = " ", replacement = ".")
test.df$Task <- factor(test.df$Task, levels = levels(as.factor(as.character(test.df$Task))))


# Training phase --------------------
# SVM ========
library(e1071)
library(kernlab)
x <- training.df[, -c(1:2)]
y <- training.df$Task

# Finding the best fit ###############
set.seed(5855)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3, classProbs = T) # Leave-one-out-cross-validation is used for training.
svm.locType.tuned <- train(x = x,
                           y = y,
                           trControl = ctrl,
                           method = "svmLinear",
                           metric = "Accuracy")

# Saving the trained classifier for future use
save(svm.locType.tuned, file = "Trained models/locomotion_type_SVM.Rdata")

# Evaluation on test set #############
svm.out <- data.frame(PID = test.df$PID, Actual = test.df$Task, Predicted = NA)
svm.out$Predicted <- predict(svm.locType.tuned, test.df[, -c(1:2)])

# saving the output on test set for future analysis.
write.csv(svm.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/Locomotion_Type_SVM.csv", row.names = F)
table(svm.out[, -1])


# Decision Tree ========
library(rpart)
x <- training.df[, -c(1:2)]
y <- training.df$Task

# Finding the best fit ###############
set.seed(5855)
ctrl <- trainControl(method = "LOOCV", classProbs = T) # Leave-one-out-cross-validation is used for training.
decisionTree.locType.tuned <- train(x = x,
                                    y = y,
                                    trControl = ctrl,
                                    method = "rpart",
                                    metric = "Accuracy")

# Saving the trained classifier for future use
save(decisionTree.locType.tuned, file = "Trained models/locomotion_type_decisionTree.Rdata")

# Evaluation on test set #############
decisionTree.out <- data.frame(PID = test.df$PID, Actual = test.df$Task, Predicted = NA)
decisionTree.out$Predicted <- predict(decisionTree.locType.tuned, test.df[, -c(1:2)])

# saving the output on test set for future analysis.
write.csv(decisionTree.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/Locomotion_Type_decisionTree.csv", row.names = F)
table(decisionTree.out[, -1])


# Random Forest ========
library(randomForest)
x <- training.df[, -c(1:2)]
y <- training.df$Task

# Finding the best fit ###############

ctrl <- trainControl(method = "oob", classProbs = T)
nTree <- 1500 # This is altered to find the best combination (ntree, mtry)
mtry <- 2:4
tunegrid <- expand.grid(.mtry=mtry)
set.seed(5855)
randomForest.locType.tuned <- train(x = x, y = y, method = "rf", metric = "Accuracy", tuneGrid = tunegrid, trControl = ctrl, ntree = nTree)
randomForest.locType.tuned$results

# Saving the trained classifier for future use (Best: ntree = 1500, mtry = 4)
save(randomForest.locType.tuned, file = "Trained models/locomotion_type_randomForest.Rdata")

# Evaluation on test set #############
randomForest.out <- data.frame(PID = test.df$PID, Actual = test.df$Task, Predicted = NA)
randomForest.out$Predicted <- predict(randomForest.locType.tuned, test.df[, -c(1:2)])

# saving the output on test set for future analysis.
write.csv(randomForest.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/Locomotion_Type_randomForest.csv", row.names = F)
table(randomForest.out[, -1])
