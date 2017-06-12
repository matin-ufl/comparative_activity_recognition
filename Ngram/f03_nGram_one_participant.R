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
#      3. METs: MET score (energy expenditure) for the given task
#      4. taskDataFrame: accelerometer data.frame. This data.frame should contain a VM column for vector magnitude.
#      5. start.idx: indicates from which point we should check the taskDataFrame$VM
#      6. end.idx: indicates at which point the task ends in the taskDataFrame$VM
#      7. binInterval: indicates the width of a bin such that the participant data can be divided into 10 bins
#
# Output:
#      a data.frame with the following columns:
#      1. PID: participant unique identifier
#      2. Task: task title
#      3. start.time: when the task started
#      4. end.time: when the task ended
#      5. METs: MET score (energy expenditure) for the given task
#      6. Applicable unigram and bigram patterns: features for the given task

nGram.construction <- function(PID, Task, METs, taskDataFrame, start.idx, end.idx, binInterval) {
  result <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
  if(length(start.idx) == 0 || length(end.idx) == 0) {
    return(result)
  }
  if(end.idx < start.idx) {
    print(paste(PID, Task, "Start time is after end time?!",sep = " - "))
    return(result)
  }
  
  Unigrams <- character(length = ceiling(end.idx - start.idx)+1)
  j <- 1
  for(i in seq(start.idx, end.idx)){
    Unigrams[j] <- as.character(floor(taskDataFrame$VM[i]/binInterval))
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
  UGFinal <- as.data.frame(UG[-1,],stringsAsFactors=FALSE)
  colnames(UGFinal) <- unlist(UG[1,],use.names = TRUE)
  
  B <- as.data.frame(table(Bigrams),stringsAsFactors=FALSE)
  BG <- as.data.frame(t(B),stringsAsFactors=FALSE)
  BGFinal <- as.data.frame(BG[-1,],stringsAsFactors=FALSE)
  colnames(BGFinal) <- unlist(BG[1,],use.names = TRUE)
  
  feature.set=merge(UGFinal,BGFinal)
  participantInfo=data.frame(PID = PID, Task = Task, start.time = taskDataFrame$Timestamp[start.idx], end.time = taskDataFrame$Timestamp[end.idx],
                             METs = METs,stringsAsFactors=FALSE)
  result <- merge(participantInfo,feature.set)
  result
}


# Input:
#     1. participantID: participant unique identifier
#     2. cosmed.df: (data.frame) containing all cosmed information for every participant-task row
#     3-7. ppt.vX.df: (data.table) containing wrist accelerometer data for VX
#     8. taskTimes.df: (data.frame) containing tasktimes data: start and end times of each task for the given participant
#     9. epoch.length: (integer) indicates each epoch length (in 10 milliseconds) for which we construct features
#
# Output:
#     1. returns a data.frame which contains Unigram and Bigram features for each <Participant, Task, Epoch>.
nGram.oneParticipant <- function(participantID, cosmed.df, ppt.v1.df, ppt.v2.df, ppt.v3.df, ppt.v4.df, taskTimes.df) {
  message(paste("Constructing n-grams for", participantID, " started."))
  require(plyr)
  
  if(length(na.omit(ppt.v1.df))>0)
  {
    minVMForVisits <- c(min(ppt.v1.df$VM))
    maxVMForVisits <- c(max(ppt.v1.df$VM))
  }
  
  if(length(na.omit(ppt.v2.df))>0)
  {
    minVMForVisits <- c(minVMForVisits, min(ppt.v2.df$VM))
    maxVMForVisits <- c(maxVMForVisits, max(ppt.v2.df$VM))
  }
   
  if(length(na.omit(ppt.v3.df))>0)
  {
    minVMForVisits <- c(minVMForVisits, min(ppt.v3.df$VM))
    maxVMForVisits <- c(maxVMForVisits, max(ppt.v3.df$VM))
  } 
  
  if(length(na.omit(ppt.v4.df))>0)
  {
    minVMForVisits <- c(minVMForVisits, min(ppt.v4.df$VM))
    maxVMForVisits <- c(maxVMForVisits, max(ppt.v4.df$VM))
  }
  
  #Calculating bin interval for the current participant
  binInterval=(max(maxVMForVisits)-min(minVMForVisits))/10
  
  result <- data.frame(matrix(nrow = 0, ncol = 0),stringsAsFactors=FALSE)
  
  # Selecting the part of cosmed.df dataframe which is related to the current participant.
  ppt.cosmed.df <- cosmed.df[cosmed.df$participant_acrostic == participantID, ]
  
  # Constructing features #
  for(i in 1:nrow(taskTimes.df)){
    taskTimes.ppt.df <- taskTimes.df[i, ]
    visit <- trimws(taskTimes.ppt.df$visit[1])
    taskDataFrame <- ppt.v1.df
    Task <- taskTimes.ppt.df$task[1]
    message(paste(participantID, Task, sep = " -- "))
    if(visit == 'V2') {
      taskDataFrame <- ppt.v2.df
    } else if(visit == 'V3') {
      taskDataFrame <- ppt.v3.df
    } else if(visit == 'V4') {
      taskDataFrame <- ppt.v4.df
    } else if(visit == 'VH') {
      next()
    }
    process.status <- TRUE
    if(length(na.omit(taskDataFrame))==0)
      next()
    start.idx <- which(taskDataFrame$timeOnly == taskTimes.ppt.df$start[1])
    if(length(start.idx) == 0) {
      warning(paste("No start time found for participant (", participantID, ") and task (", Task, ")", sep = ""))
      process.status <- FALSE
      next
    } else {
      start.idx <- min(start.idx)
    }
    end.idx <- which(taskDataFrame$timeOnly == taskTimes.ppt.df$end[1])
    if(length(end.idx) == 0) {
      warning(paste("No end time found for participant (", participantID, ") and task (", Task, ")", sep = ""))
      process.status <- FALSE
      next
    } else {
      end.idx <- max(end.idx)
    }
    if(process.status) {
      METs <- NA
      MET.idx <- which(ppt.cosmed.df$task == Task)
      if(length(MET.idx) > 0) {
        METs <- ppt.cosmed.df$METs[MET.idx]
      }
      
      nGram.df <- nGram.construction(PID = participantID, Task = taskTimes.ppt.df$task[1], METs, taskDataFrame, start.idx, end.idx, binInterval) 
      if(nrow(nGram.df) > 0) {
          result <- rbind.fill(result, nGram.df)
      }
    }
  }
  result[is.na(result)] <- 0
  result
}

# Receives two arguments:
#     1. dataFolder: the address where participants' data are located.
#     2. participantID: participant unique identifier
#
# Finds wrist accelerometer files for the given participant and returns a list:
#     1. ppt.v1.df: a data.table consisting of V1 wrist accelerometer data
#     2. ppt.v2.df: a data.table consisting of V2 wrist accelerometer data
#     3. ppt.v3.df: a data.table consisting of V3 wrist accelerometer data
#     4. ppt.v4.df: a data.table consisting of V4 wrist accelerometer data
read.participant.files <- function(dataFolder, participantID) {
  require(data.table)
  
  # Locating participant's folder
  participantFolder <- dir(path = dataFolder, pattern = paste("^", participantID, ".*$", sep = ""))
  if(length(participantFolder) == 0) {
    stop("Participant Data are not found.") # if for a participant we do not have a data folder, we should not continue.
  }
  participantFolder <- paste(dataFolder, participantFolder, "/", sep = "")
  
  # Reading wrist accelerometer file for visit V1
  ppt.v1.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V1-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V1 visit.")
  } else {
    ppt.v1.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = "")) # similar to read.csv() function.
    colnames(ppt.v1.df) <- c("Timestamp", "X", "Y", "Z") # Renaming columns name for convenicence.
    
    ppt.v1.df$temp <- 1:nrow(ppt.v1.df)
    ppt.v1.df$Timestamp <- as.character(ppt.v1.df$Timestamp)
    ppt.v1.df[, VM := sqrt(X^2 + Y^2 + Z^2)] # calculating Vector Magnitude and adding a column 'VM' to our dataset
    # We also need to construct a timeOnly column for a more efficient search. See the three lines below.
    ppt.v1.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v1.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v1.df[, temp := NULL] 
  }
  message("V1 data loaded.")
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v2.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V2-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V2 visit.")
  } else {
    ppt.v2.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v2.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v2.df$temp <- 1:nrow(ppt.v2.df)
    ppt.v2.df$Timestamp <- as.character(ppt.v2.df$Timestamp)
    ppt.v2.df[, VM := sqrt(X^2 + Y^2 + Z^2)]
    ppt.v2.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v2.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v2.df[, temp := NULL]
  }
  message("V2 data loaded.")
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v3.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V3-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V3 visit.")
  } else {
    ppt.v3.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v3.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v3.df$temp <- 1:nrow(ppt.v3.df)
    ppt.v3.df$Timestamp <- as.character(ppt.v3.df$Timestamp)
    ppt.v3.df[, VM := sqrt(X^2 + Y^2 + Z^2)]
    ppt.v3.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v3.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v3.df[, temp := NULL]
  }
  message("V3 data loaded.")
  
  # Similar to reading wrist accelerometer file for visit 1.
  ppt.v4.df <- NA
  visitFileName <- dir(path = paste(participantFolder, "Wrist/", sep = ""), pattern = "^.*V4-.*$")
  if(length(visitFileName) == 0) {
    warning("Participant does not have Wrist data for V4 visit.")
  } else {
    ppt.v4.df <- fread(input = paste(participantFolder, "Wrist/", visitFileName, sep = ""))
    colnames(ppt.v4.df) <- c("Timestamp", "X", "Y", "Z")
    
    ppt.v4.df$temp <- 1:nrow(ppt.v4.df)
    ppt.v4.df$Timestamp <- as.character(ppt.v4.df$Timestamp)
    ppt.v4.df[, VM := sqrt(X^2 + Y^2 + Z^2)]
    ppt.v4.df[, timeOnly := as.character(unlist(strsplit(Timestamp, split = " "))[2]), by = temp]
    ppt.v4.df[, timeOnly := as.character(unlist(strsplit(timeOnly, split = "\\."))[1]), by = temp]
    ppt.v4.df[, temp := NULL]
  }
  message("V4 data loaded.")
  
  result <- list(ppt.v1.df, ppt.v2.df, ppt.v3.df, ppt.v4.df, taskTimes.df)
  result
}