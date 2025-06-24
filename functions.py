### Functions for Pedal Poll analysis
import pandas as pd
import numpy as np

def identify_count_session(df):
    """
    Create labels for the unique count session times for filtering and matching between years
    """
    
    # this captures if someone starts their 7 am count at 6:59, for instance
    # include start hours during the count window to capture if someone stopped and restarted their count
    weekday_morning = [6,7,8]
    weekday_lunch = [10,11,12]
    weekday_afternoon1 = [13,14] # need to disambiguate starting at 15:00 from weekday afternoon and weekday late afternoon
    weekday_afternoon2 = [15]
    weekday_late_afternoon1 = [16,17]
    weekday_late_afternoon2 = [15]
    valid_weekend_start_hours = [11,12,13]
    
    # redo to capture hand count data, also the 2021 data has the start_datetime_hourofday matching the individual count and not the session
    df['start_datetime_hour'] = pd.to_datetime(df['start_datetime'], format='mixed').dt.hour 
    df['start_datetime_minute'] = pd.to_datetime(df['start_datetime'], format='mixed').dt.minute
    df['elapsed_time_seconds'] = (pd.to_datetime(df['end_datetime'], format='mixed') - pd.to_datetime(df['start_datetime'], format='mixed')).dt.seconds
    
    # list of conditions to identify 
    conditions = [((df['is_weekend'] == True) & df['start_datetime_hour'].isin(valid_weekend_start_hours)), #weekend_afternoon
              ((df['is_weekend'] == False) & df['start_datetime_hour'].isin(weekday_morning)), # weekday_morning
              ((df['is_weekend'] == False) & df['start_datetime_hour'].isin(weekday_lunch)), # weekday_lunch
              # weekday afternoon
              ((df['is_weekend'] == False) & (df['start_datetime_hour'].isin(weekday_afternoon1) # has 1 or 2 pm start hour on a weekday
                                             | (df['start_datetime_hour'].isin(weekday_afternoon2) # or has 3 pm start hour
                                                & (df['elapsed_time_seconds']/60 < 120 - df['start_datetime_minute'])))), # and ends before 5 pm (split halfway)
              # weekday late afternoon
              ((df['is_weekend'] == False) & (df['start_datetime_hour'].isin(weekday_late_afternoon1) # has 4 or 5 pm start hour on a weekday
                                             | (df['start_datetime_hour'].isin(weekday_late_afternoon2) # or has 3 pm start hour
                                                & (df['elapsed_time_seconds']/60 >= 120 - df['start_datetime_minute']))))] # and ends after 5 pm (split halfway)                               

              
    values = ['weekend_afternoon', 'weekday_morning', 'weekday_lunch', 'weekday_afternoon', 'weekday_late_afternoon'] 
    
    df['count_session_label'] = np.select(conditions, values, default = 'not_assigned')
    
    return df
