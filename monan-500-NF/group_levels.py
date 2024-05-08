import netCDF4 as nc
import numpy as np
import re
# Open the NetCDF file
data_dir = '/mnt/beegfs/denis.eiras/monan_github_issues_workspace/monan-500/'
# nc_file = nc.Dataset(f'{data_dir}diagnostics_2024-02-01.nc', 'r')
nc_file = nc.Dataset(f'{data_dir}MONAN_DIAG_G_POS_GFS_2024042900_2024042900.00.00.x1024002L55.nc', 'r')

dimensions_4D = ('Time', 'latitude', 'longitude', 'level')
# Group variables based on their names
variable_groups = {}
for name, variable in nc_file.variables.items():
    if 'hPa' in name or name in dimensions_4D:
        if 'hPa' in name:
            variable_type = re.split('_.*hPa', name)[0]  # Extract the variable type (e.g., '15hPa', '20hPa')
        else:
            variable_type = name
        if variable_type not in variable_groups:
            variable_groups[variable_type] = [variable]
        else:
            variable_groups[variable_type].append(variable)


level_dimension_size = len(variable_groups[variable_type]) 

# Save the concatenated variables to a new NetCDF file
new_nc_file = nc.Dataset(f'{data_dir}concatenated_file.nc', 'w')

# Copy dimensions Time, latitude, longitude
for dim_name, dim_type in nc_file.dimensions.items():
    if dim_name in ['Time', 'latitude', 'longitude']:
        new_nc_file.createDimension(dim_name, dim_type.size)
# Create level dimension
new_nc_file.createDimension('level', level_dimension_size)

# Copy variables
for variable_type, variables in variable_groups.items():
    print(f'Creating var {variable_type}')
    if variable_type == 'level':
        new_variable = new_nc_file.createVariable(variable_type, variables[0].dtype, variables[0].dimensions)
        new_variable.setncatts({k: variables[0].getncattr(k) for k in variables[0].ncattrs()})
        new_variable[:] = range(level_dimension_size, 0, -1)
    elif variable_type in ('latitude', 'longitude', 'Time'):
        new_variable = new_nc_file.createVariable(variable_type, variables[0].dtype, variables[0].dimensions)
        new_variable.setncatts({k: variables[0].getncattr(k) for k in variables[0].ncattrs()})
        new_variable[:] = variables[0][:]
    else:
        new_variable = new_nc_file.createVariable(variable_type, variables[0].dtype, dimensions_4D)
        new_variable.setncatts({k: variables[0].getncattr(k) for k in variables[0].ncattrs()})
        for i in range(level_dimension_size):
            print(f'copying variable level {i}')
            new_variable[:,:,:,i] = variables[i][:]


# Close the new NetCDF file
new_nc_file.close()
# Close the NetCDF file
nc_file.close()
