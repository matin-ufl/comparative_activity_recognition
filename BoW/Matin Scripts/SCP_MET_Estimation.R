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

setwd("~/Workspaces/R workspace/Comparative Activity Recognition/BoW/Matin Scripts/")
training.df <- readRDS(file.choose())
test.df <- readRDS(file.choose())

# Class labels ----------------------
source("../../Utilities/FUN_PA_Labels_and_METs.R")
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
svr.statistical.oneStep.tuned <- train(x = training.df[, -c(1:2, ncol(training.df))], y = training.df$MET,
                                       method = "svmLinear", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(svr.statistical.oneStep.tuned, file = "Trained models/MET_oneStep_SVR.Rdata")

# Evaluation on test set #############
svr.statistical.oneStep.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$MET, Predicted = NA)
svr.statistical.oneStep.out$Predicted <- predict(svr.statistical.oneStep.tuned, test.df[, -c(1:2, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(svr.statistical.oneStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_oneStep_SVR.csv", row.names = F)

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
randomForest.statistical.oneStep.tuned <- train(x = training.df[, -c(1:2, ncol(training.df))], y = training.df$MET,
                                                method = "rf", metric = "RMSE",
                                                trControl = ctrl, tuneGrid = tunegrid, ntree = nTree)

# Saving the trained classifier for future use
save(randomForest.statistical.oneStep.tuned, file = "Trained models/MET_oneStep_randomForest.Rdata")

# Evaluation on test set #############
randomForest.statistical.oneStep.out <- data.frame(PID = test.df$PID, Task = test.df$Task, Actual = test.df$MET, Predicted = NA)
randomForest.statistical.oneStep.out$Predicted <- predict(randomForest.statistical.oneStep.tuned, test.df[, -c(1:2, ncol(test.df))])

# saving the output on test set for future analysis.
write.csv(randomForest.statistical.oneStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_oneStep_randomForest.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((randomForest.statistical.oneStep.out$Actual - randomForest.statistical.oneStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = randomForest.statistical.oneStep.out)
s <- summary(lm.fit)
print(paste("One step Random Forest: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, randomForest.statistical.oneStep.out, randomForest.statistical.oneStep.tuned, ctrl, nTree, mTry, tunegrid)



# Two step energy expenditure ---------------------------------
source("../../Utilities/FUN_PA_Labels_and_METs.R")
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
setwd("~/Workspaces/R workspace/Comparative Activity Recognition/BoW/Matin Scripts/")


# SVR ========================
library(caret)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(5855)
svr.statistical.twoStep.tuned <- train(x = twoStep_training.df[, -c(1:2, 35)], y = twoStep_training.df$MET,
                                       method = "svmLinear", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(svr.statistical.twoStep.tuned, file = "Trained models/MET_twoStep_SVR.Rdata")

# Evaluation on test set #############
testSedentary.df <- read.csv(file.choose())
twoStep_test.df$Sedentary <- 0
for(i in 1:nrow(twoStep_test.df)) {
     sed <- testSedentary.df$Predicted[(testSedentary.df$PID == twoStep_test.df$PID[i] & testSedentary.df$Task == twoStep_test.df$Task[i])]
     if(sed == "Sed") {
          twoStep_test.df$Sedentary[i] <- 1
     }
}
rm(i, sed, testSedentary.df)

testLocomotion.df <- read.csv(file.choose())
twoStep_test.df$Locomotion <- 0
for(i in 1:nrow(twoStep_test.df)) {
     loc <- testLocomotion.df$Predicted[(testLocomotion.df$PID == twoStep_test.df$PID[i] & testLocomotion.df$Task == twoStep_test.df$Task[i])]
     if(loc == "Loc") {
          twoStep_test.df$Locomotion[i] <- 1
     }
}
rm(i, loc, testLocomotion.df)

svr.statistical.twoStep.out <- data.frame(PID = twoStep_test.df$PID, Task = twoStep_test.df$Task, Actual = twoStep_test.df$MET, Predicted = NA)

svr.statistical.twoStep.out$Predicted <- predict(svr.statistical.twoStep.tuned, twoStep_test.df[, -c(1:2, 35)])

# saving the output on test set for future analysis.
write.csv(svr.statistical.twoStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_twoStep_SVR.csv", row.names = F)

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
decisionTree.statistical.twoStep.tuned <- train(x = twoStep_training.df[, -c(1:2, 35)], y = twoStep_training.df$MET,
                                                method = "rpart", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(decisionTree.statistical.twoStep.tuned, file = "Trained models/MET_twoStep_decisionTree.Rdata")

# Evaluation on test set #############
twoStep_test.df <- test.df

testSedentary.df <- read.csv(file.choose())
twoStep_test.df$Sedentary <- 0
for(i in 1:nrow(twoStep_test.df)) {
     sed <- testSedentary.df$Predicted[(testSedentary.df$PID == twoStep_test.df$PID[i] & testSedentary.df$Task == twoStep_test.df$Task[i])]
     if(sed == "Sed") {
          twoStep_test.df$Sedentary[i] <- 1
     }
}
rm(i, sed, testSedentary.df)

testLocomotion.df <- read.csv(file.choose())
twoStep_test.df$Locomotion <- 0
for(i in 1:nrow(twoStep_test.df)) {
     loc <- testLocomotion.df$Predicted[(testLocomotion.df$PID == twoStep_test.df$PID[i] & testLocomotion.df$Task == twoStep_test.df$Task[i])]
     if(loc == "Loc") {
          twoStep_test.df$Locomotion[i] <- 1
     }
}
rm(i, loc, testLocomotion.df)

decisionTree.statistical.twoStep.out <- data.frame(PID = twoStep_test.df$PID, Task = twoStep_test.df$Task, Actual = twoStep_test.df$MET, Predicted = NA)

decisionTree.statistical.twoStep.out$Predicted <- predict(decisionTree.statistical.twoStep.tuned, twoStep_test.df[, -c(1:2, 35)])

# saving the output on test set for future analysis.
write.csv(decisionTree.statistical.twoStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_twoStep_decisionTree.csv", row.names = F)

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
randomForest.statistical.twoStep.tuned <- train(x = twoStep_training.df[, -c(1:2, 35)], y = twoStep_training.df$MET,
                                                method = "rf", metric = "RMSE", trControl = ctrl, ntree = 1500, mTry = 2)

# Saving the trained classifier for future use
save(randomForest.statistical.twoStep.tuned, file = "Trained models/MET_twoStep_randomForest.Rdata")

# Evaluation on test set #############
twoStep_test.df <- test.df

testSedentary.df <- read.csv(file.choose())
twoStep_test.df$Sedentary <- 0
for(i in 1:nrow(twoStep_test.df)) {
     sed <- testSedentary.df$Predicted[(testSedentary.df$PID == twoStep_test.df$PID[i] & testSedentary.df$Task == twoStep_test.df$Task[i])]
     if(sed == "Sed") {
          twoStep_test.df$Sedentary[i] <- 1
     }
}
rm(i, sed, testSedentary.df)

testLocomotion.df <- read.csv(file.choose())
twoStep_test.df$Locomotion <- 0
for(i in 1:nrow(twoStep_test.df)) {
     loc <- testLocomotion.df$Predicted[(testLocomotion.df$PID == twoStep_test.df$PID[i] & testLocomotion.df$Task == twoStep_test.df$Task[i])]
     if(loc == "Loc") {
          twoStep_test.df$Locomotion[i] <- 1
     }
}
rm(i, loc, testLocomotion.df)

randomForest.statistical.twoStep.out <- data.frame(PID = twoStep_test.df$PID, Task = twoStep_test.df$Task, Actual = twoStep_test.df$MET, Predicted = NA)

randomForest.statistical.twoStep.out$Predicted <- predict(randomForest.statistical.twoStep.tuned, twoStep_test.df[, -c(1:2, 35)])

# saving the output on test set for future analysis.
write.csv(randomForest.statistical.twoStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_twoStep_randomForest.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((randomForest.statistical.twoStep.out$Actual - randomForest.statistical.twoStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = randomForest.statistical.twoStep.out)
s <- summary(lm.fit)
print(paste("Two step Random Forest: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, randomForest.statistical.twoStep.out, randomForest.statistical.twoStep.tuned, ctrl, randomForest.locomotion.tuned, randomForest.sedentary.tuned, Locomotion_labels, Sedentary_labels, twoStep_test.df)


# Three step energy expenditure ---------------------------------
threeStep_training.df <- twoStep_training.df
rm(twoStep_training.df)

# One hot encoding ####
threeStep_training.df$CW <- 0 # Computer Work
threeStep_training.df$CW[training.df$Task == "COMPUTER WORK"] <- 1
threeStep_training.df$TW <- 0 # TV Watching
threeStep_training.df$TW[training.df$Task == "TV WATCHING"] <- 1
threeStep_training.df$SS <- 0 # Standing Still
threeStep_training.df$SS[training.df$Task == "STANDING STILL"] <- 1
threeStep_training.df$LW <- 0 # Leisure Walk
threeStep_training.df$LW[training.df$Task == "LEISURE WALK"] <- 1
threeStep_training.df$RW <- 0 # Rapid Walk
threeStep_training.df$RW[training.df$Task == "RAPID WALK"] <- 1
threeStep_training.df$WR1 <- 0 # Walking at RPE 1
threeStep_training.df$WR1[training.df$Task == "WALKING AT RPE 1"] <- 1
threeStep_training.df$WR5 <- 0 # Walking at RPE 5
threeStep_training.df$WR5[training.df$Task == "WALKING AT RPE 5"] <- 1
threeStep_training.df$SA <- 0 # Stair Ascent
threeStep_training.df$SA[training.df$Task == "STAIR ASCENT"] <- 1
threeStep_training.df$SD <- 0 # Stair Descent
threeStep_training.df$SD[training.df$Task == "STAIR DESCENT"] <- 1

# SVR ===================================
library(caret)
ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)
set.seed(5855)
svr.statistical.threeStep.tuned <- train(x = threeStep_training.df[, -c(1:2, 35)], y = threeStep_training.df$MET,
                                         method = "svmLinear", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(svr.statistical.threeStep.tuned, file = "Trained models/MET_threeStep_SVR.Rdata")

# Evaluation on test set #############
threeStep_test.df <- test.df

threeStep_test.df$Sedentary <- 0
threeStep_test.df$Locomotion <- 0
for(i in 1:nrow(threeStep_test.df)) {
     if(threeStep_test.df$Task[i] %in% c("COMPUTER WORK", "TV WATCHING", "STANDING STILL")) {
          threeStep_test.df$Sedentary[i] <- 1
     } else {
          if(threeStep_test.df$Task[i] %in% c("LEISURE WALK", "RAPID WALK", "WALKING AT RPE 1", "WALKING AT RPE 5", "STAIR ASCENT", "STAIR DESCENT")) {
               threeStep_test.df$Locomotion[i] <- 1
          }
     }
}
rm(i)

SedentaryLabels.df <- read.csv(file.choose())
SedentaryLabels.df$Actual <- gsub("\\.", " ", as.character(SedentaryLabels.df$Actual))
LocomotionLabels.df <- read.csv(file.choose())
LocomotionLabels.df$Actual <- gsub("\\.", " ", as.character(LocomotionLabels.df$Actual))

threeStep_test.df$CW <- 0 # Computer Work
threeStep_test.df$TW <- 0 # TV Watching
threeStep_test.df$SS <- 0 # Standing Still
threeStep_test.df$LW <- 0 # Leisure Walk
threeStep_test.df$RW <- 0 # Rapid Walk
threeStep_test.df$WR1 <- 0 # Walking at RPE 1
threeStep_test.df$WR5 <- 0 # Walking at RPE 5
threeStep_test.df$SA <- 0 # Stair Ascent
threeStep_test.df$SD <- 0 # Stair Descent

for(i in 1:nrow(threeStep_test.df)) {
     PID <- threeStep_test.df$PID[i]
     found <- which(SedentaryLabels.df$PID == PID & SedentaryLabels.df$Actual == threeStep_test.df$Task[i])
     if(length(found) > 0) {
          if(SedentaryLabels.df$Predicted[found] == "COMPUTER.WORK") {
               threeStep_test.df$CW[i] <- 1
          } else if(SedentaryLabels.df$Predicted[found] == "TV.WATCHING") {
               threeStep_test.df$TW[i] <- 1
          } else if(SedentaryLabels.df$Predicted[found] == 'STANDING.STILL') {
               threeStep_test.df$SS[i] <- 1
          }
     } else {
          found <- which(LocomotionLabels.df$PID == PID & LocomotionLabels.df$Actual == threeStep_test.df$Task[i])
          if(length(found) > 0) {
               if(LocomotionLabels.df$Predicted[found] == 'LEISURE.WALK') {
                    threeStep_test.df$LW[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "RAPID.WALK") {
                    threeStep_test.df$RW[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "WALKING.AT.RPE.1") {
                    threeStep_test.df$WR1[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "WALKING.AT.RPE.5") {
                    threeStep_test.df$WR5[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "STAIR.ASCENT") {
                    threeStep_test.df$SA[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == 'STAIR.DESCENT') {
                    threeStep_test.df$SD[i] <- 1
               }
          }
     }
}
rm(i, PID, found)

svr.statistical.threeStep.out <- data.frame(PID = threeStep_test.df$PID, Task = threeStep_test.df$Task, Actual = threeStep_test.df$MET, Predicted = NA)

svr.statistical.threeStep.out$Predicted <- predict(svr.statistical.threeStep.tuned, threeStep_test.df[, -c(1:2, 35)])

# saving the output on test set for future analysis.
write.csv(svr.statistical.threeStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_threeStep_SVR.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((svr.statistical.threeStep.out$Actual - svr.statistical.threeStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = svr.statistical.threeStep.out)
s <- summary(lm.fit)
print(paste("Three step SVR: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, svr.statistical.threeStep.out, svr.statistical.threeStep.tuned, ctrl, svm.locomotion.tuned, svm.sedentary.tuned,
   Locomotion_labels, Sedentary_labels, threeStep_test.df, svm.locType.tuned, svm.sedType.tuned, locType, sedType, SedentaryLabels.df, LocomotionLabels.df)



# Decision Tree ===================================
library(rpart)
ctrl <- trainControl(method = "LOOCV")
set.seed(5855)
decisionTree.statistical.threeStep.tuned <- train(x = training.df[, -c(1:2, 35)], y = training.df$MET,
                                                  method = "rpart", metric = "RMSE", trControl = ctrl)

# Saving the trained classifier for future use
save(decisionTree.statistical.threeStep.tuned, file = "Trained models/MET_threeStep_decisionTree.Rdata")

# Evaluation on test set #############
threeStep_test.df <- test.df

threeStep_test.df$Sedentary <- 0
threeStep_test.df$Locomotion <- 0
for(i in 1:nrow(threeStep_test.df)) {
     if(threeStep_test.df$Task[i] %in% c("COMPUTER WORK", "TV WATCHING", "STANDING STILL")) {
          threeStep_test.df$Sedentary[i] <- 1
     } else {
          if(threeStep_test.df$Task[i] %in% c("LEISURE WALK", "RAPID WALK", "WALKING AT RPE 1", "WALKING AT RPE 5", "STAIR ASCENT", "STAIR DESCENT")) {
               threeStep_test.df$Locomotion[i] <- 1
          }
     }
}
rm(i)

SedentaryLabels.df <- read.csv(file.choose())
SedentaryLabels.df$Actual <- gsub("\\.", " ", as.character(SedentaryLabels.df$Actual))
LocomotionLabels.df <- read.csv(file.choose())
LocomotionLabels.df$Actual <- gsub("\\.", " ", as.character(LocomotionLabels.df$Actual))

threeStep_test.df$CW <- 0 # Computer Work
threeStep_test.df$TW <- 0 # TV Watching
threeStep_test.df$SS <- 0 # Standing Still
threeStep_test.df$LW <- 0 # Leisure Walk
threeStep_test.df$RW <- 0 # Rapid Walk
threeStep_test.df$WR1 <- 0 # Walking at RPE 1
threeStep_test.df$WR5 <- 0 # Walking at RPE 5
threeStep_test.df$SA <- 0 # Stair Ascent
threeStep_test.df$SD <- 0 # Stair Descent

for(i in 1:nrow(threeStep_test.df)) {
     PID <- threeStep_test.df$PID[i]
     found <- which(SedentaryLabels.df$PID == PID & SedentaryLabels.df$Actual == threeStep_test.df$Task[i])
     if(length(found) > 0) {
          if(SedentaryLabels.df$Predicted[found] == "COMPUTER.WORK") {
               threeStep_test.df$CW[i] <- 1
          } else if(SedentaryLabels.df$Predicted[found] == "TV.WATCHING") {
               threeStep_test.df$TW[i] <- 1
          } else if(SedentaryLabels.df$Predicted[found] == 'STANDING.STILL') {
               threeStep_test.df$SS[i] <- 1
          }
     } else {
          found <- which(LocomotionLabels.df$PID == PID & LocomotionLabels.df$Actual == threeStep_test.df$Task[i])
          if(length(found) > 0) {
               if(LocomotionLabels.df$Predicted[found] == 'LEISURE.WALK') {
                    threeStep_test.df$LW[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "RAPID.WALK") {
                    threeStep_test.df$RW[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "WALKING.AT.RPE.1") {
                    threeStep_test.df$WR1[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "WALKING.AT.RPE.5") {
                    threeStep_test.df$WR5[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "STAIR.ASCENT") {
                    threeStep_test.df$SA[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == 'STAIR.DESCENT') {
                    threeStep_test.df$SD[i] <- 1
               }
          }
     }
}
rm(i, PID, found)

decisionTree.statistical.threeStep.out <- data.frame(PID = threeStep_test.df$PID, Task = threeStep_test.df$Task, Actual = threeStep_test.df$MET, Predicted = NA)

decisionTree.statistical.threeStep.out$Predicted <- predict(decisionTree.statistical.threeStep.tuned, threeStep_test.df[, -c(1:2, 35)])

# saving the output on test set for future analysis.
write.csv(decisionTree.statistical.threeStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_threeStep_decisionTree.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((decisionTree.statistical.threeStep.out$Actual - decisionTree.statistical.threeStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = decisionTree.statistical.threeStep.out)
s <- summary(lm.fit)
print(paste("Three step Decision Tree: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, decisionTree.statistical.threeStep.out, decisionTree.statistical.threeStep.tuned, ctrl, decisionTree.locomotion.tuned, decisionTree.sedentary.tuned,
   Locomotion_labels, Sedentary_labels, threeStep_test.df, decisionTree.locType.tuned, decisionTree.sedType.tuned, SedentaryLabels.df, LocomotionLabels.df)


# Random Forest ===================================
library(randomForest)
ctrl <- trainControl(method = "oob")
nTree = 5000
mTry = 2:8
tunegrid <- expand.grid(.mtry=mTry)
set.seed(5855)
randomForest.statistical.threeStep.tuned <- train(x = training.df[, -c(1:2, 35)], y = training.df$MET,
                                                  method = "rf", metric = "RMSE", trControl = ctrl, tuneGrid = tunegrid)

# Saving the trained classifier for future use
save(randomForest.statistical.threeStep.tuned, file = "Trained models/MET_threeStep_randomForest.Rdata")

# Evaluation on test set #############
threeStep_test.df <- test.df

threeStep_test.df$Sedentary <- 0
threeStep_test.df$Locomotion <- 0
for(i in 1:nrow(threeStep_test.df)) {
     if(threeStep_test.df$Task[i] %in% c("COMPUTER WORK", "TV WATCHING", "STANDING STILL")) {
          threeStep_test.df$Sedentary[i] <- 1
     } else {
          if(threeStep_test.df$Task[i] %in% c("LEISURE WALK", "RAPID WALK", "WALKING AT RPE 1", "WALKING AT RPE 5", "STAIR ASCENT", "STAIR DESCENT")) {
               threeStep_test.df$Locomotion[i] <- 1
          }
     }
}
rm(i)

SedentaryLabels.df <- read.csv(file.choose())
SedentaryLabels.df$Actual <- gsub("\\.", " ", as.character(SedentaryLabels.df$Actual))
LocomotionLabels.df <- read.csv(file.choose())
LocomotionLabels.df$Actual <- gsub("\\.", " ", as.character(LocomotionLabels.df$Actual))

threeStep_test.df$CW <- 0 # Computer Work
threeStep_test.df$TW <- 0 # TV Watching
threeStep_test.df$SS <- 0 # Standing Still
threeStep_test.df$LW <- 0 # Leisure Walk
threeStep_test.df$RW <- 0 # Rapid Walk
threeStep_test.df$WR1 <- 0 # Walking at RPE 1
threeStep_test.df$WR5 <- 0 # Walking at RPE 5
threeStep_test.df$SA <- 0 # Stair Ascent
threeStep_test.df$SD <- 0 # Stair Descent

for(i in 1:nrow(threeStep_test.df)) {
     PID <- threeStep_test.df$PID[i]
     found <- which(SedentaryLabels.df$PID == PID & SedentaryLabels.df$Actual == threeStep_test.df$Task[i])
     if(length(found) > 0) {
          if(SedentaryLabels.df$Predicted[found] == "COMPUTER.WORK") {
               threeStep_test.df$CW[i] <- 1
          } else if(SedentaryLabels.df$Predicted[found] == "TV.WATCHING") {
               threeStep_test.df$TW[i] <- 1
          } else if(SedentaryLabels.df$Predicted[found] == 'STANDING.STILL') {
               threeStep_test.df$SS[i] <- 1
          }
     } else {
          found <- which(LocomotionLabels.df$PID == PID & LocomotionLabels.df$Actual == threeStep_test.df$Task[i])
          if(length(found) > 0) {
               if(LocomotionLabels.df$Predicted[found] == 'LEISURE.WALK') {
                    threeStep_test.df$LW[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "RAPID.WALK") {
                    threeStep_test.df$RW[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "WALKING.AT.RPE.1") {
                    threeStep_test.df$WR1[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "WALKING.AT.RPE.5") {
                    threeStep_test.df$WR5[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == "STAIR.ASCENT") {
                    threeStep_test.df$SA[i] <- 1
               } else if(LocomotionLabels.df$Predicted[found] == 'STAIR.DESCENT') {
                    threeStep_test.df$SD[i] <- 1
               }
          }
     }
}
rm(i, PID, found)

randomForest.statistical.threeStep.out <- data.frame(PID = threeStep_test.df$PID, Task = threeStep_test.df$Task, Actual = threeStep_test.df$MET, Predicted = NA)

randomForest.statistical.threeStep.out$Predicted <- predict(randomForest.statistical.threeStep.tuned, threeStep_test.df[, -c(1:2, 35)])

# saving the output on test set for future analysis.
write.csv(randomForest.statistical.threeStep.out, "~/Dropbox/Work-Research/Current Directory/Activity Recognition - Comparative Study/Data/Outputs/Bag of Words/Matin/MET_threeStep_randomForest.csv", row.names = F)

# Checking the rMSE and R2
mse <- mean((randomForest.statistical.threeStep.out$Actual - randomForest.statistical.threeStep.out$Predicted)^2)
rMSE <- round(sqrt(mse), digits = 4)
lm.fit <- lm(Actual~Predicted, data = randomForest.statistical.threeStep.out)
s <- summary(lm.fit)
print(paste("Three step Random Forest: rMSE (", rMSE, ") - R2 (", round(s$adj.r.squared, digits = 4), ")", sep = ""))

# Removing the immediate results and clearing workspace before executing the next method
rm(s, mse, rMSE, lm.fit, randomForest.statistical.threeStep.out, randomForest.statistical.threeStep.tuned, randomForest.locomotion.tuned, randomForest.sedentary.tuned,
   Locomotion_labels, Sedentary_labels, threeStep_test.df, randomForest.locType.tuned, randomForest.sedType.tuned, locType, sedType, ctrl, mTry, tunegrid, nTree)


