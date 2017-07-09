#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_2_Merge_All_Subsequences.R

#Script Summary : This script merges all the sub-sequences (3s or 6s) 
#                 from the individual Rdata files and saves it in a single file. 

#Author & Reviewer Details -------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings --------------------------------------------------------------------------

#Set the working directory to the location where the scripts and function R files are located

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Set the directory to the location where the subsequence files are present

DATAFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/BOW_Files/"

#Set FILETYPE = (Training_Set or Testing_Set) and CHUNKSIZE = (3 or 6).
CHUNKSIZE=3
FILETYPE <- "Testing_Set"


if(FILETYPE == "Testing_Set")
{
  FILEDIR <- "Testing_Set/"
  OUTFILEPREFIX <- "Test_"
  
} else {
  
  FILEDIR <- "Training_Set/"
  OUTFILEPREFIX <- "Train_"
}

if (CHUNKSIZE == 3)
{
  # Merging all 3s BoW chunks into one data.frame
  filelist <- dir(path = paste(DATAFOLDER,"Three-second chunks/",FILEDIR,sep=""), pattern = "^.*.Rdata$") 
  CHUNKFILENAME<- paste(OUTFILEPREFIX,"All_3s_Chunks.Rdata",sep = "")
  
  #Additional csv copy of file for codebook learning
  
  if(FILETYPE == "Training_Set")
  {
    CHUNKFILENAME1 <- paste(OUTFILEPREFIX,"All_3s_Chunks.csv",sep = "")
  }
  
  #Merge All the Chunks for all participants
  allChunks.df <- data.frame(matrix(nrow = 0, ncol = 35))
  for(fileName in filelist) {
    bowChunks.df <- readRDS(paste(DATAFOLDER, "Three-second chunks/", FILEDIR, fileName, sep = ""))
    allChunks.df <- rbind(allChunks.df, bowChunks.df)
  }
  
} else if (CHUNKSIZE == 6)
{
  # Merging all 6s BoW chunks into one data.frame
  l <- dir(path = paste(DATAFOLDER,"Six-second chunks/",FILEDIR,sep=""), pattern = "^.*.Rdata$") 
  CHUNKFILENAME<- paste(OUTFILEPREFIX,"All_6s_Chunks.Rdata",sep = "")
  
  #Additional csv copy of file for codebook learning
  
  if(FILETYPE == "Training_Set")
  {
    CHUNKFILENAME1 <- paste(OUTFILEPREFIX,"All_6s_Chunks.csv",sep = "")
  }
  
  #Merge All the Chunks for all participants
  allChunks.df <- data.frame(matrix(nrow = 0, ncol = 35))
  for(fileName in l) {
    bowChunks.df <- readRDS(paste(DATAFOLDER, "Six-second chunks/", FILEDIR, fileName, sep = ""))
    allChunks.df <- rbind(allChunks.df, bowChunks.df)
  }
}

#Removing unused dataframes for reducing memory overhead
rm(fileName, bowChunks.df)

#Merge Sub-sequences --------------------------------------------------------------------------

# Removing unnecessary tasks from this raw dataset
keep.these.tasks <- c("LIGHT GARDENING", "YARD WORK", "DIGGING", "LEISURE WALK",
                      "RAPID WALK", "SWEEPING", "PREPARE SERVE MEAL", "STRAIGHTENING UP DUSTING",
                      "WASHING DISHES", "UNLOADING STORING DISHES", "VACUUMING", "WALKING AT RPE 1", 
                      "PERSONAL CARE", "DRESSING", "WALKING AT RPE 5", "STAIR DESCENT",
                      "STAIR ASCENT", "TRASH REMOVAL", "REPLACING SHEETS ON A BED", "STRETCHING YOGA",
                      "MOPPING", "COMPUTER WORK", "LAUNDRY WASHING", "SHOPPING",
                      "IRONING", "LIGHT HOME MAINTENANCE", "WASHING WINDOWS", "HEAVY LIFTING",
                      "STRENGTH EXERCISE LEG CURL", "STRENGTH EXERCISE CHEST PRESS", "STRENGTH EXERCISE LEG EXTENSION", "TV WATCHING",
                      "STANDING STILL")
rawBoW.df <- allChunks.df[allChunks.df$Task %in% keep.these.tasks, ]
rawBoW.df$PID <- as.character(rawBoW.df$PID); 
rawBoW.df$Task <- as.character(rawBoW.df$Task); 
rawBoW.df$Start.Time <- as.character(rawBoW.df$Start.Time); 
rawBoW.df$End.Time <- as.character(rawBoW.df$End.Time)

#Save output files --------------------------------------------------------------------------

#Save the merged dataframe into a RData file
saveRDS(rawBoW.df, file = paste(DATAFOLDER,CHUNKFILENAME, sep=""))

#Save additional csv copy of training set file for codebook learning
if(FILETYPE == "Training_Set")
{
  write.csv(rawBoW.df, file = paste(DATAFOLDER,CHUNKFILENAME1, sep=""), row.names=FALSE)
}

message(paste(CHUNKSIZE," seconds sub-sequences file merging completed for ",FILETYPE,".",sep = ""))
