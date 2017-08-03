# ______________________________________________________
# Energy expenditure estimation using statistical
# variables. Three estimation models are used:
#     1-step: original variables are passed to
#                the model.
#     2-step: PA predicted labels for <Sedentary,
#             Locomotion> are also passed to the
#             model.
#     3-step: PA exact activity type is also predicted
#             and passed to the model.
#
# Regressors used in this script:
#     1. SVM
#     2. Decision Tree
#     3. Random Forest
#
# ______________
# Matin Kheirkhahan (matinkheirkhahan@ufl.edu)
# ______________________________________________________

setwd("~/Workspaces/R workspace/Comparative Activity Recognition/Statisical Model/")
training.df <- readRDS(file.choose())
test.df <- readRDS(file.choose())

# Class labels ----------------------
source("../Utilities/FUN_PA_Labels_and_METs.R")
training.df$MET <- NA
for(i in 1:nrow(training.df)) {
     training.df$MET[i] <- giveMETValue(as.character(training.df$PID[i]), as.character(training.df$Task[i]))
}
rm(i)
na_indeces <- which(is.na(training.df$MET))
print(paste(length(na_indeces), "observations had no MET values in the training set with", nrow(training.df), "samples."))
training.df <- training.df[complete.cases(training.df), ]

test.df$MET <- NA
for(i in 1:nrow(test.df)) {
     test.df$MET[i] <- giveMETValue(as.character(test.df$PID[i]), as.character(test.df$Task[i]))
}
rm(i)
na_indeces <- which(is.na(test.df$MET))
print(paste(length(na_indeces), "observations had no MET values in the test set with", nrow(test.df), "samples."))
test.df <- test.df[complete.cases(test.df), ]

rm(giveClassLabel_sedentary, giveClassLabel_locomotion, giveMETIntensity, giveMETValue, na_indeces)



# One step energy expenditure ---------------------------------
# SVR ========================
library(caret)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(5855)
svr.statistical.oneStep.tuned <- train(x = training.df[, -c(1:4, ncol(training.df))], y = training.df$MET,
                                       method = "svmLinear", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(svr.statistical.oneStep.tuned, file = "Trained models/MET_oneStep_SVR.Rdata")

# Evaluation on test set #############
svr.statistical.oneStep.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$MET, Predicted = NA)
svr.statistical.oneStep.out$Predicted <- predict(svr.statistical.oneStep.tuned, test.df[, -c(1:4, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(svr.statistical.oneStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_oneStep_SVR.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((svr.statistical.oneStep.out$Actual - svr.statistical.oneStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = svr.statistical.oneStep.out)
s <- summary(lm.fit)
print(paste("One step SVR: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, svr.statistical.oneStep.out, svr.statistical.oneStep.tuned, ctrl)


# Decision Tree ========================
library(rpart)
ctrl <- trainControl(method = "LOOCV")
set.seed(5855)
decisionTree.statistical.oneStep.tuned <- train(x = training.df[, -c(1:4, ncol(training.df))], y = training.df$MET,
                                       method = "rpart", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(decisionTree.statistical.oneStep.tuned, file = "Trained models/MET_oneStep_decisionTree.Rdata")

# Evaluation on test set #############
decisionTree.statistical.oneStep.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$MET, Predicted = NA)
decisionTree.statistical.oneStep.out$Predicted <- predict(decisionTree.statistical.oneStep.tuned, test.df[, -c(1:4, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(decisionTree.statistical.oneStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_oneStep_decisionTree.cv", row.names = F)

# Checking the rMSE and R2
mse <- mean((decisionTree.statistical.oneStep.out$Actual - decisionTree.statistical.oneStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = decisionTree.statistical.oneStep.out)
s <- summary(lm.fit)
print(paste("One step Decision Tree: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, decisionTree.statistical.oneStep.out, decisionTree.statistical.oneStep.tuned, ctrl)


# Random Forest ========================
library(randomForest)
ctrl <- trainControl(method = "oob")
nTree <- 500
mTry <- 2:4
tunegrid <- expand.grid(.mtry=mTry)
set.seed(5855)
randomForest.statistical.oneStep.tuned <- train(x = training.df[, -c(1:4, ncol(training.df))], y = training.df$MET,
                                                method = "rf", metric = "RMSE",
                                                trControl = ctrl, tuneGrid = tunegrid, ntree = nTree)

# Saving the trained classifier for future use
save(randomForest.statistical.oneStep.tuned, file = "Trained models/MET_oneStep_randomForest.Rdata")

# Evaluation on test set #############
randomForest.statistical.oneStep.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$MET, Predicted = NA)
randomForest.statistical.oneStep.out$Predicted <- predict(randomForest.statistical.oneStep.tuned, test.df[, -c(1:4, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(randomForest.statistical.oneStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_oneStep_randomForest.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((randomForest.statistical.oneStep.out$Actual - randomForest.statistical.oneStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = randomForest.statistical.oneStep.out)
s <- summary(lm.fit)
print(paste("One step Random Forest: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, randomForest.statistical.oneStep.out, randomForest.statistical.oneStep.tuned, ctrl, nTree, mTry, tunegrid)



# Two step energy expenditure ---------------------------------
source("../Utilities/FUN_PA_Labels_and_METs.R")
twoStep_training.df <- training.df
twoStep_training.df$Sedentary <- sapply(as.character(twoStep_training.df$Task), FUN = function (x) {
     if(giveClassLabel_sedentary(x)) {
          return(1)
     }
     return(0)
})
twoStep_training.df$Locomotion <- sapply(as.character(twoStep_training.df$Task), FUN = function(x) {
     if(giveClassLabel_locomotion(x)) {
          return(1)
     }
     return(0)
})
twoStep_test.df <- test.df
rm(giveClassLabel_locomotion, giveClassLabel_sedentary, giveMETValue, giveMETIntensity)

# SVR ========================
library(caret)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(5855)
svr.statistical.twoStep.tuned <- train(x = twoStep_training.df[, -c(1:4, 12)], y = twoStep_training.df$MET,
                                       method = "svmLinear", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(svr.statistical.twoStep.tuned, file = "Trained models/MET_twoStep_SVR.Rdata")

# Evaluation on test set #############
load("Trained models/sedentary_SVM.Rdata")
Sedentary_labels <- predict(svm.sedentary.tuned, twoStep_test.df[, -c(1:4, ncol(twoStep_test.df))])
twoStep_test.df$Sedentary <- sapply(as.character(Sedentary_labels), FUN = function(x) {
     if(x == "Sed") {
          return(1)
     }
     return(0)
})

load("Trained models/locomotion_SVM.Rdata")
library(kernlab)
Locomotion_labels <- predict(svm.locomotion.tuned, twoStep_test.df[, -c(1:4, 12:13)])
twoStep_test.df$Locomotion <- sapply(as.character(Locomotion_labels), FUN = function(x) {
     if(x == "Loc") {
          return(1)
     }
     return(0)
})

svr.statistical.twoStep.out <- data.frame(PID = twoStep_test.df$PID, Task = twoStep_test.df$Task, Actual = twoStep_test.df$MET, Predicted = NA)

svr.statistical.twoStep.out$Predicted <- predict(svr.statistical.twoStep.tuned, twoStep_test.df[, -c(1:4, 12)])

# saving the output on test set for future analysis.
write.csv(svr.statistical.twoStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_twoStep_SVR.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((svr.statistical.twoStep.out$Actual - svr.statistical.twoStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = svr.statistical.twoStep.out)
s <- summary(lm.fit)
print(paste("Two step SVR: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, svr.statistical.twoStep.out, svr.statistical.twoStep.tuned, ctrl, svm.locomotion.tuned, svm.sedentary.tuned, Locomotion_labels, Sedentary_labels, twoStep_test.df)


# Decision Tree ========================
ctrl <- trainControl(method = "LOOCV")
set.seed(5855)
decisionTree.statistical.twoStep.tuned <- train(x = twoStep_training.df[, -c(1:4, 12)], y = twoStep_training.df$MET,
                                       method = "rpart", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(decisionTree.statistical.twoStep.tuned, file = "Trained models/MET_twoStep_decisionTree.Rdata")

# Evaluation on test set #############
twoStep_test.df <- test.df
load("Trained models/sedentary_decisionTree.Rdata")
Sedentary_labels <- predict(decisionTree.sedentary.tuned, twoStep_test.df[, -c(1:4, 12)])
twoStep_test.df$Sedentary <- sapply(as.character(Sedentary_labels), FUN = function(x) {
     if(x == "Sed") {
          return(1)
     }
     return(0)
})

load("Trained models/locomotion_decisionTree.Rdata")
library(kernlab)
Locomotion_labels <- predict(decisionTree.locomotion.tuned, twoStep_test.df[, -c(1:4, 12:13)])
twoStep_test.df$Locomotion <- sapply(as.character(Locomotion_labels), FUN = function(x) {
     if(x == "Loc") {
          return(1)
     }
     return(0)
})

decisionTree.statistical.twoStep.out <- data.frame(PID = twoStep_test.df$PID, Task = twoStep_test.df$Task, Actual = twoStep_test.df$MET, Predicted = NA)

decisionTree.statistical.twoStep.out$Predicted <- predict(decisionTree.statistical.twoStep.tuned, twoStep_test.df[, -c(1:4, 12)])

# saving the output on test set for future analysis.
write.csv(decisionTree.statistical.twoStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_twoStep_decisionTree.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((decisionTree.statistical.twoStep.out$Actual - decisionTree.statistical.twoStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = decisionTree.statistical.twoStep.out)
s <- summary(lm.fit)
print(paste("Two step Decision Tree: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, decisionTree.statistical.twoStep.out, decisionTree.statistical.twoStep.tuned, ctrl, decisionTree.locomotion.tuned, decisionTree.sedentary.tuned, Locomotion_labels, Sedentary_labels, twoStep_test.df)


# Random Forest ========================
ctrl <- trainControl(method = "oob")
set.seed(5855)
randomForest.statistical.twoStep.tuned <- train(x = twoStep_training.df[, -c(1:4, 12)], y = twoStep_training.df$MET,
                                                method = "rf", metric = "RMSE", trControl = ctrl, ntree = 1500, mTry = 2)

# Saving the trained classifier for future use
save(randomForest.statistical.twoStep.tuned, file = "Trained models/MET_twoStep_randomForest.Rdata")

# Evaluation on test set #############
twoStep_test.df <- test.df
load("Trained models/sedentary_randomForest.Rdata")
Sedentary_labels <- predict(randomForest.sedentary.tuned, twoStep_test.df[, -c(1:4, 12)])
twoStep_test.df$Sedentary <- sapply(as.character(Sedentary_labels), FUN = function(x) {
     if(x == "Sed") {
          return(1)
     }
     return(0)
})

load("Trained models/locomotion_randomForest.Rdata")
Locomotion_labels <- predict(randomForest.locomotion.tuned, twoStep_test.df[, -c(1:4, 12:13)])
twoStep_test.df$Locomotion <- sapply(as.character(Locomotion_labels), FUN = function(x) {
     if(x == "Loc") {
          return(1)
     }
     return(0)
})

randomForest.statistical.twoStep.out <- data.frame(PID = twoStep_test.df$PID, Task = twoStep_test.df$Task, Actual = twoStep_test.df$MET, Predicted = NA)

randomForest.statistical.twoStep.out$Predicted <- predict(randomForest.statistical.twoStep.tuned, twoStep_test.df[, -c(1:4, 12)])

# saving the output on test set for future analysis.
write.csv(randomForest.statistical.twoStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_twoStep_randomForest.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((randomForest.statistical.twoStep.out$Actual - randomForest.statistical.twoStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = randomForest.statistical.twoStep.out)
s <- summary(lm.fit)
print(paste("Two step Random Forest: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, randomForest.statistical.twoStep.out, randomForest.statistical.twoStep.tuned, ctrl, randomForest.locomotion.tuned, randomForest.sedentary.tuned, Locomotion_labels, Sedentary_labels, twoStep_test.df)
rm(list = ls())


# Three step energy expenditure ---------------------------------
source("../Utilities/FUN_PA_Labels_and_METs.R")
training.df$Sedentary <- sapply(training.df$Task, FUN = function(x) {
     if(giveClassLabel_sedentary(x)) {
          return(1)
     }
     return(0)
})
training.df$Locomotion <- sapply(training.df$Task, FUN = function(x) {
     if(giveClassLabel_locomotion(x)) {
          return(1)
     }
     return(0)
})

rm(giveClassLabel_locomotion, giveClassLabel_sedentary, giveMETValue, giveMETIntensity)

# One hot encoding ####
training.df$CW <- 0 # Computer Work
training.df$CW[training.df$Task == "COMPUTER WORK"] <- 1
training.df$TW <- 0 # TV Watching
training.df$TW[training.df$Task == "TV WATCHING"] <- 1
training.df$SS <- 0 # Standing Still
training.df$SS[training.df$Task == "STANDING STILL"] <- 1
training.df$LW <- 0 # Leisure Walk
training.df$LW[training.df$Task == "LEISURE WALK"] <- 1
training.df$RW <- 0 # Rapid Walk
training.df$RW[training.df$Task == "RAPID WALK"] <- 1
training.df$WR1 <- 0 # Walking at RPE 1
training.df$WR1[training.df$Task == "WALKING AT RPE 1"] <- 1
training.df$WR5 <- 0 # Walking at RPE 5
training.df$WR5[training.df$Task == "WALKING AT RPE 5"] <- 1
training.df$SA <- 0 # Stair Ascent
training.df$SA[training.df$Task == "STAIR ASCENT"] <- 1
training.df$SD <- 0 # Stair Descent
training.df$SD[training.df$Task == "STAIR DESCENT"] <- 1

# SVR ===================================
library(caret)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(5855)
svr.statistical.threeStep.tuned <- train(x = training.df[, -c(1:4, 12)], y = training.df$MET,
                                       method = "svmLinear", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(svr.statistical.threeStep.tuned, file = "Trained models/MET_threeStep_SVR.Rdata")

# Evaluation on test set #############
threeStep_test.df <- test.df
load("Trained models/sedentary_SVM.Rdata")
Sedentary_labels <- predict(svm.sedentary.tuned, threeStep_test.df[, -c(1:4, ncol(threeStep_test.df))])
threeStep_test.df$Sedentary <- sapply(as.character(Sedentary_labels), FUN = function(x) {
     if(x == "Sed") {
          return(1)
     }
     return(0)
})

load("Trained models/locomotion_SVM.Rdata")
library(kernlab)
Locomotion_labels <- predict(svm.locomotion.tuned, threeStep_test.df[, -c(1:4, 12:13)])
threeStep_test.df$Locomotion <- sapply(as.character(Locomotion_labels), FUN = function(x) {
     if(x == "Loc") {
          return(1)
     }
     return(0)
})

load("Trained models/sedentary_type_SVM.Rdata")
sedType <- predict(svm.sedType.tuned, threeStep_test.df[threeStep_test.df$Sedentary == 1, -c(1:4, 12:14)])
load("Trained models/locomotion_type_SVM.Rdata")
locType <- predict(svm.locType.tuned, threeStep_test.df[threeStep_test.df$Locomotion == 1, -c(1:4, 12:14)])

threeStep_test.df$CW <- 0 # Computer Work
threeStep_test.df$CW[sedType == "COMPUTER WORK"] <- 1
threeStep_test.df$TW <- 0 # TV Watching
threeStep_test.df$TW[sedType == "TV WATCHING"] <- 1
threeStep_test.df$SS <- 0 # Standing Still
threeStep_test.df$SS[sedType == "STANDING STILL"] <- 1
threeStep_test.df$LW <- 0 # Leisure Walk
threeStep_test.df$LW[locType == "LEISURE WALK"] <- 1
threeStep_test.df$RW <- 0 # Rapid Walk
threeStep_test.df$RW[locType == "RAPID WALK"] <- 1
threeStep_test.df$WR1 <- 0 # Walking at RPE 1
threeStep_test.df$WR1[locType == "WALKING AT RPE 1"] <- 1
threeStep_test.df$WR5 <- 0 # Walking at RPE 5
threeStep_test.df$WR5[locType == "WALKING AT RPE 5"] <- 1
threeStep_test.df$SA <- 0 # Stair Ascent
threeStep_test.df$SA[locType == "STAIR ASCENT"] <- 1
threeStep_test.df$SD <- 0 # Stair Descent
threeStep_test.df$SD[locType == "STAIR DESCENT"] <- 1


svr.statistical.threeStep.out <- data.frame(PID = threeStep_test.df$PID, Task = threeStep_test.df$Task, Actual = threeStep_test.df$MET, Predicted = NA)

svr.statistical.threeStep.out$Predicted <- predict(svr.statistical.threeStep.tuned, threeStep_test.df[, -c(1:4, 12)])

# saving the output on test set for future analysis.
write.csv(svr.statistical.threeStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_threeStep_SVR.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((svr.statistical.threeStep.out$Actual - svr.statistical.threeStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = svr.statistical.threeStep.out)
s <- summary(lm.fit)
print(paste("Three step SVR: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, svr.statistical.threeStep.out, svr.statistical.threeStep.tuned, ctrl, svm.locomotion.tuned, svm.sedentary.tuned,
   Locomotion_labels, Sedentary_labels, threeStep_test.df, svm.locType.tuned, svm.sedType.tuned, locType, sedType)



# Decision Tree ===================================
library(rpart)
ctrl <- trainControl(method = "LOOCV")
set.seed(5855)
decisionTree.statistical.threeStep.tuned <- train(x = training.df[, -c(1:4, 12)], y = training.df$MET,
                                         method = "rpart", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(decisionTree.statistical.threeStep.tuned, file = "Trained models/MET_threeStep_decisionTree.Rdata")

# Evaluation on test set #############
threeStep_test.df <- test.df
load("Trained models/sedentary_decisionTree.Rdata")
Sedentary_labels <- predict(decisionTree.sedentary.tuned, threeStep_test.df[, -c(1:4, ncol(threeStep_test.df))])
threeStep_test.df$Sedentary <- sapply(as.character(Sedentary_labels), FUN = function(x) {
     if(x == "Sed") {
          return(1)
     }
     return(0)
})

load("Trained models/locomotion_decisionTree.Rdata")
library(kernlab)
Locomotion_labels <- predict(decisionTree.locomotion.tuned, threeStep_test.df[, -c(1:4, 12:13)])
threeStep_test.df$Locomotion <- sapply(as.character(Locomotion_labels), FUN = function(x) {
     if(x == "Loc") {
          return(1)
     }
     return(0)
})

load("Trained models/sedentary_type_decisionTree.Rdata")
sedType <- predict(decisionTree.sedType.tuned, threeStep_test.df[threeStep_test.df$Sedentary == 1, -c(1:4, 12:14)])
load("Trained models/locomotion_type_decisionTree.Rdata")
locType <- predict(decisionTree.locType.tuned, threeStep_test.df[threeStep_test.df$Locomotion == 1, -c(1:4, 12:14)])

threeStep_test.df$CW <- 0 # Computer Work
threeStep_test.df$CW[sedType == "COMPUTER WORK"] <- 1
threeStep_test.df$TW <- 0 # TV Watching
threeStep_test.df$TW[sedType == "TV WATCHING"] <- 1
threeStep_test.df$SS <- 0 # Standing Still
threeStep_test.df$SS[sedType == "STANDING STILL"] <- 1
threeStep_test.df$LW <- 0 # Leisure Walk
threeStep_test.df$LW[locType == "LEISURE WALK"] <- 1
threeStep_test.df$RW <- 0 # Rapid Walk
threeStep_test.df$RW[locType == "RAPID WALK"] <- 1
threeStep_test.df$WR1 <- 0 # Walking at RPE 1
threeStep_test.df$WR1[locType == "WALKING AT RPE 1"] <- 1
threeStep_test.df$WR5 <- 0 # Walking at RPE 5
threeStep_test.df$WR5[locType == "WALKING AT RPE 5"] <- 1
threeStep_test.df$SA <- 0 # Stair Ascent
threeStep_test.df$SA[locType == "STAIR ASCENT"] <- 1
threeStep_test.df$SD <- 0 # Stair Descent
threeStep_test.df$SD[locType == "STAIR DESCENT"] <- 1


decisionTree.statistical.threeStep.out <- data.frame(PID = threeStep_test.df$PID, Task = threeStep_test.df$Task, Actual = threeStep_test.df$MET, Predicted = NA)

decisionTree.statistical.threeStep.out$Predicted <- predict(decisionTree.statistical.threeStep.tuned, threeStep_test.df[, -c(1:4, 12)])

# saving the output on test set for future analysis.
write.csv(decisionTree.statistical.threeStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_threeStep_decisionTree.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((decisionTree.statistical.threeStep.out$Actual - decisionTree.statistical.threeStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = decisionTree.statistical.threeStep.out)
s <- summary(lm.fit)
print(paste("Three step Decision Tree: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, decisionTree.statistical.threeStep.out, decisionTree.statistical.threeStep.tuned, ctrl, decisionTree.locomotion.tuned, decisionTree.sedentary.tuned,
   Locomotion_labels, Sedentary_labels, threeStep_test.df, decisionTree.locType.tuned, decisionTree.sedType.tuned, locType, sedType)


# Random Forest ===================================
library(randomForest)
ctrl <- trainControl(method = "oob")
nTree = 5000
mTry = 2:4
tunegrid <- expand.grid(.mtry=mTry)
set.seed(5855)
randomForest.statistical.threeStep.tuned <- train(x = training.df[, -c(1:4, 12)], y = training.df$MET,
                                                  method = "rf", metric = "RMSE", trControl = ctrl, tuneGrid = tunegrid)

# Saving the trained classifier for future use
save(randomForest.statistical.threeStep.tuned, file = "Trained models/MET_threeStep_randomForest.Rdata")

# Evaluation on test set #############
threeStep_test.df <- test.df
load("Trained models/sedentary_randomForest.Rdata")
Sedentary_labels <- predict(randomForest.sedentary.tuned, threeStep_test.df[, -c(1:4, ncol(threeStep_test.df))])
threeStep_test.df$Sedentary <- sapply(as.character(Sedentary_labels), FUN = function(x) {
     if(x == "Sed") {
          return(1)
     }
     return(0)
})

load("Trained models/locomotion_randomForest.Rdata")
Locomotion_labels <- predict(randomForest.locomotion.tuned, threeStep_test.df[, -c(1:4, 12:13)])
threeStep_test.df$Locomotion <- sapply(as.character(Locomotion_labels), FUN = function(x) {
     if(x == "Loc") {
          return(1)
     }
     return(0)
})

load("Trained models/sedentary_type_randomForest.Rdata")
sedType <- predict(randomForest.sedType.tuned, threeStep_test.df[threeStep_test.df$Sedentary == 1, -c(1:4, 12:14)])
load("Trained models/locomotion_type_randomForest.Rdata")
locType <- predict(randomForest.locType.tuned, threeStep_test.df[threeStep_test.df$Locomotion == 1, -c(1:4, 12:14)])

threeStep_test.df$CW <- 0 # Computer Work
threeStep_test.df$CW[sedType == "COMPUTER WORK"] <- 1
threeStep_test.df$TW <- 0 # TV Watching
threeStep_test.df$TW[sedType == "TV WATCHING"] <- 1
threeStep_test.df$SS <- 0 # Standing Still
threeStep_test.df$SS[sedType == "STANDING STILL"] <- 1
threeStep_test.df$LW <- 0 # Leisure Walk
threeStep_test.df$LW[locType == "LEISURE WALK"] <- 1
threeStep_test.df$RW <- 0 # Rapid Walk
threeStep_test.df$RW[locType == "RAPID WALK"] <- 1
threeStep_test.df$WR1 <- 0 # Walking at RPE 1
threeStep_test.df$WR1[locType == "WALKING AT RPE 1"] <- 1
threeStep_test.df$WR5 <- 0 # Walking at RPE 5
threeStep_test.df$WR5[locType == "WALKING AT RPE 5"] <- 1
threeStep_test.df$SA <- 0 # Stair Ascent
threeStep_test.df$SA[locType == "STAIR ASCENT"] <- 1
threeStep_test.df$SD <- 0 # Stair Descent
threeStep_test.df$SD[locType == "STAIR DESCENT"] <- 1


randomForest.statistical.threeStep.out <- data.frame(PID = threeStep_test.df$PID, Task = threeStep_test.df$Task, Actual = threeStep_test.df$MET, Predicted = NA)

randomForest.statistical.threeStep.out$Predicted <- predict(randomForest.statistical.threeStep.tuned, threeStep_test.df[, -c(1:4, 12)])

# saving the output on test set for future analysis.
write.csv(randomForest.statistical.threeStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Statistical/MET_threeStep_randomForest.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((randomForest.statistical.threeStep.out$Actual - randomForest.statistical.threeStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = randomForest.statistical.threeStep.out)
s <- summary(lm.fit)
print(paste("Three step Random Forest: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, randomForest.statistical.threeStep.out, randomForest.statistical.threeStep.tuned, randomForest.locomotion.tuned, randomForest.sedentary.tuned,
   Locomotion_labels, Sedentary_labels, threeStep_test.df, randomForest.locType.tuned, randomForest.sedType.tuned, locType, sedType, ctrl, mTry, tunegrid, nTree)


