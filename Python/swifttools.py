import numpy as np
import pandas as pd
import xarray as xr
from scipy.io import loadmat


def read_swift(mat_file, variable_name = 'SWIFT', starttime = None, endtime = None):
    """ 
    Import a matlab SWIFT-struct to python
   
    Returns a pandas.DataFrame with the same fields as the SWIFT-struct. 
    Also adds a field 'timestamp' where matlabs datenum format is converted
    to pandas datetime.
    
    Parameters:
    
        matfile:           Path to a .mat-file where the SWIFT-struct is saved
        
        variable_name:     Name of the SWIFT-struct. Default value: 'SWIFT'
        
        starttime/endtime: Select part of the deployment based on time range. Default: None
            
    Example:
        read_swift('path/to/file.mat', starttime = numpy.datetime64('2023-03-28 19:01'))   
    """
    
    # Load matlab struct as a nested list of dicts
    swift_ld = loadmat(mat_file, simplify_cells = True)[variable_name] 
    
    # Convert nested list of dicts to pandas.DataFrame
    swift_df = pd.json_normalize(swift_ld)
    
    # The time format is in "UTC timestamp in MATLAB datenum format", 
    # which mean that the unit is days since 0 jan 0000. 
    # Convert this to python timestamp.  
    # (Source: https://stackoverflow.com/a/49135037/11028793)
    timestamps = pd.to_datetime(swift_df['time']-719529, unit='D')   
    swift_df.insert(1, 'timestamp', timestamps.dt.round('1s') )
    
    # Pick desired time interval
    if starttime is not None:
        swift_df = swift_df[swift_df.timestamp >= starttime].reset_index(drop=True)       
    if endtime is not None:
        swift_df = swift_df[swift_df.timestamp <= endtime].reset_index(drop=True)
        
    return swift_df


def wavespectra_to_xr(swift_df): 
    """
    Takes a swift dataframe (from read_swift) as input and returns an xarray dataset with 
    wavespectra data, i.e all columns called wavespectra.<variable> in the swift dataframe. 
    The xarray dataset will have coordinates 'time' and 'freq'.
    """
        
    group = 'wavespectra'
    coordinate_name = 'freq'    
    coordinate_column = (group + '.' + coordinate_name)
    
    # Find all columns with wavespectra data
    variable_columns = []   
    for col in swift_df.columns.difference({coordinate_column}):
        if col.startswith(group):
            variable_columns.append(col)
            
    # Convert wavespectra data to 2D-array and create a dictionary
    coordinate = swift_df[coordinate_column].iloc[0]
    data = {}
    for col in variable_columns:
        variable_name   = col[len(group)+1:]
        values = swift_df[col].to_numpy()       
        
        # If data is missing for a row, replace None with array of NaN (so that all rows has same length)
        values = [i if i is not (None or np.NaN) else np.NaN*np.zeros(len(coordinate)) for i in values]
        
        data[variable_name] = ([coordinate_name, 'time'], np.vstack(values).T)

    # Create xarray dataset                
    wave_ds = xr.Dataset(data_vars = data,
                         coords = dict(freq = coordinate,
                                       time = swift_df['timestamp'].values)
                        )

    return wave_ds
