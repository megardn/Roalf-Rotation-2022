#!/bin/bash

#script to grab images of what i think are B1map, B0map and B1B0CESTmaps from mOFC CEST project

logdir=/project/bbl_roalf_cest_predict/logs

b0_pathlist="/project/bbl_roalf_cest_predict/data/data.pull/87225/9459/data/DR/B0MAP/87225_9459_B0MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/92886/9087/data/DR/B0MAP/92886_9087_B0MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/94028/9203/data/GluCEST/mOFC/B0map.nii"

b1_pathlist="/project/bbl_roalf_cest_predict/data/data.pull/132179/9726/data/PR/B1MAP/132179_9726_B1MAP_mOFC_PR.nii /project/bbl_roalf_cest_predict/data/data.pull/87225/9459/data/DR/B1MAP/87225_9459_B1MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/92886/9087/data/DR/B1MAP/92886_9087_B1MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/94028/9203/data/GluCEST/mOFC/B1map.nii"

cest_pathlist="/project/bbl_roalf_cest_predict/data/data.pull/132179/9726/data/PR/132179_9726_mOFC_cest_PR.nii /project/bbl_roalf_cest_predict/data/data.pull/87225/9459/data/87225_9459_mOFC_cest.nii /project/bbl_roalf_cest_predict/data/data.pull/92886/9087/data/DR/92886_9087_mOFC_cest_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/94028/9203/data/GluCEST/mOFC/B0B1CESTmap.nii"

if ! [ -d $logdir/mofc ]
    then
    mkdir $logdir/mofc
    touch $logdir/mofc/QC_GUI_CEST.html
    echo "<html>
        <br><strong><font size="7.5" color="1814A1"> mOFC CEST DATA QUALITY CONTROL</font></strong><br>
        <br>

        " >> $logdir/mofc/QC_GUI_CEST.html
fi

#B0
for b0 in $b0_pathlist 
    do
    file=${b0##*/}        

    slicer $b0 -i -1.3 1.3 -a $logdir/mofc/$file.png
    echo "<br> <strong>$b0</strong><br>
    <img src=$file.png height="350"#>
    <br> 

    " >> $logdir/mofc/QC_GUI_CEST.html
                
    done
#B1
for b1 in $b1_pathlist 
    do
    file=${b1##*/}        

    slicer $b1 -i 0 3.3 -a $logdir/mofc/$file.png
    echo "<br> <strong>$b1</strong><br>
    <img src=$file.png height="350"#>
    <br> 

    " >> $logdir/mofc/QC_GUI_CEST.html
                
    done

#CEST
for cest in $cest_pathlist 
    do
    file=${cest##*/}        

    slicer $cest -i 0 16 -a $logdir/mofc/$file.png
    echo "<br> <strong>$cest</strong><br>
    <img src=$file.png height="350"#>
    <br> 

    " >> $logdir/mofc/QC_GUI_CEST.html
                
    done