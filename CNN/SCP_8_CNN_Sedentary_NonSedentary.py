
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_8_CNN_Sedentary_NonSedentary.py

#Script Summary : 
#   This script used for classifying the data processed after the file SCP_1_Sedentary_NonSedentary.py is executed
#   This script is used to load the preprocessed numpy ndarrays and to run the CNN model 

#Author & Reviewer Details ------------------------------------------------------------------------------------------

#Author : Abhijay Gupta
#Date : 07/11/2017
#E-Mail : abhijayvgupta@gmail.com
#Reviewed By : 
#Review Date : 
#Reviewer E-Mail : 

#Importing required libraries
import numpy as np
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
config.gpu_options.per_process_gpu_memory_fraction = 0.8
set_session(tf.Session(config=config))

#loading the numpy matrix
TrainX = np.load("/home/abhijaygupta/cnn2/train_x.npy")
TrainY = np.load("/home/abhijaygupta/cnn2/train_y.npy")
TestX = np.load("/home/abhijaygupta/cnn2/test_x.npy")
TestY = np.load("/home/abhijaygupta/cnn2/test_y.npy")


#number of segments to be trained
batch_size = TrainX.shape[0]

#epochs
epochs = 500



#The Model
model = Sequential()

#1st convolution layer with 20 filters ,each with dimension (1,10)
model.add(Conv2D(20,(1,10),activation='relu',input_shape=(1,100,3)))
model.add(MaxPooling2D(pool_size=(1,3)))

#2nd convolution layer with 40 filters ,each with dimension (1,5)
model.add(Conv2D(40,(1,5),padding='same',activation = 'relu'))
model.add(MaxPooling2D(pool_size = (1,3)))

#Flatten layer
model.add(Flatten())

model.add(Dense(2000, activation='relu'))
model.add(Dense(1000, activation='relu'))

#model.add(Dense(600, activation='relu'))
#Dropout regularization layer to prevent overfitting
#model.add(Dropout(0.5))
#model.add(Dense(300 ,activation = 'relu'))

#Final output layer
model.add(Dense(1, activation='sigmoid'))

#Compiling the model and setting up the loss function (Gradient descent optimizing algorithm)
model.compile(loss=keras.losses.binary_crossentropy,
              optimizer="adam",
              metrics=['accuracy'])

#class weights can be used for imbalanced data sets
#class_weight = { 0 : 10.5 , 1 : 1. }

#Traing the model and then testing it with the test set
model.fit(TrainX, TrainY,
          batch_size=batch_size,
          epochs=epochs,
          verbose=1,
          class_weight = class_weight,
          validation_data=(TestX, TestY))

#Loss and accuracy on the test set
SCORE = model.evaluate(TestX, TestY, verbose=0)
print('Test loss:', SCORE[0])
print('Test accuracy:', SCORE[1])

#Saving the trained model as a h5 file
model.save("cnn_model.h5")

#The saved model can be loaded and used for testing other data 
#from keras.models import load_model
#model = load_model("cnn_model.h5")
#model.evaluate(TestX,TestY,verbose=0)

