#!/usr/bin/env python

###########################################################
###########################################################
###### Originally written by Habiballah Rahimi Eichi ######
###########################################################
###########################################################

import os
import sys
import argparse as ap
import logging
import re
from dateutil import tz
from datetime import datetime, date, timedelta
import pandas as pd
import gzip
from operator import itemgetter
from math import floor
from glob import glob
import pytz
import time
import subprocess as sp

logger = logging.getLogger(os.path.basename(__file__))
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Define the structure of the Actigraphy data name which includes the serial numner of the watch, 
# date the data is extracted and converted to csv file after connected to the station 
GENEACTIV_FILE_REGEX  = re.compile(r'(?P<subject>\w+)_(?P<hand>\w+)\s(?P<position>\w+)_(?P<serialnum>\w+)_(?P<year>[0-9]{4})-(?P<month>[0-9]{2})-(?P<day>[0-9]{2})\s(?P<hour>[0-9]{2})-(?P<minute>[0-9]{2})-(?P<second>[0-9]{2})(?P<extension>\..*)')
GENEACTIV_FILE_REGEX2 = re.compile(r'(?P<subject>\w+)__(?P<serialnum>\w+)_(?P<year>[0-9]{4})-(?P<month>[0-9]{2})-(?P<day>[0-9]{2})\s(?P<hour>[0-9]{2})-(?P<minute>[0-9]{2})-(?P<second>[0-9]{2})(?P<extension>\..*)')
GENEACTIV_FILE_REGEX3 = re.compile(r'(?P<subject>\w+)_(?P<serialnum>\w+)_(?P<year>[0-9]{4})-(?P<month>[0-9]{2})-(?P<day>[0-9]{2})\s(?P<hour>[0-9]{2})-(?P<minute>[0-9]{2})-(?P<second>[0-9]{2})(?P<extension>\..*)')
GENEACTIV_FILE_REGEX5 = re.compile(r'(?P<subject>\w+)__(?P<serialnum>\w+)_(?P<year>[0-9]{4})-(?P<month>[0-9]{2})-(?P<day>[0-9]{2})(?P<extension>\..*)')
GENEACTIV_FILE_REGEX4 = re.compile(r'(?P<subject>\w+)_(?P<month>\w+)_(?P<day>\w+)_(?P<year>\w+)(?P<extension>\..*)')
MTL1_FILE_REGEX = re.compile(r'(?P<pref>\w+)_(?P<year>[0-9]{4})-(?P<month>[0-9]{2})-(?P<day>[0-9]{2})(?P<extension>\..*)')


DATA_BEGINS = 101
DATA_COLUMNS = ['timestamp', 'x', 'y', 'z', 'lux', 'button', 'temp', 'frequency']

def parse_args():
    argparser = ap.ArgumentParser('extract Pipeline for GENEActiv')

    # Input and output parameters
    argparser.add_argument('--read-dir',
        help='Path to the input directory', required=True)
    argparser.add_argument('--output-dir',
        help='Path to the output directory', required=True)
    argparser.add_argument('--output-tz',
        help='Timezone info for the output. (Default: America/New_York)',
        default = 'America/New_York')
    argparser.add_argument('--ext-mode',
        help='Data extraction mode (all, new, specific). (Default: new)',
        default = 'new')
    argparser.add_argument('--ext-date',
        help='Data extraction date when ext-mode is apec. (Default: 2010-00-00)',
        default = '2010-00-00')
    argparser.add_argument('--mtl-dir')
    return argparser

def main(args):
    # expand any ~/ in the directories
    read_dir = os.path.expanduser(args.read_dir)
    output_dir = os.path.expanduser(args.output_dir)

    # perform sanity checks for inputs
    read_dir = check_input(read_dir)
    output_dir = check_output(output_dir)
    if read_dir is None or output_dir is None:
        return

    # logger output
    fh = logging.FileHandler(os.path.join(output_dir, 'extract.log'))
    logger.addHandler(fh)

    # process data and save as csv
    process(read_dir, output_dir, args.output_tz,args.ext_mode,args.ext_date)

    # run MATLAB
    run_matlab(output_dir, args.mtl_dir)

    # remove processed csv files
    # clean_output_csv(output_dir)

# Run MATLAB
def run_matlab(output_dir, mtl_dir):
    try:
        matlab_path = "addpath('{matlab_dir}');".format(matlab_dir=mtl_dir)
        sub_cmd = "extract('{OUTPUT_DIR}')".format(OUTPUT_DIR=output_dir)
        
        sub_cmd = wrap_matlab(sub_cmd)

        if mtl_dir:
            sub_cmd = matlab_path + sub_cmd

        cmd = ['matlab', '-nojvm', '-nodisplay', '-nosplash', '-r', sub_cmd]
        sp.check_call(cmd, stderr=sp.STDOUT)

    except Exception as e:
        logger.error(e)

def wrap_matlab(cmd):
    return 'try; {0}; catch; err = lasterror; disp(err.message); quit(1); end; quit();'.format(cmd)

# Loop through subdirectories and get the filenames and sort
def process(read_dir, output_dir, output_tz, ext_mode, ext_date):
    if ext_mode=='new':
        files2=[]
        for root_dir1, dirs1, files1 in os.walk(output_dir):
            for file in sorted(files1):
                if file.endswith('.csv'):
                    files2 = file
            if files2==[]:
                ext_mode='all'
            else:
                match = MTL1_FILE_REGEX.match(files2)
                file_date1 = get_date(match)

    
    #Instantiate an empty dataframe
    df = []  # new
    df1= []  # all
    df2= []  # specific  
    #Go the actigraphy directory to append the related file names depending on the extraction mode.
    for root_dir, dirs, files in os.walk(read_dir):
        files[:] = [f for f in files if not f[0] == '.']
        dirs[:] = [d for d in dirs if not d[0] == '.']

        for file_name in sorted(files):
            verified = verify(file_name)
            if verified:
                file_date = get_date(verified)
                file_path = os.path.join(root_dir, file_name)
                df1.append({'date' : file_date, 'path': file_path})
                if ext_mode=='new':
                    if datetime.strptime(file_date, '%Y-%m-%d')>datetime.strptime(file_date1, '%Y-%m-%d')+ timedelta(days=2):
                        df.append({'date' : file_date, 'path': file_path})
                if ext_mode=='specific':
                    if datetime.strptime(file_date, '%Y-%m-%d')>datetime.strptime(ext_date, '%Y-%m-%d')- timedelta(days=2):
                        df2.append({'date' : file_date, 'path': file_path})

    # Based on the extraction mode sort the related files that needs to be extracted 
    if ext_mode=='new':
        if len(df) == 0:
            logger.error('Could not find more GENEActiv files. Exiting.')
            return
        df = sort_df(df)
    if ext_mode=='specific':
        if len(df2) == 0:
            logger.error('Could not find the specific GENEActiv file. Exiting.')
            return
        df = sort_df(df2)
    if ext_mode=='all':
        if len(df1) == 0:
            logger.error('Could not find any GENEActiv files. Exiting.')
            return
        df = sort_df(df1)

    return parse(df, output_dir, output_tz)

# Parse geneactiv
def parse(df, output_dir, output_tz):
    for file_name in df:
        path = file_name['path']
        logger.info('Reading %s' % path)
        lines = DATA_BEGINS

        frequency, date_from  = get_fs(path)
        if frequency is None: continue
       
        input_tz, sgn, hour_diff = get_tz(path)
        while True:
            num_lines = get_lines(date_from, frequency)
            date_from_str = get_date_str(date_from)

            if lines != DATA_BEGINS:
                skip_lines = int(lines + add_lines(-1, frequency))
                df = read_csv(path, num_lines + add_lines(5, frequency), skip_lines)
            else:
                df = read_csv(path, num_lines + add_lines(5, frequency), lines)

            if len(df) == 0:
                break

            convert_timestamp = check_timestamp(df, output_tz, input_tz, sgn, hour_diff)
            if convert_timestamp is True:
                if lines != DATA_BEGINS:
                    skip_lines = int(lines + add_lines(-91, frequency))
                    df = read_csv(path, num_lines + add_lines(155, frequency), skip_lines)
                else:
                    df = read_csv(path, num_lines + add_lines(155, frequency), lines)
                df['timestamp'] = df.apply(lambda row: get_true_time(row['timestamp'],
                input_tz, sgn, hour_diff, output_tz), axis=1)
                df = df.drop_duplicates(subset=['timestamp'], keep='last')

            # Ensures that all data points belong to the same day
            df = df[df.timestamp.str.startswith(date_from_str)]
            df['frequency'] = frequency

            # Group by hour, fill in NaNs, and export csv
            export_csv(df, date_from_str, output_dir,frequency)

            # Increment for the next loop
            lines = int(lines + num_lines)
            date_from = get_new_date(date_from)

def check_timestamp(df, output_tz, input_tz, sgn, hour_diff):
    mid_point = df.iloc[int(len(df) / 2)]['timestamp']
    mid_point_true_time = get_true_time(mid_point, input_tz, sgn, hour_diff, output_tz)
    return mid_point != mid_point_true_time

# Convert timestamp to reflect the timezone information
def get_true_time(timestamp, input_tz, sgn, hour_diff, output_tz):
    input_tz = pytz.timezone(input_tz)
    ts = datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S:%f').replace(tzinfo=input_tz)
    if sgn == '-':
        ts = ts + timedelta(hours=hour_diff)
    elif sgn == '+':
        ts = ts - timedelta(hours=hour_diff)
    else:
        logger.error('Error encountered while parsing timezone information')
        return timestamp

    ts = ts.astimezone(pytz.timezone(output_tz))
    return ts.strftime('%Y-%m-%d %H:%M:%S:%f')[:-3]

def process_nan(df):
    frequencies = df.frequency.unique()
    df_columns = list(df.columns.values)
    if (len(frequencies) == 1) and ('' not in frequencies):
        df['.hour'] = df.apply(lambda row: int(row['timestamp'][11:13]), axis=1)
        df = df.groupby('.hour').apply(lambda dfg: add_row(dfg, 
            frequencies[0], 
            df_columns)).reset_index(drop=True)
        return check_day(df, frequencies[0], df_columns)
    else:
        return pd.DataFrame(columns=df_columns)

# Check the number of rows for each hour
def add_row(dfg, frequency, df_columns):
    df_hour_length = len(dfg)
    lines_per_hour = frequency * 60 * 60
    if lines_per_hour != df_hour_length:
        hour = int(dfg['timestamp'].iloc[0][11:13])
        new_rows = get_nan(lines_per_hour, df_hour_length, df_columns, hour)
        return pd.concat([new_rows, dfg], ignore_index=True, sort=False)
    else:
        return dfg

# Check the number of rows for the day and fill in
def check_day(df, frequency, df_columns):
    df_day_length = len(df)
    lines_per_hour = int(frequency * 60 * 60)
    lines_per_day = int(lines_per_hour * 24)

    if lines_per_day != df_day_length:
        new_df = []
        present_hours = df['.hour'].unique()

        new_columns = df_columns.append('.hour')
        for hour in range(0,24):
            if hour not in present_hours:
                pd_series = {}
                for df_column in df_columns:
                    pd_series[df_column] = 'NaN'
                pd_series['.hour'] = hour
                for line in range(0,lines_per_hour):
                    new_df.append(pd_series)
        new_rows = pd.DataFrame(new_df, columns=new_columns)
        
        return pd.concat([new_rows, df], ignore_index=True)
    else:
        return df

# Insert rows of NaN to fill in missing rows
def get_nan(expected_line_num, current_line_num, df_columns, hour):
    new_df = []
    missing_rows = int(expected_line_num - current_line_num)

    new_columns = df_columns.append('.hour')
    for row in range(0, missing_rows):
        pd_series = {}
        for df_column in df_columns:
            pd_series[df_column] = 'NaN'
        pd_series['.hour'] = hour
        new_df.append(pd_series)
    return pd.DataFrame(new_df, columns=new_columns)

# Export csv
def export_csv(df, date_from_str, output_dir,frequency):
    file_name = 'mtl1_' + date_from_str + '.csv'
    file_path = os.path.join(output_dir, file_name)
    if os.path.exists(file_path):
        try:
            logger.info('Found old file %s. Concatenating.' % file_path)
            old_df = pd.read_csv(file_path, keep_default_na=False, engine='c',
                    skipinitialspace=True, memory_map=True, na_values='NaN').dropna()
            old_df, df = compare_date(old_df, df,frequency)

            # Find duplicate timestamps, and drop them from the old data
            merged = pd.merge_asof(old_df, df, on='.time', allow_exact_matches=False, 
                tolerance=pd.Timedelta('90ms'))['timestamp_y'].dropna()
            dup_index = set(merged.index.values)
            keep_index = set(range(old_df.shape[0])) - dup_index
            old_df = old_df.take(list(keep_index))

            df = pd.concat([old_df, df], ignore_index=True, names=DATA_COLUMNS)
            df = df.drop_duplicates(subset='timestamp')
        except Exception as e:
            logger.error(e)
            logger.warn('Could not read old file %s. Overwriting.' % file_path)
    try:
        df = sort_values(process_nan(df))
        logger.info('Writing %s, %s lines' % (file_path, len(df)))
        
        df.to_csv(path_or_buf=file_path,
            index=False, columns=DATA_COLUMNS, na_rep='')
    except Exception as e:
        logger.error(e)
        logger.warn('Could not export file %s' % file_path)

# Sort data based on hour and timestamp
def sort_values(df):
    if '.hour' in df and 'timestamp' in df:
        df = df.sort_values(by=['.hour', 'timestamp'])
    elif 'timestamp' in df:
        df = df.sort_values(by=['timestamp'])
    return df

# Compare the timestamp from each file, 
# and return dfs in chronological order
def compare_date(old_df, df, frequency):
    old_ts = old_df['timestamp'].iloc[0]    
    old_timestamp = datetime.strptime(old_ts, '%Y-%m-%d %H:%M:%S:%f')
  #  logger.info('Old ts %s' % old_timestamp)

    new_ts = df['timestamp'].iloc[0]    
    new_timestamp = datetime.strptime(new_ts, '%Y-%m-%d %H:%M:%S:%f')
  #  logger.info('New ts %s' % new_timestamp)


    old_df['.time'] = old_df.apply(lambda row: get_datetime(row['timestamp']), axis=1)
    df['.time'] =  df.apply(lambda row: get_datetime(row['timestamp']), axis=1)

    if new_ts >= old_ts:
        return old_df, df
    else:
        return df, old_df

def add_lines(minute, frequency):
    return minute * 60 * frequency

def get_new_date(date_to):
    return datetime(date_to.year, date_to.month, date_to.day) + timedelta(days=1)

def get_date_str(date_obj):
    return date_obj.strftime('%Y-%m-%d')

# Get the number of lines based on frequency
def get_lines(date_to, frequency):
    date_from = datetime(date_to.year, date_to.month, date_to.day) + timedelta(days=1)
    date_diff = date_from - date_to
    sec = date_diff.total_seconds()
    lines = round(sec * frequency) + 1 #Including the first line
    return lines

# Get the timezone information from the file
def get_tz(path):
    df = read_csv(path, 100, 0)
    if len(df) == 0:
        logger.error('There are no data in file %s.' % path)
        return None, None, None
    if df is not []:
        timezones = df.index[df['timestamp'] == 'Time Zone'].tolist()
        if len(timezones) == 0:
            logger.error('There are no timezone information in file %s.' % path)
            return None, None, None
        else:
            timezone, time_diff = df.iloc[timezones[0]]['x'].split(' ')
            sgn = time_diff[0]
            hour_diff = time_diff[1:]
            return timezone, sgn, int(hour_diff)
    else:
        logger.error('Could not get the frequency from %s' % path)
        return None, None, None

# Get the frequency and first date from the file
def get_fs(path):
    df = read_csv(path, 2, DATA_BEGINS)
    if len(df) == 0:
        logger.error('There are no data in file %s.' % path)
        return None, None

    if df is not []:
        df['$timestamp_dt'] = df.apply(lambda row: get_datetime(row['timestamp']), axis=1)
        df['$timestamp_fs'] = df['$timestamp_dt'].diff()
        df['$timestamp_fs'] = df.apply(lambda row: calculate_fs(row['$timestamp_fs']), axis=1)
        return round(df['$timestamp_fs'].iloc[1]), df['$timestamp_dt'].iloc[0]
    else:
        logger.error('Could not get the frequency from %s' % path)
        return None, None

# Calculate fs
def calculate_fs(timestamp_fs):
    sec = timestamp_fs.total_seconds()
    return 1 / sec

# Get datetime
def get_datetime(timestamp):
    return datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S:%f')

# Read CSV
def read_csv(path, lines, line_from):
    if path.endswith('csv'):
        try:
            df = pd.read_csv(path, keep_default_na=False, engine='c',
                skipinitialspace=True, memory_map=True, skiprows=line_from, 
                header=None, names=DATA_COLUMNS, nrows=lines)
            return df
        except Exception as e:
            logger.error(e)
            return [] 
    elif path.endswith('csv.gz'):
        try:
            with gzip.open(path, 'rb') as f:
                df = pd.read_csv(f, keep_default_na=False,
                skipinitialspace=True, skiprows=line_from, 
                header=None, names=DATA_COLUMNS, nrows=lines)
                return df
        except Exception as e:
            logger.error(e)
            return []
    else:
        logger.error('Unsupported filename.')
        return []

# Sort the files based on the GENEActiv date
def sort_df(df):
    return sorted(df, key=itemgetter('date'))

# GENEActiv date extracted from the filename
def get_date(match):
    d = match.groupdict()
    return d['year'] + '-' + d['month'] + '-' + d['day']

# Check if the file is a GENEActiv file
def verify(file_name):
    match = GENEACTIV_FILE_REGEX.match(file_name)
    if match:
        extension = match.group('extension')
        if extension == '.csv' or extension == '.csv.gz':
            return match
        else:
            logger.error('The format of the file %s is not supported.' % file_name)
            return False
    else:
        match = GENEACTIV_FILE_REGEX2.match(file_name)
        if match:
            extension = match.group('extension')
            if extension == '.csv' or extension == '.csv.gz':
                return match
            else:
                logger.error('The format of the file %s is not supported.' % file_name)
                return False
        else:
            match = GENEACTIV_FILE_REGEX3.match(file_name)
            if match:
                extension = match.group('extension')
                if extension == '.csv' or extension == '.csv.gz':
                    return match
                else:
                    logger.error('The format of the file %s is not supported.' % file_name)
                    return False
            else:
                match = GENEACTIV_FILE_REGEX4.match(file_name)
                if match:
                        extension = match.group('extension')
                        if extension == '.csv' or extension == '.csv.gz':
                            return match
                        else:
                            logger.error('The format of the file %s is not supported.' % file_name)
                            return False
                else:
                    match = GENEACTIV_FILE_REGEX5.match(file_name)
                    if match:
                            extension = match.group('extension')
                            if extension == '.csv' or extension == '.csv.gz':
                                return match
                            else:
                                logger.error('The format of the file %s is not supported.' % file_name)
                                return False
                    else:
                        logger.error('The format of the file %s is not supported.' % file_name)
                        return False
                    
                                

# Exit program if the input directory does not exist.
def check_input(read_dir):
    if os.path.exists(read_dir):
        return read_dir
    else:
        logger.error('%s does not exist.' % read_dir)
        return None

# Exit program if the output directory does not exist.
def check_output(output_dir):
    if os.path.exists(output_dir):
        output_dir = os.path.join(output_dir, 'mtl1')
        if os.path.exists(output_dir):
            #clean_output_dir(output_dir)
            return output_dir
        else:
            try:
                os.mkdir(output_dir)
                return output_dir
            except Exception as e:
                logger.error('Could not create %s' % output_dir)
                return None
    else:
        logger.error('%s does not exist.' % output_dir)
        return None

def clean_output_dir(output_dir):
    logger.warn('Cleaning out output directory %s' % output_dir)
    file_name = 'mtl1_*'
    file_pattern = os.path.join(output_dir, file_name)
    for match in glob(file_pattern):
        logger.warn('Removing file %s' % match)
        os.remove(match)

def clean_output_csv(output_dir):
    logger.warn('Cleaning out output directory %s' % output_dir)
    file_name = 'mtl1_*.csv'
    file_pattern = os.path.join(output_dir, file_name)
    for match in glob(file_pattern):
        logger.warn('Removing file %s' % match)
        os.remove(match)

if __name__ == '__main__':
    parser = parse_args()
    args = parser.parse_args()
    main(args)
