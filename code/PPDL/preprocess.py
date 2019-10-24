import numpy as np
import pandas as pd
import numpy as np
import datetime
import math
from sklearn.preprocessing import MinMaxScaler
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

def get_train_test(PATH="../data/df.pkl", getScaler=False):
    try:    
        # Load data
        df = pd.read_pickle(PATH)
        X = df.drop('power(MW)', axis=1).values
        y = df['power(MW)'].values
        x_train, x_test,y_train, y_test =  train_test_split(X, y, train_size = 0.8)
        features = list(df.columns)
        features.remove('power(MW)')
        return features, x_train, x_test,y_train, y_test
    except:
        # Read data, selected columns only
        weather_df = pd.read_csv('../data/weather20102018.csv', encoding='EUC_KR', usecols=['일시', '기온(°C)', '강수량(mm)', '풍속(m/s)', '풍향(16방위)', '습도(%)', '적설(cm)'])
        weather_df = weather_df.fillna(0)
        power_df = pd.read_csv('../data/power20102019.csv', encoding='EUC_KR')

        # String date to Datetime
        weather_df = weather_df.rename(columns={'일시': 'Date'})
        weather_df['Date'] = pd.to_datetime(weather_df['Date'], dayfirst=True)

        # Hour column to row
        power_df = power_df.drop(columns=['MAX', 'MIN', 'AVG'])
        power_df = pd.melt(power_df, id_vars=['Date'], value_vars=list(power_df.columns[1:]), value_name='power(MW)')
        power_df['Date'] = power_df['Date'].map(str) + "-0" + power_df['variable'].replace('24h', '0h')
        power_df['Date'] = pd.to_datetime(power_df['Date'])
        power_df = power_df.drop(columns=['variable'])

        # Split year, month, day, and day-of-the-week from Datetime
        df = weather_df.merge(power_df, on='Date')
        df['연'] = df['Date'].dt.year
        df['월'] = df['Date'].dt.month
        df['일'] = df['Date'].dt.day
        df['요일'] = df['Date'].dt.dayofweek
        df['시간'] = df['Date'].dt.hour

        # One-hot encode day-of-the-week
        df['요일'] = df['요일'].apply(lambda x: day_list(x))
        for i in range(1,8):
            df['요일'+str(i)] = 0
        for i,row in df.iterrows():
            one_hot_index = np.where(df['요일'][i]==1)
            one_hot_index = one_hot_index[0][0]
            df.at[i,'요일'+str(one_hot_index+1)] = 1
        df = df.drop(['요일', 'Date'],axis=1)
        df = df.round().astype(int)

        # Save data
        df.to_pickle(PATH)
        X = df.drop('power(MW)', axis=1).values
        y = df['power(MW)'].values
        x_train, x_test,y_train, y_test =  train_test_split(X, y, train_size = 0.8)
        features = df.columns
        features.remove('power(MW)')
        return features, x_train, x_test,y_train, y_test
        
# Utility function for one-hot encoding day-of-the-week
def day_list(x):
    day_list = np.zeros(7)
    day_list[x] = 1
    return day_list


