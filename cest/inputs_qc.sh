#!/bin/bash

#####################
# Copy of cestandstruct_qc.sh updated to extract files from data/inputs 
# rather than data/data.pull (to capture mOFC dicoms converted by move_postproc_inputs_manual.sh).
# This script makes QC images for the CEST GUI ouput (B0, B1, BOB1CEST) and corresponding htmls for easy quality control.
# as well as structural scans (MPRAGE for ONM, MP2RAGE UNI & INV2 for TERRA)
# activate xbash and make sure to have fsl loaded before running this (fsl slicer function is called). Loaded automatically with the BBL bash_rc line.
#####################

# cest directory
inputs=/project/bbl_roalf_cest_predict/data/inputs
logdir=/project/bbl_roalf_cest_predict/logs/

cest_logfile=$logdir/cest_inputs_qc.log
{

    for ses in $(ls $inputs) # script will only be executed for participants in this directory
        do
            if [ -f $inputs/$ses/*B0map.nii ] \
                && [ -f $inputs/$ses/*B1map.nii ] \
                && [ -f $inputs/$ses/*B0B1CESTmap.nii ] 

            then
            
            echo -e "\n------- MAKING QC IMAGES for $ses -------\n"

            if ! [ -d $logdir/Quality_Control/QC_inputs_pngs ]
            then
            mkdir $logdir/Quality_Control/QC_inputs_pngs
            fi

            if ! [ -e $logdir/Quality_Control/QC_inputs_pngs/QC_inputs_CEST.html ]
            then
            touch $logdir/Quality_Control/QC_inputs_pngs/QC_inputs_CEST.html
            echo "<html>

            <head>
            <title>B0B1 Corrected CEST QC</title>
            </head>

            <body>

            <br><strong><font size="7.5" color="1814A1"> CEST DATA QUALITY CONTROL</font></strong><br>
            <br>
            <br><strong><font size="5" color="1814A1">&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;B0 &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; B1 &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;B0B1-corrected CEST</font></strong><br>
            <br>

            " >> $logdir/Quality_Control/QC_Preprocessing_pngs/QC_GUI_CEST.html
            fi

            slicer $inputs/$ses/*B0map.nii -i -1.3 1.3 -a $logdir/Quality_Control/QC_inputs_pngs/$ses-B0MAP-qc.png
            slicer $inputs/$ses/*B1map.nii -i 0 3.3 -a $logdir/Quality_Control/QC_inputs_pngs/$ses-B1MAP-qc.png
            slicer $inputs/$ses/*B0B1CESTmap.nii -i 0 16 -a $logdir/Quality_Control/QC_inputs_pngs/$ses-CEST-qc.png


            echo "<br> <strong>$ses-</strong><br>
            <img src=$ses-B0MAP-qc.png height="350" width="350">
            <img src=$ses-B1MAP-qc.png height="350" width="350">
            <img src=$ses-CEST-qc.png height="350" width="350">
            <br> 

            " >> $logdir/Quality_Control/QC_inputs_pngs/QC_inputs_CEST.html
                
            
            else
            echo "$ses is missing CEST niftis. Skipping this participant/session."
            # sleep 1.5
            fi

        done


} | tee "$cest_logfile"

#structural QC
struc_logfile=$logdir/struc_inputs_qc.log # if want to keep track of stuff in log file
{

    for ses in $(ls $inputs) # script will only be executed for participants in this directory
        do
        #find MPRAGE or INV2&UNI - ask about "mp2rage"
            if ([ -f $inputs/$ses/*INV2.nii.gz ] && [ -f $inputs/$ses/*UNI_Images.nii.gz ]) \
            || [ -f $inputs/$ses/*mprage.nii.gz ]
            then
            
            echo -e "\n------- MAKING QC IMAGES for $ses -------\n"

            if ! [ -d $logdir/Quality_Control ]
            then
            mkdir $logdir/Quality_Control
            fi

            if ! [ -e $logdir/Quality_Control/QC_inputs_pngs/QC_STRUCT_INPUTS.html ]
            then
            touch $logdir/Quality_Control/QC_inputs_pngs/QC_STRUCT_INPUTS.html
            echo "<html>

            <head>
            <title>B0B1 Corrected CEST QC</title>
            </head>

            <body>

            <br><strong><font size="7.5" color="1814A1"> CEST DATA QUALITY CONTROL</font></strong><br>
            <br>

            " >> $logdir/Quality_Control/QC_inputs_pngs/QC_STRUCT_INPUTS.html
            fi

            if [ -f $inputs/$ses/*mprage.nii.gz ] #mprage
            then
            slicer $inputs/$ses/*mprage.nii.gz -a $logdir/Quality_Control/QC_inputs_pngs/$ses-mprage-qc.png

            echo "<br> <strong>$ses MPRAGE</strong><br>
            <img src=$ses-mprage-qc.png height="350" width="700">
            <br> 
            
            " >> $logdir/Quality_Control/QC_inputs_pngs/QC_STRUCT_INPUTS.html

            elif [ -f $inputs/$ses/*INV2.nii.gz ] \
                && [ -f $inputs/$ses/*UNI_Images.nii.gz ] #INV2 & UNI
            then
            slicer $inputs/$ses/*INV2.nii.gz -a $logdir/Quality_Control/QC_inputs_pngs/$ses-INV2-qc.png
            slicer $inputs/$ses/*UNI_Images.nii.gz -a $logdir/Quality_Control/QC_inputs_pngs/$ses-UNI-qc.png

            echo "<br> <strong>$ses INV2 & UNI</strong><br>
            <img src=$ses-INV2-qc.png height="350" width="700">
            <img src=$ses-UNI-qc.png height="350" width="700">
            <br> 
            
            " >> $logdir/Quality_Control/QC_inputs_pngs/QC_STRUCT_INPUTS.html
            fi 

            else
            echo "$ses is missing structural niftis. Skipping this participant/session."
            # sleep 1.5
            fi

        done
    

} | tee "$struc_logfile"