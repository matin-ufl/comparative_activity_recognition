########################################################
# BoW functions.
# ___________________________
########################################################

# For every participant-task,
# 1. selects the right chunk of the Vector Magnitude (only for the given task)
# 2. spans a window with the defined length (default is 3 seconds)
# 3. that window will be a row to be converted to a word later.
# 4. then slides the window by 'slide.step' (default is 1 second)
#
# 5. returns a data.frame which has
#                   <PID, Task, window.index, [window-vector]>
bow.timeSeriesChunks.oneTask <- function(PID, Task, taskDataFrame, start.idx, end.idx, window.length = 3 * 10, slide.step = 10) {
  result <- data.frame(matrix(nrow = 0, ncol = (5 + window.length)))
  f.idx <- start.idx
  counter <- 1
  while(f.idx <= end.idx) {
    l.idx <- f.idx + window.length - 1
    if(l.idx <= end.idx) {
      result <- rbind(result,data.frame(PID, Task, as.character(taskDataFrame$Timestamp[f.idx]), as.character(taskDataFrame$Timestamp[l.idx]), Index = counter, matrix(taskDataFrame$VM[f.idx:l.idx], ncol = window.length, nrow = 1)))
    }
    f.idx <- f.idx + slide.step
    counter <- counter + 1
  }
  colnames(result) <- c("PID", "Task", "Start.Time", "End.Time", "Index", sapply(1:window.length, function(x) {paste("V", x, sep = "")}))
  result
}

# Input:
#     1. participantID: participant unique identifier
#     2. downsampledData.df: dataFrame containing the downsampled data for each participant 
#     3. epoch.length: (integer) indicates each epoch length (in 10 milliseconds) for which we construct features
#
# Output:
#     1. returns a data.frame which contains BoW vectors for each <Participant, Task, Epoch>.
bow.timeSeriesChunks.oneParticipant <- function(participantID, downsampledData.df, window.length = (3 * 10)) {
  message(paste("Constructing word representations for", participantID, " started."))
  
  result <- data.frame(matrix(nrow = 0, ncol = 12))
  
  # Constructing features #
  for(curr_task in unique(downsampledData.df$TaskLabel)){
    downsample_oneTask.df <- downsampledData.df[which(downsampledData.df$TaskLabel == curr_task),]
    start.idx <- min(which(downsample_oneTask.df$timeOnly ==  min(downsample_oneTask.df$timeOnly)))
    end.idx <- max(which(downsample_oneTask.df$timeOnly ==  max(downsample_oneTask.df$timeOnly)))
    
    message(paste(participantID, curr_task, sep = " -- "))
    
    bow.df <- bow.timeSeriesChunks.oneTask(PID = participantID, Task = curr_task, taskDataFrame = downsample_oneTask.df, start.idx, end.idx, window.length)
    
    if(nrow(bow.df) > 0) {
      result <- rbind(result, bow.df)
    }
    
  }
  
  result
}
