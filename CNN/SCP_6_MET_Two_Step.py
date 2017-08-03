
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_6_MET_Two_Step.py

#Script Summary : 
#       This script generates 10 second segments of all the time series data and stores it as a numpy ndarray.
#       The training and testing data are stored seperately 
#Author & Reviewer Details ------------------------------------------------------------------------------------------

#Author : Abhijay Gupta
#Date : 07/11/2017
#E-Mail : abhijayvgupta@gmail.com
#Reviewed By : 
#Review Date : 
#Reviewer E-Mail : 

#importing necessary libraries
import numpy as np 
import pandas as pd 
from FUN_Preprocessing import *
# Location of Training Data
PATH1 = "/home/abhijay/activity/files/Training_Set/"
# Location of Testing Data 
PATH2 = "/home/abhijay/activity/files/Testing_Set/" 

#Function call to read csv
Data1_df = FUN_ReadCSV(PATH1)
Data2_df = FUN_ReadCSV(PATH2)

#Function to add sedentary and locmotion columns
Data1_df = FUN_Sed_Loc_Columns(Data1_df)
Data2_df = FUN_Sed_Loc_Columns(Data2_df)

#loading met values
met = pd.read_csv('/home/abhijay/activity/files/met_values.csv')
#Drop duplicate met values
met = met.drop_duplicates(subset=['PID', 'Task'])
met.columns = ['PID','TaskLabel','METs','MET_Intensity']

#merging met and data
met_train = pd.merge(Data1_df,met,how='left',on=['PID','TaskLabel'])
Data1_df = met_train[pd.notnull(met_train['METs'])]
met_test = pd.merge(Data2_df,met,how='left',on=['PID','TaskLabel'])
Data2_df = met_test[pd.notnull(met_test['METs'])]


#Function to change time from HH:MM:SS to HHMMSS(integer)
Data1_df = FUN_TimeToInteger(Data1_df)
#Data1_2df = Data1_df
Data2_df = FUN_TimeToInteger(Data2_df)
#Data2_2df = Data2_df

#length of each segment
WindowSize = 100

#Function to segment into 33 classes and saving them
Segments_Train, mets_train , _ = FUN_Segment_TwoStep(Data1_df,WindowSize)
Segments_Test, mets_test , _ = FUN_Segment_TwoStep(Data2_df,WindowSize)




#reshaping the input to a 4D tensor comprising of ->
#1 number of time series data to be trained (datapoints/window_size)
#2 width of tensor (1 because the matrice has 100 rows and 1 column)
#3 height of tensor (number of data points)
#4 depth 3 (x,y and z axis)
Segments_Train = Segments_Train.reshape(len(Segments_Train), 1,100, 3)
Segments_Test = Segments_Test.reshape(len(Segments_Test), 1,100, 3)



#Saving the data frame
np.save("/home/abhijay/activity/files/train_x.npy",Segments_Train)
np.save("/home/abhijay/activity/files/train_y.npy",mets_train)
np.save("/home/abhijay/activity/files/test_x.npy",Segments_Test)
np.save("/home/abhijay/activity/files/test_y.npy",mets_test)
