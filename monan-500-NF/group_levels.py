import netCDF4 as nc
import numpy as np
import re
import sys

if len(sys.argv) != 4:
    print("Usage: python script.py <string1> <string2>")
    sys.exit(1)

# /mnt/beegfs/eduardo.khamis/issues/488/feature-488/scripts_CD-CT/dataout/2024020100/Post
data_dir = sys.argv[1]
file_in = sys.argv[2]
file_out = sys.argv[3]

nc_file_in = nc.Dataset(f'{data_dir}/{file_in}', 'r')
# Save the concatenated variables to a new NetCDF file
nc_file_out = nc.Dataset(f'{data_dir}/{file_out}', 'w')

dimensions_4D = ('time', 'latitude', 'longitude', 'level')
# Group variables based on their names
variable_groups = {}
first_hpa_variable = ''
for name, variable in nc_file_in.variables.items():
    # if 'hPa' in name or name in dimensions_4D:
    if 'hPa' in name:
        variable_type = re.split('_.*hPa', name)[0]  # Extract the variable type (e.g., '15hPa', '20hPa')
        first_hpa_variable = variable_type if first_hpa_variable == '' else first_hpa_variable  
    else:
        variable_type = name
    if variable_type not in variable_groups:
        variable_groups[variable_type] = [variable]
    else:
        variable_groups[variable_type].append(variable)


level_dimension_size = len(variable_groups[first_hpa_variable]) 


# Copy dimensions Time, latitude, longitude
for dim_name, dim_type in nc_file_in.dimensions.items():
    if dim_name.lower() in ['time', 'latitude', 'longitude']:
        nc_file_out.createDimension(dim_name, dim_type.size)
# Create level dimension
nc_file_out.createDimension('level', level_dimension_size)

# Copy variables
for variable_type, variables in variable_groups.items():
    print(f'Creating var {variable_type}')
    if variable_type == 'level':
        new_variable = nc_file_out.createVariable(variable_type, variables[0].dtype, variables[0].dimensions)
        new_variable.setncatts({k: variables[0].getncattr(k) for k in variables[0].ncattrs()})
        new_variable[:] = range(level_dimension_size, 0, -1)
    elif len(variables) == level_dimension_size:
        new_variable = nc_file_out.createVariable(variable_type, variables[0].dtype, dimensions_4D)
        new_variable.setncatts({k: variables[0].getncattr(k) for k in variables[0].ncattrs()})
        for i in range(level_dimension_size):
            print(f'copying variable level {i}')
            new_variable[:,:,:,i] = variables[i][:]
    else:
        # variable_type in ('latitude', 'longitude', 'Time'):
        new_variable = nc_file_out.createVariable(variable_type, variables[0].dtype, variables[0].dimensions)
        new_variable.setncatts({k: variables[0].getncattr(k) for k in variables[0].ncattrs()})
        new_variable[:] = variables[0][:]

nc_file_out.close()
nc_file_in.close()
