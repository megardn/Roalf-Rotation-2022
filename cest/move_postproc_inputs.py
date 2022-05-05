import os
import re

#Script to organize raw CEST data to create data_dir input for `structural_script-ML.sh`:
#expects dir that stores and *mprage.nii.gz OR *INV2.nii.gz AND *UNI_Images.nii.gz (BBLID_ScanID) 
##Question: also wants none.nii?

from_struc = '/project/bbl_roalf_cest_dti/margaret_sandbox/data/rawdata'
from_cest = '/project/bbl_roalf_cest_dti/margaret_sandbox/data/matobj'
to_data = '/project/bbl_roalf_cest_dti/margaret_sandbox/data/inputs'

#pull raw data
subs = os.listdir(from_data)

i = 0
while i < len(subs):
    
    #index subjects
    sub = subs[i]

    sub_path = os.path.join(from_data, sub)

    for ses in os.listdir(sub_path):

        ses_path = os.path.join(sub_path, ses, 'cest')

        # make to_data folder for that subject - ok way to denote session?
        os.system(' '.join(['mkdir', os.path.join(to_data, sub+'_'+ses), '-p']))
        
        # copy the raw cest folder contents in 
        os.system(' '.join(['cp', 
                           os.path.join(from_data, sub, ses, 'cest', '*'), 
                           os.path.join(to_data, sub+'_'+ses),
                           '-r']))

        #also grab .mat files
        os.system(' '.join(['cp', 
                           os.path.join(from_mat, sub+'_'+ses+'*'), 
                           os.path.join(to_data, sub+'_'+ses)]))


    i = i + 1

