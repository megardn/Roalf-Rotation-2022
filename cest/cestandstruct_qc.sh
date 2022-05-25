#!/bin/bash

#####################
# Copied from Joelle B's DTI project, added structural QC
# This script makes QC images for the CEST GUI ouput (B0, B1, BOB1CEST) and corresponding htmls for easy quality control.
# as well as structural scans (MPRAGE for ONM, MP2RAGE UNI & INV2 for TERRA)
# activate xbash and make sure to have fsl loaded before running this (fsl slicer function is called). Loaded automatically with the BBL bash_rc line.
#####################

# cest directory
cest=/project/bbl_roalf_cest_predict/data/data.pull
logdir=/project/bbl_roalf_cest_predict/logs/

cest_logfile=$logdir/cest_gui_qc.log # if want to keep track of stuff in log file
{

    for i in $(ls $cest) # script will only be executed for participants in this directory
        do

        participant=${i##*/}
        # participant=14528
        # participant=106573_8900

        for j in $(ls $cest/$participant)
            do 
            session=${j##*/}
        
            if [ -f $cest/$participant/$session/cest/*/*B0map.nii ] \
                && [ -f $cest/$participant/$session/cest/*/*B1map.nii ] \
                && [ -f $cest/$participant/$session/cest/*/*B0B1CESTmap.nii ] 

            then
            
            echo -e "\n------- MAKING QC IMAGES for $participant/$session -------\n"

            if ! [ -d $logdir/Quality_Control/QC_Preprocessing_pngs ]
            then
            mkdir $logdir/Quality_Control/QC_Preprocessing_pngs
            fi

            if ! [ -e $logdir/Quality_Control/QC_Preprocessing_pngs/QC_GUI_CEST.html ]
            then
            touch $logdir/Quality_Control/QC_Preprocessing_pngs/QC_GUI_CEST.html
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

            slicer $cest/$participant/$session/cest/cest_gui_niftis/*B0map.nii -i -1.3 1.3 -a $logdir/Quality_Control/QC_Preprocessing_pngs/$participant-$session-B0MAP-qc.png
            slicer $cest/$participant/$session/cest/cest_gui_niftis/*B1map.nii -i 0 3.3 -a $logdir/Quality_Control/QC_Preprocessing_pngs/$participant-$session-B1MAP-qc.png
            slicer $cest/$participant/$session/cest/cest_gui_niftis/*B0B1CESTmap.nii -i 0 16 -a $logdir/Quality_Control/QC_Preprocessing_pngs/$participant-$session-CEST-qc.png


            echo "<br> <strong>$participant-$session</strong><br>
            <img src=$participant-$session-B0MAP-qc.png height="350" width="350">
            <img src=$participant-$session-B1MAP-qc.png height="350" width="350">
            <img src=$participant-$session-CEST-qc.png height="350" width="350">
            <br> 

            " >> $logdir/Quality_Control/QC_Preprocessing_pngs/QC_GUI_CEST.html
                
            
            else
            echo "$cest/$participant/$session/cest is missing CEST niftis. Skipping this participant/session."
            # sleep 1.5
            fi

        done
    done

} | tee "$cest_logfile"

#structural QC
struc_logfile=$logdir/struc_data.pull_qc.log # if want to keep track of stuff in log file
{

    for i in $(ls $cest) # script will only be executed for participants in this directory
        do

        participant=${i##*/}

        for j in $(ls $cest/$participant)
            do 
            session=${j##*/}
        
        #find MPRAGE or INV2&UNI - ask about "mp2rage"
            if ([ -f $cest/$participant/$session/structural/*INV2.nii.gz ] && [ -f $cest/$participant/$session/structural/*UNI_Images.nii.gz ]) \
            || [ -f $cest/$participant/$session/structural/*mprage.nii.gz ]
            then
            
            echo -e "\n------- MAKING QC IMAGES for $participant/$session -------\n"

            if ! [ -d $logdir/Quality_Control ]
            then
            mkdir $logdir/Quality_Control
            fi

            if ! [ -e $logdir/Quality_Control/QC_Preprocessing_pngs/QC_STRUCT_DATA.PULL.html ]
            then
            touch $logdir/Quality_Control/QC_Preprocessing_pngs/QC_STRUCT_DATA.PULL.html
            echo "<html>

            <head>
            <title>B0B1 Corrected CEST QC</title>
            </head>

            <body>

            <br><strong><font size="7.5" color="1814A1"> CEST DATA QUALITY CONTROL</font></strong><br>
            <br>

            " >> $logdir/Quality_Control/QC_Preprocessing_pngs/QC_STRUCT_DATA.PULL.html
            fi

            if [ -f $cest/$participant/$session/structural/*mprage.nii.gz ] #mprage
            then
            slicer $cest/$participant/$session/structural/*mprage.nii.gz -a $logdir/Quality_Control/QC_Preprocessing_pngs/$participant-$session-mprage-qc.png

            echo "<br> <strong>$participant-$session MPRAGE</strong><br>
            <img src=$participant-$session-mprage-qc.png height="350" width="700">
            <br> 
            
            " >> $logdir/Quality_Control/QC_Preprocessing_pngs/QC_STRUCT_DATA.PULL.html

            elif [ -f $cest/$participant/$session/structural/*INV2.nii.gz ] \
                && [ -f $cest/$participant/$session/structural/*UNI_Images.nii.gz ] #INV2 & UNI
            then
            slicer $cest/$participant/$session/structural/*INV2.nii.gz -a $logdir/Quality_Control/QC_Preprocessing_pngs/$participant-$session-INV2-qc.png
            slicer $cest/$participant/$session/structural/*UNI_Images.nii.gz -a $logdir/Quality_Control/QC_Preprocessing_pngs/$participant-$session-UNI-qc.png

            echo "<br> <strong>$participant-$session INV2 & UNI</strong><br>
            <img src=$participant-$session-INV2-qc.png height="350" width="700">
            <img src=$participant-$session-UNI-qc.png height="350" width="700">
            <br> 
            
            " >> $logdir/Quality_Control/QC_Preprocessing_pngs/QC_STRUCT_DATA.PULL.html
            fi 

            else
            echo "$cest/$participant/$session is missing structural niftis. Skipping this participant/session."
            # sleep 1.5
            fi

        done
    done

} | tee "$struc_logfile"