
#Script Details ----------------------------------------------------------------------------------------------------

#Script Name : SCP_10_CNN_OnlySedentary.py

#Script Summary : 
#   This script is used to classify only sedentary activities

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
epochs = 100



#The Model
model = Sequential()

#1st convolution layer with 20 filters ,each with dimension (1,10)
model.add(Conv2D(20,(1,10),activation='relu',input_shape=(1,100,3)))
model.add(MaxPooling2D(pool_size=(1,3)))
#Dropout regularization layer to prevent overfitting


#2nd convolution layer with 40 filters ,each with dimension (1,5)
model.add(Conv2D(40,(1,5),padding='same',activation = 'relu'))
model.add(MaxPooling2D(pool_size = (1,3)))
#Dropout regularization layer to prevent overfitting


#Flatten layer
model.add(Flatten())
#Dropout regularization layer to prevent overfitting
#model.add(Dropout(0.5))
model.add(Dense(2000, activation='relu'))
model.add(Dense(1500, activation='relu'))

#model.add(Dense(300, activation='relu'))
#Dropout regularization layer to prevent overfitting
#model.add(Dropout(0.5))
#model.add(Dense(100 ,activation = 'relu'))

#Final output layer
model.add(Dense(1, activation='sigmoid'))

#Compiling the model and setting up the loss function (Gradient descent optimizing algorithm)
model.compile(loss=keras.losses.binary_crossentropy,
              optimizer="adam",
              metrics=['accuracy'])

class_weight = { 0 : 10.5 , 1 : 1. }

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
model.save("cnn_model_sed.h5")

#The saved model can be loaded and used for testing other data 
#from keras.models import load_model
#model = load_model("cnn_model.h5")
#model.evaluate(TestX,TestY,verbose=0)


#Printing the confusion matrix
from sklearn.metrics import classification_report,confusion_matrix
y_pred = model.predict_classes(TestX)
y_pred = y_pred.flatten()
y_pred = y_pred.astype(np.int8)
#p=model.predict_proba(Segments_Sed_Test) # to predict probability
target_names = ['Sedentary', 'Non-Sedentary']
print(classification_report(TestY, y_pred,target_names=target_names))
#print(confusion_matrix(np.argmax(Labels_Sed_Test,axis=1), y_pred))


print(confusion_matrix(TestY, y_pred))