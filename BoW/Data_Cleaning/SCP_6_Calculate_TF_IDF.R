
#Set the working directory to the location where the scripts and function R files are located 

setwd("~/Desktop/Data_Mining_Project/Data_Cleaning_Code/My_Code")


#Set Chunk Size when the script needs to be run as a standalone
#chunksize=3

#Set the directory where the DTW subsequnces with labels are stored
datafolder <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant Data/Cleaned_Data/"

if(chunksize == 3)
{
  #Number of atoms
  d <- 32
  
  #Atom List
  atoms <- sapply(1:d, FUN = function(x) {as.character(paste("D", x, sep = ""))})
  
  #Load the word label file
  merged.df <- readRDS(file = paste(datafolder,"merged_BoW_labeled_W3_D32_dtw.Rdata",sep = ""))
  
  #Outputfilename
  BOWfilename <- "BoW_W3_D32_dtw.Rdata"
  
} else if (chunksize == 6)
{
  #Number of atoms
  d <- 64
  
  #Atom List
  atoms <- sapply(1:d, FUN = function(x) {as.character(paste("D", x, sep = ""))})
  
  #Load the codebook
  merged.df <- readRDS(file = paste(datafolder,"merged_BoW_labeled_W6_D64_dtw.Rdata",sep = ""))
  
  #Outputfilename
  BOWfilename <- "BoW_W6_D64_dtw.Rdata"
  
}


# Calculating TF_IDF for each ppt-task
justWords.df <- merged.df[, c(1:5, ncol(merged.df))]

# First, term frequency (TF): we use augmented frequency to prevent a bias towards longer documents.
TF.df <- data.frame(matrix(nrow = 0, ncol = 4))
for(ppt in levels(as.factor(justWords.df$PID))) {
  ppt.df <- justWords.df[justWords.df$PID == ppt, ]
  for(task in levels(as.factor(ppt.df$Task))) {
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
rm(maxTF, curTF.df, count, augmented.frequency, ppt.df, task.df, word, ppt)

# Second, inverse document frequency (IDF) is calculated.
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
rm(word, n_word)



# Final stage of data cleaning
bow_dtw.df <- data.frame(matrix(nrow = 0, ncol = 2 + d))
for(ppt in levels(as.factor(TF.df$PID))) {
  ppt.df <- TF.df[TF.df$PID == ppt, ]
  for(task in levels(as.factor(ppt.df$Task))) {
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
rm(ppt, ppt.df, task, task.df, temp.df, pptTF.df, taskTF.df, i)


# Dataset is ready! Save it to a file!
saveRDS(bow_dtw.df, file = paste(datafolder,BOWfilename,sep = ""))
