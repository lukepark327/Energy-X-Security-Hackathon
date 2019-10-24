from keras.models import Sequential
from keras.layers import Activation, Dense, Dropout
from sklearn.model_selection import train_test_split
from matplotlib import pyplot
import pandas as pd

class FLModel:
    def __init__(self, compiled_model):
        self.__model = compiled_model
        self.__weight = self.get_weights()
        self.loss = None
        self.metrics = None

    def summary(self):
        self.__model.summary()

    def fit(self, x_train, y_train, epochs=5, validation_data = None,callbacks=[], verbose=0):
        return self.__model.fit(x_train, y_train, epochs=epochs, validation_data = validation_data, callbacks=callbacks, verbose=verbose)

    def evaluate(self, x_test, y_test, verbose=0):
        res = self.__model.evaluate(x_test, y_test, verbose=verbose)
        self.loss = res[0]
        self.metrics = res[1:]

    def raw_evaluate(self, x_test, y_test, verbose=0):
        res = self.__model.evaluate(x_test, y_test, verbose=verbose)
        return res  # loss, metrics

    def get_weights(self):
        self.__weight = self.__model.get_weights()
        return self.__weight

    def set_weights(self, new_weights):
        self.__model.set_weights(new_weights)
    
    def predict(self, x_input):
        return self.__model.predict(x_input)
    
    def plot(self, x_train, y_train, x_test, y_test):
        history = flmodel.fit(x_train, y_train,  epochs=30, validation_data = (x_test, y_test), verbose=1)
    
        pyplot.title('Loss / Mean Squared Error')
        pyplot.plot(history.history['loss'], label='train')
        pyplot.plot(history.history['val_loss'], label='test')
        pyplot.legend()
        pyplot.show()

if __name__ == "__main__":
    df = pd.read_pickle('../data/df.pkl')
    X = df.drop('power(MW)', axis=1).values
    y = df['power(MW)'].values
    x_train, x_test,y_train, y_test =  train_test_split(X, y, train_size = 0.8)

    model = Sequential()
    model.add(Dense(input_dim=x_train.shape[1], units=512))
    model.add(Activation("relu"))
    model.add(Dropout(0.2))
    model.add(Dense(units=256))
    model.add(Activation("relu"))
    model.add(Dropout(0.2))
    model.add(Dense(units=128))
    model.add(Activation("relu"))
    model.add(Dropout(0.2))
    model.add(Dense(units=1))
    model.compile("nadam", "mse", ["mse"])
    
    flmodel = FLModel(model)
    
    flmodel.summary()
    # weights = flmodel.get_weights()
    # print(weights)
    
    flmodel.plot(x_train,y_train, x_test, y_test)
    