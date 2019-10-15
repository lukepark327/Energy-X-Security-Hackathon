import numpy as np
import pandas as pd
import os
import datetime
import math

weather_df = pd.read_csv('../data/weather20102018.csv', encoding='EUC_KR')
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
