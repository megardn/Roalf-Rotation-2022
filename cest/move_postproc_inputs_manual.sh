#!/bin/bash

#manually cleaning up some atypical inputs not fully accounted for by `move_postproc_inpyts.py`
base=/project/bbl_roalf_cest_predict/data/inputs

#mOFC CEST INPUTS
b0_pathlist="/project/bbl_roalf_cest_predict/data/data.pull/105176/9332/data/DR/B0MAP/105176_9332_B0MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/87225/9459/data/DR/B0MAP/87225_9459_B0MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/92886/9087/data/DR/B0MAP/92886_9087_B0MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/94028/9203/data/GluCEST/mOFC/B0map.nii"
b1_pathlist="/project/bbl_roalf_cest_predict/data/data.pull/105176/9332/data/DR/B1MAP/105176_9332_B1MAP_mOFC_DR.nii
 /project/bbl_roalf_cest_predict/data/data.pull/132179/9726/data/PR/B1MAP/132179_9726_B1MAP_mOFC_PR.nii /project/bbl_roalf_cest_predict/data/data.pull/87225/9459/data/DR/B1MAP/87225_9459_B1MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/92886/9087/data/DR/B1MAP/92886_9087_B1MAP_mOFC_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/94028/9203/data/GluCEST/mOFC/B1map.nii"
cest_pathlist="/project/bbl_roalf_cest_predict/data/data.pull/105176/9332/data/DR/105176_9332_mOFC_cest_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/132179/9726/data/PR/132179_9726_mOFC_cest_PR.nii /project/bbl_roalf_cest_predict/data/data.pull/87225/9459/data/87225_9459_mOFC_cest.nii /project/bbl_roalf_cest_predict/data/data.pull/92886/9087/data/DR/92886_9087_mOFC_cest_DR.nii /project/bbl_roalf_cest_predict/data/data.pull/94028/9203/data/GluCEST/mOFC/B0B1CESTmap.nii"

#B0
for b0 in $b0_pathlist 
    do
    sub=$(echo "$b0" | sed -r 's_^(/[^/]*){4}/([^/]*)/.*$_\2_g')
    ses=$(echo "$b0" | sed -r 's_^(/[^/]*){5}/([^/]*)/.*$_\2_g')   

    if [ ! -f $base/${sub}_${ses}/${sub}-${ses}-B0map.nii ]
    then
    cp $b0 $base/${sub}_${ses}/${sub}-${ses}-B0map.nii
    fi          
    done
#B1
for b1 in $b1_pathlist 
    do
    sub=$(echo "$b1" | sed -r 's_^(/[^/]*){4}/([^/]*)/.*$_\2_g')
    ses=$(echo "$b1" | sed -r 's_^(/[^/]*){5}/([^/]*)/.*$_\2_g')   

    if [ ! -f $base/${sub}_${ses}/${sub}-${ses}-B1map.nii ]
    then
    cp $b1 $base/${sub}_${ses}/${sub}-${ses}-B1map.nii
    fi         
    done

#CEST
for cest in $cest_pathlist 
    do
    sub=$(echo "$cest" | sed -r 's_^(/[^/]*){4}/([^/]*)/.*$_\2_g')
    ses=$(echo "$cest" | sed -r 's_^(/[^/]*){5}/([^/]*)/.*$_\2_g')   

    if [ ! -f $base/${sub}_${ses}/${sub}-${ses}-B0B1CESTmap.nii ]
    then
    cp $cest $base/${sub}_${ses}/${sub}-${ses}-B0B1CESTmap.nii
    fi       
    done


#renaming mis-labeled mprages
for session in $(ls $base)
    do
        if [ -f $base/$session/${session}_mp2rage.nii.gz ] && [ ! -f $base/$session/${session}_mprage.nii.gz ]
        then
        cp $base/$session/${session}_mp2rage.nii.gz $base/$session/${session}_mprage.nii.gz
        fi
    done

#remove subjects I won't be using d/t QC issues - see labarchives for more notes
for bad_scan in 109577_8980 17622_8559 82051_10087 88760_9704 89279_9781 89367_8946
    do
        if [ -d $base/$bad_scan ]
        then
        rm -rf $base/$bad_scan
        fi
    done