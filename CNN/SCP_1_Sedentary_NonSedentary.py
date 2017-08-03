
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_1_Sedentary_NonSedentary.py

#Script Summary : 
#       This script first divides data into sedentary and non-sedentary and then generates 10 second segments of all the time series data and stores it as a numpy ndarray.
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
PATH1 = "/home/abhijaygupta/cnn/Training_Set"
# Location of Testing Data 
PATH2 = "/home/abhijaygupta/cnn/Testing_Set" 

#Function call to read csv
Data1_df = FUN_ReadCSV(PATH1)
Data2_df = FUN_ReadCSV(PATH2)

#Function to change time from HH:MM:SS to HHMMSS(integer)
Data1_df = FUN_TimeToInteger(Data1_df)
Data2_df = FUN_TimeToInteger(Data2_df)

#Function call to convert to 2 classes  Sedentary Neither   
Data1_df =  FUN_ConvertToSedentary(Data1_df)
Data2_df =  FUN_ConvertToSedentary(Data2_df)    

#length of each segment
WindowSize = 100

#converting time series data into batches of few seconds(in this case 10sec)
# in order to feed into the neural network
SegmentsTrain, _ ,LabelsTrain = FUN_Segment(Data1_df,WindowSize)
SegmentsTest, _ ,LabelsTest = FUN_Segment(Data2_df,WindowSize)


#One hot encoding of activity types
LabelsTrain = np.asarray(LabelsTrain, dtype = np.int8)
LabelsTest = np.asarray(LabelsTest, dtype = np.int8)

#reshaping the input to a 4D tensor comprising of ->
#1 number of time series data to be trained (datapoints/window_size)
#2 width of tensor (1 because the matrice has 100 rows and 1 column)
#3 height of tensor (number of data points)
#4 depth 3 (x,y and z axis)
ReshapedSegmentsTrain = SegmentsTrain.reshape(len(SegmentsTrain), 1,100, 3)
ReshapedSegmentsTest = SegmentsTest.reshape(len(SegmentsTest), 1,100, 3)

#Saving the data frame
np.save("/home/abhijaygupta/cnn/train_x.npy",ReshapedSegmentsTrain)
np.save("/home/abhijaygupta/cnn/train_y.npy",LabelsTrain)
np.save("/home/abhijaygupta/cnn/test_x.npy",ReshapedSegmentsTest)
np.save("/home/abhijaygupta/cnn/test_y.npy",LabelsTest)
