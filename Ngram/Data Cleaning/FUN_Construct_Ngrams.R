#Script Details -------------------------------------------------------------------------------------------------

#Script Name : FUN_Construct_Ngrams.R

#Script Summmary : This script contains three functions required for generating feature set using ngrams.
#     1. FUN_nGrams.construction: Function to convert accelerometer data into Representative Patterns (Unigrams and Bigrams)
#     2. FUN_nGrams.oneParticipant: Function to generate ngrams from accelerometer data for one participant
#     3. FUN_adjustFeatureSet: Function to adjust data values in combined feature set of all participants

#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Shikha Mehta
#Date : 07/08/2017
#E-Mail : shikha.mehta@ufl.edu
#Reviewed By : Madhurima Nath
#Review Date : 
#Reviewer E-Mail : madhurima09@ufl.edu

#----------------------------------------------------------------------------------------------------------------


# Input:
#      1. PID: participant unique identifier
#      2. Task: task title
#      3. taskData: accelerometer data vector for the given participant-task pair. This data has vector magnitude values.
#      4. binInterval: indicates the width of a bin such that the participant data can be divided into available bins
#      5. binCount: available number of bins to use for binning the wrist accelerometer data of the participant
#
# Output:
#      Returns a list of two data frames (Unigram and Bigram), each with the following columns:
#      1. PID: participant unique identifier
#      2. Task: task title
#      3. Unigram/Bigram patterns: features for the task
#
# Algorithm:
# 1. The total number of bins is received as input. We compute "binInterval" 
#    such that data for all visits can be distributed into all the bins.
# 2. For every task, we define a logical array. Let's call it "Unigrams".
#     2.1. each accelerometer data point (VM) in our dataset is checked.
#     2.2. for each data point, we assign a bin number (equal to accelerometer value / binInterval) in 'Unigrams'.
#     2.3. we define a 2-points sliding window, such as <p_1, p_2>.
#     2.4. the pattern for <Unigrams[p_1], Unigram[p_2]> is read. E.g., <1, 0>
#     2.5. this 2-points pattern is converted into one "Bigram".E.g., <10>
#     2.6. the 2-point window is shifted by 1 seconds. (we keep a 1-second overlapping point)
#     2.7. the process is repeated (go to 2.4) unless we reach the last second of the task.
#
FUN_nGrams.construction <- function(PID, Task, taskData, binInterval,binCount) {
  
  result.dfs <- list(data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE),data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE))
  
  Unigrams <- character(length = length(taskData))
  j <- 1
  for(VMvalue in taskData){
    Unigrams[j] <- as.character(floor(VMvalue/binInterval))
    if(Unigrams[j]==binCount)
      Unigrams[j] <- binCount-1
    j <- j + 1
  }
  
  Bigrams <- character(length = length(Unigrams)-1)
  i <- 1
  j <- j - 1
  while(i + 1 <= j) {
    sliding_window <- Unigrams[i:(i + 1)]
    Bigrams[i] <- as.character(paste(sliding_window, collapse = ""))
    i <- i + 1
  }
  
  U.df <- as.data.frame(table(Unigrams),stringsAsFactors=FALSE)
  UG.df <- as.data.frame(t(U.df),stringsAsFactors=FALSE)
  UnigramFeatureSet.df <- as.data.frame(UG.df[-1,],stringsAsFactors=FALSE)
  colnames(UnigramFeatureSet.df) <- unlist(UG.df[1,],use.names = TRUE)
  
  B.df <- as.data.frame(table(Bigrams),stringsAsFactors=FALSE)
  BG.df <- as.data.frame(t(B.df),stringsAsFactors=FALSE)
  BigramFeatureSet.df <- as.data.frame(BG.df[-1,],stringsAsFactors=FALSE)
  colnames(BigramFeatureSet.df) <- unlist(BG.df[1,],use.names = TRUE)
  
  participantInfo=data.frame(PID = PID, Task = Task,stringsAsFactors=FALSE)
  result.dfs <- list(merge(participantInfo,UnigramFeatureSet.df), merge(participantInfo,BigramFeatureSet.df))
  result.dfs
}


# Input:
#     1. participantID: participant unique identifier
#     2. ppt.df: (data.frame) containing wrist accelerometer data for all visits
#     3. binCount: available number of bins to use for binning the wrist accelerometer data of the participant
#
# Output:
#     Returns a list of two data frames: 
#     1. Unigram features for each <Participant, Task>.
#     2. Bigram features for each <Participant, Task>.
#
FUN_nGrams.oneParticipant <- function(participantID, ppt.df, binCount) {
  print(paste("Constructing n-grams for", participantID))
  require(plyr)
  
  # Calculating the offset for all Vector Magnitude values
  minVM<-min(ppt.df$VM)
  
  # Calculating bin interval for the current participant
  binInterval<-(max(ppt.df$VM)-minVM)/binCount
  
  result.dfs <- list(data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE),data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE))
  
  # Constructing features #
  for(task in unique(ppt.df$TaskLabel)){
    taskDataFrame <- ppt.df[ppt.df$TaskLabel==task,]
    print(paste(participantID, task, sep = " -- "))
    
    nGrams.df <- FUN_nGrams.construction(PID = participantID, Task = task, taskDataFrame$VM-minVM, binInterval,binCount) 
    if(nrow(nGrams.df[[1]]) > 0) {
        result.dfs[[1]] <- rbind.fill(result.dfs[[1]], nGrams.df[[1]])
    }
    if(nrow(nGrams.df[[2]]) > 0) {
       result.dfs[[2]] <- rbind.fill(result.dfs[[2]], nGrams.df[[2]])
    }
  }
  result.dfs[[1]][is.na(result.dfs[[1]])] <- 0
  result.dfs[[2]][is.na(result.dfs[[2]])] <- 0
  print(paste("Constructed n-gram features for", participantID))
  result.dfs
}


# Input:
#     features.df: combined feature set of all participants to process
#
# Output:
#     Returns a data frame with non-NA values and "B" appended to all feature columns
#
FUN_adjustFeatureSet<-function(features.df)
{
  # Update all NAs to 0
  features.df[is.na(features.df)] <- 0
  
  FeatureNames<-names(features.df)
  for(i in 3:ncol(features.df))
  {
    # Append feature name with "B"
    FeatureNames[[i]]<-as.character(paste("B",FeatureNames[[i]],sep=""))
    # Convert feature data to type - numeric
    features.df[,i]<-as.numeric(features.df[,i])
  }
  colnames(features.df) <- FeatureNames
  features.df
}
