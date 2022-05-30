#!/bin/bash

#probably need to change dicom2nifti to dicom2nifti-unzip.sh - testing with unzip for now, dcm2niix exits w error on orig
#/project/bbl_projects/apps/melliott/scripts/dicom2nifti.sh

#manually converting and cleaning up some atypical inputs (mOFC data) not fully accounted for by `move_postproc_inpyts.py`
base=/project/bbl_roalf_cest_predict/data/inputs
dicoms=/project/bbl_roalf_cest_predict/data/dicom_anon
logdir=/project/bbl_roalf_cest_predict/logs

logfile=$logdir/mofc/mofc_convert_sort.log # if want to keep track of stuff in log file
{
#mOFC CEST INPUTS
for i in $(ls $dicoms) # script will only be executed for participants in this directory
    do
	sub=$(echo $i | cut -f1 -d_)
	ses=$(echo $i | cut -f2 -d_)

#B0
	for b0 in $(ls $dicoms/${sub}_${ses}/*B0MAP*)
    do
		if [ -f $base/${sub}_${ses}/${sub}-${ses}-B0map.nii ]
		then
		rm $base/${sub}_${ses}/${sub}-${ses}-B0map.nii
		fi 
		/project/bbl_projects/apps/melliott/scripts/dicom2nifti.sh -u -r Y -F $base/${sub}_${ses}/${sub}-${ses}-B0map.nii $dicoms/${sub}_${ses}/*B0MAP*/$b0
    done
#B1
	for b1 in $(ls $dicoms/${sub}_${ses}/*B1MAP*)
    do
		if [ -f $base/${sub}_${ses}/${sub}-${ses}-B1map.nii ]
		then
		rm $base/${sub}_${ses}/${sub}-${ses}-B1map.nii
		fi 
		/project/bbl_projects/apps/melliott/scripts/dicom2nifti.sh -u -r Y -F $base/${sub}_${ses}/${sub}-${ses}-B1map.nii $dicoms/${sub}_${ses}/*B1MAP*/$b1
    done

#CEST
	for cest in $(ls $dicoms/${sub}_${ses}/*CEST*)
    do
		if [ -f $base/${sub}_${ses}/${sub}-${ses}-B0B1CESTmap.nii ]
		then
		rm $base/${sub}_${ses}/${sub}-${ses}-B0B1CESTmap.nii
		fi 
		/project/bbl_projects/apps/melliott/scripts/dicom2nifti.sh -u -r Y -F $base/${sub}_${ses}/${sub}-${ses}-B0B1CESTmap.nii $dicoms/${sub}_${ses}/*CEST*/$cest  
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
done
} | tee "$logfile"