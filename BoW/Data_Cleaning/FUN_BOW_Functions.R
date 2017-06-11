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
#     2-6. ppt.vX.df: (data.table) containing wrist accelerometer data for VX
#     7. taskTimes.df: (data.frame) containing tasktimes data: start and end times of each task for the given participant
#     8. epoch.length: (integer) indicates each epoch length (in 10 milliseconds) for which we construct features
#
# Output:
#     1. returns a data.frame which contains BoW vectors for each <Participant, Task, Epoch>.
bow.timeSeriesChunks.oneParticipant <- function(participantID, ppt.v1.df, ppt.v2.df, ppt.v3.df, ppt.v4.df, taskTimes.df, window.length = (3 * 10)) {
  message(paste("Constructing word representations for", participantID, " started."))
  
  result <- data.frame(matrix(nrow = 0, ncol = 12))

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
    if(is.na(taskDataFrame)) {
      message(paste("Skipping ", participantID, "-", Task, " (", visit, "). Since there is no visit file.", sep = ""))
      next()
    } else {
      process.status <- TRUE
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
        bow.df <- bow.timeSeriesChunks.oneTask(PID = participantID, Task = taskTimes.ppt.df$task[1], taskDataFrame, start.idx, end.idx, window.length)
        if(nrow(bow.df) > 0) {
          result <- rbind(result, bow.df)
        }
      }
    }
  }
  result
}