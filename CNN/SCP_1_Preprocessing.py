
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_1_Preprocessing.py

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
PATH1 = "/home/abhijaygupta/cnn/Training_Set/"
# Location of Testing Data 
PATH2 = "/home/abhijaygupta/cnn/Testing_Set/" 

#Function call to read csv
data1_df = FUN_ReadCSV(PATH1)
data2_df = FUN_ReadCSV(PATH2)

#Function to change time from HH:MM:SS to HHMMSS(integer)
data1_df = FUN_TimeToInteger(data1_df)
data2_df = FUN_TimeToInteger(data2_df)

#Function call to convert to 3 classes Locomotion Sedentary Neither   
data1_df = ConvertTo3Class(data1_df)
data2_df = ConvertTo3Class(data2_df)    

#length of each segment
window_size = 100

#converting time series data into batches of few seconds(in this case 10sec)
# in order to feed into the neural network
segments_train, labels_train = FUN_Segment(data1_df,window_size)
segments_test, labels_test = FUN_Segment(data2_df,window_size)

#One hot encoding of activity types
labels_train = np.asarray(pd.get_dummies(labels_train), dtype = np.int8)
labels_test = np.asarray(pd.get_dummies(labels_test), dtype = np.int8)

#reshaping the input to a 4D tensor comprising of ->
#1 number of time series data to be trained (datapoints/window_size)
#2 width of tensor (1 because the matrice has 100 rows and 1 column)
#3 height of tensor (number of data points)
#4 depth 3 (x,y and z axis)
reshaped_segments_train = segments_train.reshape(len(segments_train), 1,100, 3)
reshaped_segments_test = segments_test.reshape(len(segments_test), 1,100, 3)

train_x = reshaped_segments_train
test_x = reshaped_segments_test
train_y = labels_train
test_y = labels_test

#Saving the data frame
np.save("/home/abhijaygupta/cnn/train_x.npy",train_x)
np.save("/home/abhijaygupta/cnn/train_y.npy",train_y)
np.save("/home/abhijaygupta/cnn/test_x.npy",test_x)
np.save("/home/abhijaygupta/cnn/test_y.npy",test_y)
