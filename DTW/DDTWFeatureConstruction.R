#Author & Reviewer Details --------------------------------------------------------------------------------------

#Author : Madhurima Nath
#Date : 07/11/2017
#E-Mail : madhurima09@ufl.edu
#Reviewed By : Shikha Mehta
#Review Date : 
#Reviewer E-Mail : shikha.mehta@ufl.edu
#----------------------------------------------------------------------------------------------------------------
# Input:
#      1. dataframe:containing VM values of a task
# Output:
#      Returns a data frame with the following column:
#      1. Dist: containing ddtw distances 
#

library(dplyr)  
library(dtw)
calculateDDTW<-function(dataframe)
{
  ddtw.df <- data.frame(matrix(nrow = 0, ncol = 1))
  colnames(ddtw.df) <- c("Dist")
  
  for(i in 2:(nrow(dataframe)-1))
  {
    ddtw <- ((dataframe[i,1]-dataframe[i-1,1])+((dataframe[i+1,1]-dataframe[i-1,1])/2))/2
    intermediate_ddtw <- data.frame(dist=ddtw)
    ddtw.df <- rbind(ddtw.df,intermediate_ddtw)
  }
  ddtw.df
}

# Input:
#      1. test1:test dataframe
#      2. ppt1: train dataframe
#
# Output:
#      Returns a data frame with the following columns:
#      1. TaskLabel: the acitivity of the user
#      2. Dist: min dist of the task from train participants
#
# Converts accelerometer data for a participant into Time series data.
# ALGORITHM:
# 1. Train data frame for a participant is received as input. Total number of activities
#    is extracted from the train dataframe..
# 2. For each extracted task-
#     2.1. train and test data frames are filtered with matching task names
#     2.2. each dataframe is aggregated over VM column grouping by timeOnly Column
#     2.3. on the reduced data sample, mean is calculated every 3th row to further downsample the data
#     2.4. DDTW is calculated on each of the train and test dataframes
#     2.5. for each point on test dataframe, dtw distance is calculated from the train data frame
#     2.6. min ddtw distance is obtained and saved
#     2.7. ddtw feature set is constructed using task label obtained from step 1 and ddtw min distance obtained from previous step.
#

DDTWFeature.OneParticipant<-function(test1,ppt1)
{
  ddtw.df <- data.frame(matrix(nrow = 0, ncol = 2))
  colnames(ddtw.df) <- c("Label","Dist")
  options("scipen"=100, "digits"=4)
  for(i in 1:length(activities))
  {
    current_activity_type<-activities[i]
    test_df <- filter(test1, TaskLabel == current_activity_type)
    train_df <- filter(ppt1, TaskLabel == current_activity_type)
    
    #Here I'm aggregating column 2 of data.frame d, grouping by timeOnly, and applying the mean function.
    test_df<-aggregate(test_df$VM, list(test_df$timeOnly), mean)
    train_df <-aggregate(train_df$VM, list(train_df$timeOnly), mean)
    #calculate mean every 3th row to downsample the dataset.
    n <- 3 # every 3 rows
    #The important part of this solution that handles the issue of non-divisibility of nrow(df) by n is specifying the len parameter (actually the full parameter name is length.out) of rep(), which automatically caps the group vector to the appropriate length.
    test_df<-aggregate(test_df$x,list(rep(1:(nrow(test_df)%/%n+1),each=n,len=nrow(test_df))),mean)[-1];
    train_df<-aggregate(train_df$x,list(rep(1:(nrow(train_df)%/%n+1),each=n,len=nrow(train_df))),mean)[-1];
    
    test_df<-calculateDDTW(test_df)
    train_df<-calculateDDTW(train_df)
    
    dmin<-1000
    for(j in 1:nrow(test_df))
    {
      test_vm<-test_df[j,1]
      for(k in 1:nrow(train_df))
      {
        d <- dtw(test_vm,train_df[k,1])$distance
        if(d<dmin)
        {
          dmin<-d
        }
      }
    }
    intermediate_feature <- data.frame(Label=current_activity_type,Dist=dmin)
    ddtw.df <- rbind(ddtw.df,intermediate_feature)
  }
  ddtw.df
}

save(ddtw.df, file = "/home/sumi/Documents/Research_Project/Participant_Data/R_DataFiles/ddtwfeatures.RData")