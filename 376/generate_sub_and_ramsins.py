with open('RAMSIN_BASIC_GF_10KM__TEMPLATE', 'r') as ramsin_template:
    with open('sub_gf_TEMPLATE.sbatch', 'r') as sub_template:
        lines_ramsin_template = ramsin_template.readlines()
        lines_sub_template = sub_template.readlines()
        
        for runtype in ['SFC', 'MAKEVFILE', 'INITIAL']:
            for nnxp in range(20,70,10):
                nnyp = nnxp
                nnxp_x_nnyp = f'{nnxp}x{nnyp}'
                
                
                lines_ramsin = lines_ramsin_template
                lines_ramsin = [line.replace('<RUNTYPE>', runtype) for line in lines_ramsin]
                lines_ramsin = [line.replace('<NNXP>', str(nnxp)) for line in lines_ramsin]
                lines_ramsin = [line.replace('<NNYP>', str(nnyp)) for line in lines_ramsin]
                lines_ramsin = [line.replace('<NNXPxNNYP>', nnxp_x_nnyp) for line in lines_ramsin]
        
                file_ramsin = open(f'RAMSIN_BASIC_GF_10KM__{nnxp_x_nnyp}_{runtype}', 'w')
                file_ramsin.writelines(lines_ramsin)
                
                
                lines_sub = lines_sub_template
                lines_sub = [line.replace('<RUNTYPE>', runtype) for line in lines_sub]
                lines_sub = [line.replace('<NNXPxNNYP>', nnxp_x_nnyp) for line in lines_sub]
        
                file_sub = open(f'sub_gf_10KM__{nnxp_x_nnyp}_{runtype}.sbatch', 'w')
                file_sub.writelines(lines_sub)
                
