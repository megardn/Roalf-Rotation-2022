import os
import re

#Script to organize raw CEST data to create data_dir input for `structural_script-ML.sh` & `glucest_script.sh`:
#expects dir that stores and *mprage.nii.gz OR *INV2.nii.gz AND *UNI_Images.nii.gz (BBLID_ScanID) 

###SANDBOX PATHS###
from_data = '/project/bbl_roalf_cest_predict/data/data.pull'
to_data = '/project/bbl_roalf_cest_predict/data/inputs'

#pull raw data
subs = os.listdir(from_data)

i = 0
while i < len(subs):
    
    #index subjects
    sub = subs[i]
    #ignore random text files
    if sub.endswith('.txt'):
        print("ignoring text file")

    else:
        sub_path = os.path.join(from_data, sub)

        for ses in os.listdir(sub_path):
            ses_path=os.path.join(sub_path, ses)
            #ignore empty session directories - not actually working but whatever, moving on
            
            if len(os.listdir(ses_path)) == 0:
                print(ses+" is empty, moving on")

            else:
                # make to_data folder for that subject
                os.system(' '.join(['mkdir', os.path.join(to_data, sub+'_'+ses), '-p']))
        
                # copy the raw cest folder contents in 
                os.system(' '.join(['cp', 
                            os.path.join(sub_path, ses, 'cest/cest_gui_niftis', '*.n*'), 
                            os.path.join(to_data, sub+'_'+ses),
                            '-r']))

                # also grab structural
                os.system(' '.join(['cp', 
                            os.path.join(sub_path, ses, 'structural', '*.n*'), 
                            os.path.join(to_data, sub+'_'+ses),
                            '-r']))


    i = i + 1
print("done")