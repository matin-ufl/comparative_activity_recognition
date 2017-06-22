# Converts accelerometer data for a participant into Representative Patterns (Unigrams and Bigrams).
# 1. The total number of bins is defined as 10. We compute "binInterval" such that data for all visits can be distributed into the 10 bins.
# 2. For every task, we define a logical array. Let's call it "Unigrams".
#     2.1. each accelerometer data point (VM) in our dataset is checked.
#     2.2. for each data point, we assign a bin number (equal to accelerometer value / binInterval) in 'Unigrams'.
#     2.3. we define a 2-points sliding window, such as <p_1, p_2>.
#     2.4. the pattern for <Unigrams[p_1], Unigram[p_2]> is read. E.g., <1, 0>
#     2.5. this 2-points pattern is converted into one "Bigram".E.g., <10>
#     2.6. the 2-point window is shifted by 1 seconds. (we keep a 1-second overlapping point)
#     2.7. the process is repeated (go to 2.4) unless we reach the last second of the task.
#
# Input:
#      1. PID: participant unique identifier
#      2. Task: task title
#      3. taskData: accelerometer data vector for the given participant-task pair. This data has vector magnitude values.
#      4. binInterval: indicates the width of a bin such that the participant data can be divided into 10 bins
#
# Output:
#      Returns a list of two data frames (Unigram and Bigram), each with the following columns:
#      1. PID: participant unique identifier
#      2. Task: task title
#      3. Unigram/Bigram patterns: features for the task

nGrams.construction <- function(PID, Task, taskData, binInterval) {
  
  result <- list(data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE),data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE))
  
  Unigrams <- character(length = length(taskData))
  j <- 1
  for(VMvalue in taskData){
    Unigrams[j] <- as.character(floor(VMvalue/binInterval))
    if(Unigrams[j]==10)
      Unigrams[j] <- 9
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
  
  U <- as.data.frame(table(Unigrams),stringsAsFactors=FALSE)
  UG <- as.data.frame(t(U),stringsAsFactors=FALSE)
  UnigramFeatureSet <- as.data.frame(UG[-1,],stringsAsFactors=FALSE)
  colnames(UnigramFeatureSet) <- unlist(UG[1,],use.names = TRUE)
  
  B <- as.data.frame(table(Bigrams),stringsAsFactors=FALSE)
  BG <- as.data.frame(t(B),stringsAsFactors=FALSE)
  BigramFeatureSet <- as.data.frame(BG[-1,],stringsAsFactors=FALSE)
  colnames(BigramFeatureSet) <- unlist(BG[1,],use.names = TRUE)
  
  participantInfo=data.frame(PID = PID, Task = Task,stringsAsFactors=FALSE)
  result <- list(merge(participantInfo,UnigramFeatureSet), merge(participantInfo,BigramFeatureSet))
  result
}


# Input:
#     1. participantID: participant unique identifier
#     2. ppt.df: (data.table) containing wrist accelerometer data for all visits
#     3. taskTimes.df: (data.frame) containing tasktimes data: start and end times of each task for the given participant
#
# Output:
#     Returns a list of two data frames: 
#     1. Unigram features for each <Participant, Task>.
#     2. Bigram features for each <Participant, Task>.
nGrams.oneParticipant <- function(participantID, ppt.df) {
  print(paste("Constructing n-grams for", participantID))
  require(plyr)
  
  # Calculating the offset for all Vector Magnitude values
  minVM<-min(ppt.df$VM)
  
  # Calculating bin interval for the current participant
  binInterval<-(max(ppt.df$VM)-minVM)/10
  
  result <- list(data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE),data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE))
  
  # Constructing features #
  for(task in unique(ppt.df$TaskLabel)){
    taskDataFrame <- ppt.df[ppt.df$TaskLabel==task,]
    print(paste(participantID, task, sep = " -- "))
    
    nGrams.df <- nGrams.construction(PID = participantID, Task = task, taskDataFrame$VM-minVM, binInterval) 
    if(nrow(nGrams.df[[1]]) > 0) {
        result[[1]] <- rbind.fill(result[[1]], nGrams.df[[1]])
    }
    if(nrow(nGrams.df[[2]]) > 0) {
       result[[2]] <- rbind.fill(result[[2]], nGrams.df[[2]])
    }
  }
  result[[1]][is.na(result[[1]])] <- 0
  result[[2]][is.na(result[[2]])] <- 0
  print(paste("Constructed n-gram features for", participantID))
  result
}
