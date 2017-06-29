#Activity recognition using CNN (using python and keras)

import glob,os
import pandas as pd
import numpy as np
from scipy import stats
#The csv file contains the following data -> "timeOnly","X","Y","Z","TaskLabel"
#location of the csv
path1 = "/home/abhijay/activity/files/even_small_train/"
 
path2 = "/home/abhijay/activity/files/diff/" 
#change the directory and read all csv files into a single dataframe
def readCSV(path):
    #changing the working directory and reading all the csv files from the csv
    os.chdir(path)
    filelist = [i for i in glob.glob('*.{}'.format('csv'))]

    #merging all csv files into a single panda dataframe
    df_list = [pd.read_csv(file) for file in filelist]
    df = pd.concat(df_list)
    return df

#Function call to read csv
df = readCSV(path1)

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
    
#Function call to convert to 3 classes Locomotion Sedentary Neither   
convertTo3Class(df)    

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


#Converting HH:MM:SS to HHMMSS
df['timeOnly'] = df['timeOnly'].str.replace(':','')
df['timeOnly'] = pd.to_numeric(df['timeOnly'])


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
        if(len(df['timeOnly'][start:end]) == window_size):
            segments = np.vstack([segments,np.dstack([x,y,z])])
            labels = np.append(labels,stats.mode(data["TaskLabel"][start:end])[0][0])
    return segments, labels

#length of each segment
window_size = 60

#converting time series data into batches of few seconds(in this case 9sec)
# in order to feed into the neural network
segments, labels = segment_signal(df,window_size)

#One hot encoding of activity types
labels = np.asarray(pd.get_dummies(labels), dtype = np.int8)

#reshaping the input to a 4D tensor comprising of ->
#1 number of time series data to be trained (datapoints/window_size)
#2 width of tensor (1 because the matrice has 90 rows and 1 column)
#3 height of tensor (number of data points)
#4 depth 3 (x,y and z axis)
reshaped_segments = segments.reshape(len(segments), 1,60, 3)

#saving the data frame
np.save("/home/abhijay/activity/files/reshape.npy",reshaped_segments)

#loading the numpy matrix
reshaped_segments = np.load("/home/abhijay/activity/files/reshape.npy")


#splitting data into train and test
train_test_split = np.random.rand(len(reshaped_segments)) < 0.70
train_x = reshaped_segments[train_test_split]
train_y = labels[train_test_split]
test_x = reshaped_segments[~train_test_split]
test_y = labels[~train_test_split]

#using the keras library with tensorflow backend
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import optimizers 

#limit gpu usage
import tensorflow as tf
from keras.backend.tensorflow_backend import set_session
config = tf.ConfigProto()
config.gpu_options.per_process_gpu_memory_fraction = 0.6
set_session(tf.Session(config=config))

#number of matrics to be trained
batch_size = train_x.shape[0]

#types of activities
num_classes = 3

#epochs
epochs = 50

#The Model
model = Sequential()
model.add(Conv2D(12,(1,3),activation='relu',input_shape=(1,60,3)))
model.add(MaxPooling2D(pool_size=(1,1)))
model.add(Dropout(0.25))

model.add(Flatten())

model.add(Dense(600, activation='relu'))
model.add(Dense(300, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(300, activation='relu'))
model.add(Dense(300, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(300, activation='relu'))
model.add(Dense(300, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(300, activation='relu'))
model.add(Dense(300, activation='relu'))

model.add(Dense(num_classes, activation='softmax'))

adam = optimizers.Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.0)

model.compile(loss=keras.losses.categorical_crossentropy,
              optimizer=adam,
              metrics=['accuracy'])


model.fit(train_x, train_y,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          validation_data=(test_x, test_y))
score = model.evaluate(test_x, test_y, verbose=0)
print('Test loss:', score[0])
print('Test accuracy:', score[1])

model.save("/home/abhijay/activity/files/cnn_model.h5")



