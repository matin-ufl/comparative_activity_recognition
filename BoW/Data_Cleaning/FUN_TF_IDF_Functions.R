#Script Details -------------------------------------------------------------------------------------

#Script Name : FUN_TF_IDF_Functions.R

#Script Summary : 
#       This script contains three functions required for TF-IDF Calculations.
#         1. FUN_Calc_Term_Frequency : Function to calculate the Term-Frequency.
#         2. FUN_Calc_Inverse_Doc_Frequency : Function to calculate the Inverse Document Frequency.
#         3. FUN_Calc_BOW_Data : Function to calculate the Final Bag of Words Data.

#Author & Reviewer Details --------------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu


# FUN_Calc_Term_Frequency

FUN_Calc_Term_Frequency <- function(justWords.df) {
  
  # Input :- justWords.df : This dataframe contains the BOW values for each ppt-task.
  # Output :- TF.df : This dataframe contains the calculated Term-Frequency for each ppt-task.
  
  TF.df <- data.frame(matrix(nrow = 0, ncol = 4))
  for(ppt in unique(justWords.df$PID)) {
    message(paste("TF Calculation for Participant :", ppt))
    ppt.df <- justWords.df[justWords.df$PID == ppt, ]
    for(task in unique(ppt.df$Task)) {
      task.df <- ppt.df[ppt.df$Task == task, ]
      numberOfWords <- nrow(task.df)          
      curTF.df <- data.frame(matrix(nrow = 0, ncol = 2))
      for(word in atoms) {
        curTF.df <- rbind(curTF.df, data.frame(TF = length(which(task.df$Word == word)), Word = word))
      }
      maxTF <- max(curTF.df$TF)
      for(word in curTF.df$Word) {
        count <- curTF.df$TF[curTF.df$Word == word]
        if (maxTF > 0) {
          augmented.frequency <- 0.5 + (0.5 * (count / maxTF))
        } 
        TF.df <- rbind(TF.df,
                       data.frame(PID = ppt, Task = task, Word = word, Count = count,  TF = augmented.frequency))
      }
      
    }
  }
  return(TF.df)
}

# FUN_Calc_Inverse_Doc_Frequency

FUN_Calc_Inverse_Doc_Frequency <- function(TF.df, atoms, d) {
  
  # Input :- TF.df : This dataframe contains the calculated Term-Frequency for each ppt-task.
  #          atoms : List of Atoms.
  #          d : Number of atoms.
  # Output :- IDF.df : This dataframe contains the calculated Inverse Document Frequency.
  
  numberOfTasks <- nrow(TF.df) / d
  IDF.df <- data.frame(Word = atoms, IDF = NA)
  for(word in levels(as.factor(IDF.df$Word))) {
    n_word <- length(which(TF.df$Count[TF.df$Word == word] > 0))
    if(n_word > 0){
      IDF.df$IDF[IDF.df$Word == word] <- log(numberOfTasks / n_word)
    } else {
      IDF.df$IDF[IDF.df$Word == word] <- as.integer(0)
    }
    
  }
  return(IDF.df)
}

# FUN_Calc_BOW_Data

FUN_Calc_BOW_Data <- function(TF.df,IDF.df, d) { 
  
  # Input :- TF.df : This dataframe contains Term Frequency values.
  #          IDF.df : This dataframe contains Inverse Document Frequency values.
  # Output :- bow_dtw.df : This dataframe contains the final Bag of Words Cleaned Data.
  
  bow_dtw.df <- data.frame(matrix(nrow = 0, ncol = 2 + d))
  for(ppt in unique(TF.df$PID)) {
    message(paste("Final BOW Data Calculation for Participant :", ppt))
    ppt.df <- TF.df[TF.df$PID == ppt, ]
    for(task in unique(ppt.df$Task)) {
      task.df <- ppt.df[ppt.df$Task == task, ]
      temp.df <- data.frame(matrix(NA, nrow = 1, ncol = 2 + d))
      colnames(temp.df) <- c("PID", "Task", atoms)
      temp.df$PID <- as.character(ppt)
      temp.df$Task <- as.character(task)
      pptTF.df <- TF.df[TF.df$PID == ppt, ]
      taskTF.df <- pptTF.df[pptTF.df$Task == task, ]
      for(i in 1:d) {
        temp.df[, i + 2] <- taskTF.df$TF[i] * IDF.df$IDF[i]
      }
      bow_dtw.df <- rbind(bow_dtw.df, temp.df)
    }
  }
  
  return (bow_dtw.df)
}
