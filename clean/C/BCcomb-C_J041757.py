## configuration file for the combination of the C and B EVLA array
## configurations for the X band in J041757

COMB_CONFIG = {
    'data_prefix' : ['B-C_J041757', 'C-C_J041757'],
    'weight_mode' : 'statwt',
    'spw_show' : '3',
    'averagedata' : True,
    'avgchannel' : '16',
    'combined_file' : 'comb-C_J041757.ms'
    
}
