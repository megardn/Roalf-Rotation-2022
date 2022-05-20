#!/bin/bash

#####################
# This script makes QC images for the CEST postprocessed ouput (with overlaid atlases) and corresponding htmls for easy quality control.
# activate xbash and make sure to have fsl loaded before running this (fsl slicer function is called). Loaded automatically with the BBL bash_rc line.
#####################

#paths
cest=/project/bbl_roalf_cest_predict/data/outputs
logdir=/project/bbl_roalf_cest_predict/logs
cest_logfile=$logdir/cest_postproc_qc.log
{
for i in $(ls $cest) # script will only be executed for participants in this directory
    do

        case=${i##*/}

        if [ -f $cest/$case/orig_data/*B0map.nii ] \
        && [ -f $cest/$case/orig_data/*B1map.nii ] \
        && [ -f $cest/$case/orig_data/*B0B1CESTmap.nii ] \
        && [ -f $cest/$case/*GluCEST.nii.gz ] \
        && [ -f $cest/$case/atlases/*2d-HarvardOxford-sub.nii.gz ] \
        && [ -f $cest/$case/atlases/*2d-HarvardOxford-cort.nii.gz  ]

        then
            
        echo -e "\n------- MAKING POSTPROCESSING QC IMAGES for $case -------\n"

            
            if ! [ -d $logdir/Quality_Control/QC_Postprocessing_pngs ]
            then
                mkdir $logdir/Quality_Control/QC_Postprocessing_pngs
            fi


            if ! [ -e $logdir/Quality_Control/QC_postproc.html ]
            then
                touch $logdir/Quality_Control/QC_postproc.html
                echo "<html>

                <head>
                <title>Quality Control: FINAL GLUCEST</title>
                </head>

                <body>

                <br><strong><font size="7.5" color="1814A1"> QUALITY CONTROL: FINAL THRESHOLDED GLUCEST, Harvard-Oxford Subcortical and Cortical </font></strong><br>
                <br>
                <br><strong><font size="5" color="1814A1">&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;Thresholded GluCEST &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;Subcortical  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;Cortical </font></strong><br>
                <br>

                " >> $logdir/Quality_Control/QC_postproc.html
            fi

        
        # creating gluCEST png (with slicer from FSL)
        slicer $cest/$case/*GluCEST.nii.gz -i 0 16 -a $logdir/Quality_Control/QC_Postprocessing/$case-GluCEST-qc.png
            
        # creating Harvard-Oxford pngs (with overlay from FSL)
        overlay 1 0 $cest/$case/*GluCEST.nii.gz -a $cest/$case/atlases/*2d-HarvardOxford-sub.nii.gz 1 20 $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-sub-overlay.nii.gz
        slicer $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-sub-overlay.nii.gz  -l /import/monstrum/Applications/fsl/etc/luts/renderhot.lut -a $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-sub-qc.png
        rm -f $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-sub-overlay.nii.gz

        overlay 1 0 $cest/$case/*GluCEST.nii.gz -a $cest/$case/atlases/*2d-HarvardOxford-cort.nii.gz 1 20 $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-cort-overlay.nii.gz
        slicer $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-cort-overlay.nii.gz  -l /import/monstrum/Applications/fsl/etc/luts/renderhot.lut -a $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-cort-qc.png
        rm -f $logdir/Quality_Control/QC_Postprocessing_pngs/$case-HO-cort-overlay.nii.gz

                echo "<br> <strong>$case</strong><br>
        <img src=$case-GluCEST-qc.png height="350" width="350">
        <img src=$case-HO-sub-qc.png height="350" width="350">
        <img src=$case-HO-cort-qc.png height="350" width="350">
        <br>


        " >> $logdir/Quality_Control/QC_postproc.html

#######################################################################################################

        echo -e "\n$case SUCCESFULLY PROCESSED\n\n\n"

        else
        echo "$case missing CEST niftis or postprocessing outputs. Skipping."
                # sleep 1.5
        fi
    done
    
} | tee "$logfile"