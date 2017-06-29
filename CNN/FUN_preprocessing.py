#Activity recognition using CNN (using python and keras)

import glob,os
import pandas as pd
import numpy as np
from scipy import stats
 

#change the directory and read all csv files into a single dataframe
def readCSV(path):
    #changing the working directory and reading all the csv files from the csv
    os.chdir(path)
    filelist = [i for i in glob.glob('*.{}'.format('csv'))]

    #merging all csv files into a single panda dataframe
    df_list = [pd.read_csv(file) for file in filelist]
    df = pd.concat(df_list)
    return df


#Fucntion to convert the task label into 3 categories
#Locomotion Sedentary Neither
def convertTo3Class(df):
    sed = ['COMPUTER WORK','TV WATCHING','STANDING STILL']
    loc = ['LEISURE WALK','RAPID WALK','WALKING AT RPE 1','WALKING AT RPE 5','STAIR DESCENT','STAIR ASCENT']
    for i in sed:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Sedentary'
    for i in loc:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Locomotion'
    neither = df.TaskLabel.unique().tolist()
    neither.remove('Sedentary')
    neither.remove('Locomotion')
    for i in neither:
        df.loc[df['TaskLabel'] == i, 'TaskLabel'] = 'Neither'
    
   

###   IGNORE THIS ###
# #Types of activities in the data set
# activities = df.TaskLabel.unique()
# for i in activites:
#     tv = df.loc[df['TaskLabel']== i]
#     name = '/home/abhijay/activity/files/diff/'+str(i)+'.csv'
#     tv.to_csv(name,sep=',')
# i = None

# os.chdir(path2)
# filelist = [i for i in glob.glob('*.{}'.format('csv'))]

# df_list = [pd.read_csv(file) for file in filelist]
# df = pd.concat(df_list)
# df = df.drop('Unnamed: 0', 1)
### IGNORE TILL HERE ###



#Selecting starting and ending data points from time series data
def windows(data, size):
    start = 0
    while start < data.count():
        yield start, start + size
        start += (size / 2)
#Making segments in the data (select the dataframe and the length of segments)
def segment_signal(data,window_size):
    segments = np.empty((0,window_size,3))
    labels = np.empty((0))
    for (start, end) in windows(data['timeOnly'], window_size):
        x = data["X"][start:end]
        y = data["Y"][start:end]
        z = data["Z"][start:end]
        if(len(data['timeOnly'][start:end]) == window_size):
            segments = np.vstack([segments,np.dstack([x,y,z])])
            labels = np.append(labels,stats.mode(data["TaskLabel"][start:end])[0][0])
    return segments, labels



