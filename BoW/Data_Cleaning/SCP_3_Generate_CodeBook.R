#Script Details ------------------------------------------------------------------------------

#Script Name : SCP_3_Generate_CodeBook.R

#Script Summary : This script generates the codebook for 3s and 6s subsequences of the training set
#                 by using spark cluster framework using k-means clustering technique.

#Author & Reviewer Details -------------------------------------------------------------------

#Author : Avirup Chakraborty
#Date : 07/03/2017
#E-Mail : avirup1988@ufl.edu
#Reviewed By : Hiranava Das
#Review Date : 
#Reviewer E-Mail : hiranava@ufl.edu

#Parameter Settings --------------------------------------------------------------------------

#Load the spark libraries
library(sparklyr)
library(dplyr)

#Set the working directory to the location where this script is located. 

setwd("~/Desktop/Data_Mining_Project/Codes/Data_Cleaning/")

#Create the connection to local Spark Cluster
SC <- spark_connect(master = "local")

#Set the directory to the location where the subsequence files are present
ALLCHUNKSFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/BOW_Files/"

#Set the directory where the codebook.df would be stored
CODEBOOKFOLDER <- "~/Desktop/Data_Mining_Project/Raw_Data/Participant_Data/Cleaned_Data/"

#Set CHUNKSIZE = 3 or 6
CHUNKSIZE=3

#Data Loading ------------------------------------------------------------------------------------------

#Set the Number of Atoms for the codebook.df
if(CHUNKSIZE == 3)
{
  D<-32
  CODEBOOKFILENAME <- "codebook_W3_D32_dtw.Rdata"
  ALL3SCHUNKSFILENAME <- paste(ALLCHUNKSFOLDER,"Train_All_3s_Chunks.csv",sep = "")
  
  #Load All the 3s Data Chunks into a spark dataframe
  spark_read_csv(SC, "spark_all_3s_chunks_df", ALL3SCHUNKSFILENAME, memory = FALSE, overwrite = TRUE)
  
  # Selecting V1 to V30 (acceleration data) for clustering
  cluster_df_tbl <- tbl(SC,"spark_all_3s_chunks_df") %>% select(starts_with("V",ignore.case = FALSE))
  
} else if(CHUNKSIZE == 6)
{
  D<-64
  CODEBOOKFILENAME <- "codebook_W6_D64_dtw.Rdata"
  ALL6SCHUNKSFILENAME <- paste(ALLCHUNKSFOLDER,"Train_All_6s_Chunks.csv",sep = "")
  
  
  #Load All the 6s Data Chunks into a spark dataframe
  spark_read_csv(SC, "spark_all_6s_chunks_df", ALL6SCHUNKSFILENAME, memory = FALSE, overwrite = TRUE)
  
  # Selecting V1 to V30 (acceleration data) for clustering
  cluster_df_tbl <- tbl(SC,"spark_all_6s_chunks_df") %>% select(starts_with("V",ignore.case = FALSE))
}

#K-Means Clustering ---------------------------------------------------------------------------------------

# Applying k-means clustering to obtain the codebook
set.seed(5855)
cluster_outcome <- cluster_df_tbl %>% ml_kmeans(centers = D)

# Codebook is learned and stored in a R dataframe
atoms <- sapply(1:D, FUN = function(x) {as.character(paste("D", x, sep = ""))})
codebook.df <- data.frame(Atom = atoms, cluster_outcome$centers, row.names = NULL)

#Saving the Codebook -------------------------------------------------------------------------------------

#Save the codebook.df in a Rdata File

saveRDS(codebook.df, file = paste(CODEBOOKFOLDER,CODEBOOKFILENAME,sep = ""))

message(paste(CHUNKSIZE,"Seconds Codebook Generation Completed Successfully."))
