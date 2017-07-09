#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : FUN_BOW_Functions.R

#Script Summary : 
#       This script contains three functions required for TF-IDF Calculations.
#         1. FUN_BOW_TimeSeriesChunks_OneTask : Function to generate subsequences for one task of a participant.
#         2. FUN_BOW_TimeSeriesChunks_OneParticipant : Function to generate subsequences for a participant.

#Author & Reviewer Details ------------------------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu


#FUN_BOW_TimeSeriesChunks_OneTask

FUN_BOW_TimeSeriesChunks_OneTask <- function(PID, Task, taskDataFrame.df, start.idx, end.idx, window.length = 3 * 10, slide.step = 10) {
  
  # Input :- 
  #       1. PID : Participant ID
  #       2. Task : Task Name
  #       3. taskDataFrame.df : Dataframe containing a single task data.
  #       4. start.idx : Start Timestamp Index
  #       5. end.idx : End Timestamp Index
  #       6. window.length : Window Chunk Size
  #       7. slide.step : Window step increment
  # Output :- 
  #       1. result.df : This dataframe contains the BOW subsequences for one task.
  
  result.df <- data.frame(matrix(nrow = 0, ncol = (5 + window.length)))
  f.idx <- start.idx
  counter <- 1
  while(f.idx <= end.idx) {
    l.idx <- f.idx + window.length - 1
    if(l.idx <= end.idx) {
      result.df <- rbind(result.df,data.frame(PID, Task, as.character(taskDataFrame.df$Timestamp[f.idx]), as.character(taskDataFrame.df$Timestamp[l.idx]), Index = counter, matrix(taskDataFrame.df$VM[f.idx:l.idx], ncol = window.length, nrow = 1)))
    }
    f.idx <- f.idx + slide.step
    counter <- counter + 1
  }
  colnames(result.df) <- c("PID", "Task", "Start.Time", "End.Time", "Index", sapply(1:window.length, function(x) {paste("V", x, sep = "")}))
  result.df
}


#FUN_BOW_TimeSeriesChunks_OneParticipant

FUN_BOW_TimeSeriesChunks_OneParticipant <- function(participantID, downsampledData.df, window.length = (3 * 10)) {
  
  # Input :- 
  #       1. participantID : Participant ID
  #       2. downsampledData.df : Dataframe containing a downsampled data for one participant.
  #       3. window.length : Window Chunk Size
  # Output :- 
  #       1. result.df : This dataframe contains the BOW subsequences for one participant.
  
  
  message(paste("Constructing word representations for", participantID, " started."))
  
  result.df <- data.frame(matrix(nrow = 0, ncol = 12))
  
  # Constructing features for each participant task
  for(curr_task in unique(downsampledData.df$TaskLabel)){
    downsample_oneTask.df <- downsampledData.df[which(downsampledData.df$TaskLabel == curr_task),]
    start.idx <- min(which(downsample_oneTask.df$timeOnly ==  min(downsample_oneTask.df$timeOnly)))
    end.idx <- max(which(downsample_oneTask.df$timeOnly ==  max(downsample_oneTask.df$timeOnly)))
    
    message(paste(participantID, curr_task, sep = " -- "))
    
    bow.df <- FUN_BOW_TimeSeriesChunks_OneTask(PID = participantID, Task = curr_task, taskDataFrame.df = downsample_oneTask.df, start.idx, end.idx, window.length)
    
    if(nrow(bow.df) > 0) {
      result.df <- rbind(result.df, bow.df)
    }
    
  }
  
  result.df
}