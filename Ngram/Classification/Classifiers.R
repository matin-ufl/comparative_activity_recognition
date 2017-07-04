prepare_for_classification<-function(dataFolder,ngramType)
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
  
  # Discarding Task column
  features.df <- as.data.frame(features.df[ , -which(names(features.df) %in% c("Task","PID"))],stringAsFactors=TRUE)
  
  # Converting the class-label column to factor
  features.df$class.sedentary <- as.factor(features.df$class.sedentary)
  features.df$class.locomotion <- as.factor(features.df$class.locomotion)
  features.df  
}

random_forest_classify<-function(training.df,testing.df)
{
  library(randomForest)
  set.seed(5855)
  
  # Sedentary classification --------------------------
  rf.model <- randomForest(data = training.df, class.sedentary ~ ., ntree = 10000, mtry = 2)
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
  rf.model <- randomForest(data = training.df, class.locomotion ~ ., ntree = 10000, mtry = 2)
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
