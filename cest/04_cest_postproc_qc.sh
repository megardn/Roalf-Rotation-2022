#!/bin/bash

#####################
# This script makes QC images for the CEST postprocessed ouput (with overlaid atlases) and corresponding htmls for easy quality control.
# activate xbash and make sure to have fsl loaded before running this (fsl slicer function is called). Loaded automatically with the BBL bash_rc line.
#####################

# cest directory
cest=/project/bbl_roalf_cest_dti/CEST


logfile=/home/joelleba/cest_postproc_qc.log # if want to keep track of stuff in log file
{
for dataset in 7T_Terra 7T_Magnetom; 
    do

    # if [ $dataset == 7T_Terra ]
    # then continue
    # niftis=cest/cest_gui_niftis
    # elif [ $dataset == 7T_Magnetom ]
    # then
    # niftis=cest/cest_gui_niftis
    # fi 

    niftis=cest/cest_gui_niftis
    postproc=postprocessing/${dataset}_cest_out

    for i in $(ls $cest/$dataset) # script will only be executed for participants in this directory
        do

        participant=${i##*/}
        # participant=14528
        # participant=106573_8900

        for j in $(ls $cest/$dataset/$participant)
            do 
            session=${j##*/}
            case=$participant-$session
            # session=8900

            # echo $(ls $cest/$dataset/$participant/$session/$niftis)
        
            if [ -f $cest/$dataset/$participant/$session/$niftis/*B0map.nii ] \
                && [ -f $cest/$dataset/$participant/$session/$niftis/*B1map.nii ] \
                && [ -f $cest/$dataset/$participant/$session/$niftis/*B0B1CESTmap.nii ] \
                && [ -f $cest/$postproc/$participant/$session/*GluCEST.nii.gz ] \
                && [ -f $cest/$postproc/$participant/$session/atlases/*2d-HarvardOxford-cort.nii.gz ] \
                && [ -f $cest/$postproc/$participant/$session/atlases/*-2d-JHU.nii.gz ]

            then
            
            echo -e "\n------- MAKING POSTPROCESSING QC IMAGES for $case -------\n"

            
            if ! [ -d $cest/Quality_Control/QC_Postprocessing_$dataset ]
            then
                mkdir $cest/Quality_Control/QC_Postprocessing_$dataset
            fi


            if ! [ -e $cest/Quality_Control/QC_Postprocessing_$dataset/QC_postproc_$dataset.html ]
            then
                touch $cest/Quality_Control/QC_Postprocessing_$dataset/QC_postproc_$dataset.html
                echo "<html>

                <head>
                <title>Quality Control: FINAL GLUCEST</title>
                </head>

                <body>

                <br><strong><font size="7.5" color="1814A1"> QUALITY CONTROL: FINAL THRESHOLDED GLUCEST, Harvard-Oxford atlas and JHU atlas </font></strong><br>
                <br>
                <br><strong><font size="5" color="1814A1">&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;Thresholded GluCEST &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp; Harvard-Oxford atlas  &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;JHU atlas </font></strong><br>
                <br>

                " >> $cest/Quality_Control/QC_Postprocessing_$dataset/QC_postproc_$dataset.html
            fi

        
            # creating gluCEST png (with slicer from FSL)
            slicer $cest/$postproc/$participant/$session/$case-GluCEST.nii.gz -i 0 16 -a $cest/Quality_Control/QC_Postprocessing_$dataset/$case-GluCEST-qc.png
            
            # creating Harvard-Oxford png (with overlay from FSL)
            overlay 1 0 $cest/$postproc/$participant/$session/$case-GluCEST.nii.gz -a $cest/$postproc/$participant/$session/atlases/$case-2d-HarvardOxford-cort.nii.gz 1 20 $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-overlay.nii.gz
            slicer $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-overlay.nii.gz  -l /import/monstrum/Applications/fsl/etc/luts/renderhot.lut -a $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-atlas-qc.png
            rm -f $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-overlay.nii.gz

            # creating JHU png
            overlay 1 0 $cest/$postproc/$participant/$session/$case-GluCEST.nii.gz -a $cest/$postproc/$participant/$session/atlases/$case-2d-JHU.nii.gz 1 20 $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-overlay.nii.gz
            slicer $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-overlay.nii.gz  -l /import/monstrum/Applications/fsl/etc/luts/renderhsv.lut -a $cest/Quality_Control/QC_Postprocessing_$dataset/$case-JHU-atlas-qc.png
            rm -f $cest/Quality_Control/QC_Postprocessing_$dataset/$case-HO-overlay.nii.gz


            echo "<br> <strong>$case</strong><br>
            <img src=$case-GluCEST-qc.png height="350" width="350">
            <img src=$case-HO-atlas-qc.png height="350" width="350">
            <img src=$case-JHU-atlas-qc.png height="350" width="350">
            <br>


            " >> $cest/Quality_Control/QC_Postprocessing_$dataset/QC_postproc_$dataset.html

            #######################################################################################################

            echo -e "\n$case SUCCESFULLY PROCESSED\n\n\n"

            else
                echo "$participant/$sessionis missing CEST niftis or postprocessing outputs. Skipping this participant/session."
                # sleep 1.5
            fi
        done
    done
done
} | tee "$logfile"