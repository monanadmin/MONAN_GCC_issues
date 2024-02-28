#!/usr/bin/env python

"""
 Vertically interpolate MPAS-Atmosphere fields to a specified set
 of isobaric levels. The interpolation is linear in log-pressur.

 Variables to be set in this script include:
    - levs_hPa : a list of isobaric levels, in hPa
    - field_names : a list of names of fields to be vertically interpolated
                    these fields must be dimensioned by ('Time', 'nCells', 'nVertLevels')
    - fill_val : a value to use in interpolated fields to indicate values below
                 the lowest model layer midpoint or above the highest model layer midpoint

HISTORY: 
- original version MDUDA at: https://forum.mmm.ucar.edu/threads/how-to-extract-wind-zonal-meridional-geopotential-height-using-the-convert_mpas-include_field.9147/#post-20289 - link to file = https://forum.mmm.ucar.edu/attachments/isobaric_interp-py.3375/

ToDo:
- use numpy (eg https://docs.scipy.org/doc/scipy/tutorial/interpolate/1D.html#tutorial-interpolate-1dsection )

"""


from netCDF4 import Dataset
from scipy.interpolate import interp1d

import sys
import numpy as np

from numba import jit, prange


# Variables to be set in this script readed in input_vars.txt
with open('input_vars.py', 'r') as file:
    # Evaluate each line as Python code and execute it
    for line in file:
        exec(line)
        print(line)
	

@jit(parallel=True)
def interpolate_and_save_fields(xtime, fields, pressure, nCells, levs, isobaric_fields, isobaric_fieldnames, fill_val):
    """
    Interpolates fields vertically and saves the interpolated fields
    :param xtime: Array of time values
    :param fields: Array of fields
    :param pressure: Array of pressure values
    :param nCells: Number of cells
    :param levs: Array of pressure levels to interpolate to
    :param isobaric_fieldnames: List of fields
    :param isobaric_fieldnames: List of field names
    :param fill_val: Fill value for out-of-range interpolation
    """
    
    # Loop over times
    for t in prange(len(xtime)):

        # TODO
        # timestring = xtime[t,0:19].tostring()
        # print('Interpolating fields at time '+timestring.decode('utf-8'))

        #
        # Vertically interpolate
        #
        for iCell in prange(nCells):

            i = 0
            for field in fields:
                # OLD - deprecated method, using scipy
                #
                # y = interp1d(pressure[t,iCell,:], field[t,iCell,:],
                #            bounds_error=False, fill_value=fill_val)
                # print(f'type y = {type(y)}')
                # for lev in prange(len(levs)):
                #   # print(f'y shape = {y(levs[lev]).shape}')
                #   # print(f'y = {y(levs[lev])}')
                #   # print(f'y type = {type( y(levs[lev]) )}')
                #   isobaric_fields[i][iCell] = y(levs[lev])
                #   i = i + 1

                # NEW -using np.interp - linear
                # TODO fix . check x_in, y_in dimensions
		


                # Handle out-of-range values manually
                x_in = pressure[t, iCell, :]
                y_in = field[t, iCell, :]
                x_min = x_in[0]
                x_max = x_in[-1]
                y_min = y_in[0]
                y_max = y_in[-1]
                
                for lev in prange(len(levs)):
                    if levs[lev] < x_min:
                        isobaric_fields[i][iCell, lev] = fill_val
                    elif levs[lev] > x_max:
                        isobaric_fields[i][iCell, lev] = fill_val
                    else:
                        isobaric_fields[i][iCell, lev] = np.interp(levs[lev], x_in, y_in)
                    i += 1


                # Perform linear interpolation using np.interp
                #y = np.interp(levs, pressure[t, iCell, :], field[t, iCell, :])
                #for lev in prange(len(levs)):
                #    isobaric_fields[i][iCell, lev] = y[lev]
                #    i += 1
		
		
                #
                # Perform interpolation along the z-dimension
                #interp_func = np.interp  # linear
                #x_in = pressure[t, iCell, :]
                #y_in = field[t, iCell, :]
                #y = interp_func(x_in, x_in, y_in,
                #                       left=fill_val, right=fill_val)  # Specify how to handle out-of-range values
                # TODO isobaric_fields[:][iCell] = y[:]
                #for lev in range(len(levs)):
                #    print(f'y shape = {y.shape}')
                #    print(f'y = {y[i]}')
                #    print(f'y type = {type(y[i])}')
                #    isobaric_fields[i][iCell] = y[i]
                #    i = i + 1
                #exit(0)

    return isobaric_fields		    
	    

def main():


    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print('')
        print('Usage: isobaric_interp.py <input filename> [output filename]')
        print('')
        print('       Where <input filename> is the name of an MPAS-Atmosphere netCDF file')
        print('       containing a 3-d pressure field as well as all 3-d fields to be vertically')
        print('       interpolated to isobaric levels, and [output filename] optionally names')
        print('       the output file to be written with vertically interpolated fields.')
        print('')
        print('       If an output filename is not given, interpolated fields will be written')
        print('       to a file named isobaric.nc.')
        print('')
        exit()

    filename = sys.argv[1]
    if len(sys.argv) == 3:
        outfile = sys.argv[2]
    else:
        outfile = 'isobaric.nc'

    # Read 3-d pressure, zonal wind, and meridional wind fields
    # on model zeta levels
    f_in = Dataset(filename)

    nCells = f_in.dimensions['nCells'].size
    nVertLevels = f_in.dimensions['nVertLevels'].size

    pressure = f_in.variables['pressure'][:]
    pressure = np.array(pressure)  # avoids problems in jit

    xtime = f_in.variables['xtime'][:]
    xtime = np.array(xtime)

    fields = []
    for field in field_names:
        field_np = np.array(f_in.variables[field][:])
        fields.append(field_np)

    f_in.close()

    # Convert pressure from Pa to hPa
    pressure = pressure * 0.01

    # Compute logarithm of isobaric level values and 3-d pressure field
    pressure = np.log(pressure)
   
    levs = np.log(levs_hPa)

    # Allocate list of output fields
    isobaric_fields = []
    isobaric_fieldnames = []
    for field in field_names:
        for lev in levs_hPa:
            isobaric_fields.append(np.zeros((nCells)))
            isobaric_fieldnames.append(field+'_'+repr(round(lev))+'hPa')

    # Create netCDF output file
    f_out = Dataset(outfile, 'w', clobber=False)

    f_out.createDimension('Time', size=None)
    f_out.createDimension('nCells', size=nCells)

    for field in isobaric_fieldnames:
        f_out.createVariable(field, 'f', dimensions=('Time','nCells'), fill_value=fill_val)
    
    isobaric_fields = interpolate_and_save_fields(xtime, fields, pressure, nCells, levs, isobaric_fields, isobaric_fieldnames, fill_val)

    # Save interpolated fields
    # Loop over times
    for t in range(len(xtime)): 
        for i in range(len(isobaric_fieldnames)):
            f_out.variables[isobaric_fieldnames[i]][t,:] = isobaric_fields[i][:]

    f_out.close()

if __name__ == "__main__":
    main()
