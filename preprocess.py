import numpy as np
import pandas as pd
#import seaborn as sns
import os
import datetime
import math

#from sklearn.metrics import mean_squared_error
#from sklearn.preprocessing import MinMaxScaler
#from sklearn.preprocessing import StandardScaler

weather_df = pd.read_csv('data/weather20102018.csv', encoding='EUC_KR')
weather_df.head()

power_df = pd.read_csv('data/power20102019.csv', encoding='EUC_KR')
power_df.head()