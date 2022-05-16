#!/bin/bash

# This script creates a separate command to process each subject/session CEST data (using glucest_script.sh) and submits it as jobs to bsub on PMACS. 

# This script requires that:
#1. The structural_script-ML.sh has been run
#2. The CEST data has been processed via the Matlab GUI cest2d_TERRA_SYRP and outputs converted to nifti format

#The processing pipeline includes:
#B0 and B1 map thresholding of GluCEST images
#CSF removal from GluCEST images 
#GluCEST brain masking - now in pyglucest???
#registration of atlases from MNI space to participant UNI or MPRAGE images
#registration of FAST segmentation to GluCEST images
#generation HarvardOxford cortical and subcortical masks
#######################################################################################################
## DEFINE PATHS ##  QUESTION: IDK why what's up with dicom vs structural paths, switching paths over to outputs dir which holds pyGluCEST nifti and structural_script.sh nifti outputs
cest=/project/bbl_roalf_cest_predict/data/sandbox/inputs #path to processed GluCEST data inputs
outputs=/project/bbl_roalf_cest_predict/data/sandbox/outputs #path to structural_script.sh outputs AND where GluCEST outputs will be saved
templates=/project/bbl_roalf_cest_predict/templates/ #path to templates
logdir_base=/project/bbl_roalf_cest_predict/logs/sandbox_cest
#######################################################################################################

#######################################################################################################
## IDENTIFY CASES FOR PROCESSING ##

for i in $(ls $cest)
do
    case=${i##*/}

    #checking that subject has necessary structural data & define scantype
    if [ -f $outputs/$case/structural/$case-UNI-processed.nii.gz ] && [ -f $outputs/$case/structural/fast/${case}_seg.nii.gz ]
    then 
    scantype="Terra"
    elif [ -f $outputs/$case/structural/$case-mprage-processed.nii.gz ] && [ -f $outputs/$case/structural/fast/${case}_seg.nii.gz ]
    then 
    scantype="ONM"
    else
    echo "Oh No! Structural Data is missing. Cannot process CEST!"
    exit
    fi

    #check for GluCEST GUI data - update to -f .nii.gz
    if [ -f $cest/$case/*-B0map.nii ] && [ -f $cest/$case/*-B1map.nii ] && [ -f $cest/$case/*-B0B1CESTmap.nii ] 
    then
    sleep 1
    else
    echo "Oh No! CEST GUI Data is missing. Cannot process CEST!"
    exit
    fi
    
    #make directories
    if [ ! -d $logdir_base ]
    then 
    mkdir $logdir_base #Store logfiles here
    fi
    logdir=$logdir_base/$case
    mkdir $logdir 
    mkdir $outputs/$case/fast
    mkdir $outputs/$case/orig_data
    mkdir $outputs/$case/structural/atlases
    mkdir $outputs/$case/atlases

    # submit job to bsub ~ two -o flags, may be causing issue?
    bsub -o $logdir/jobinfo.log bash glucest_script.sh -c $cest -o $outputs -m $templates -p $case -t $scantype -l $logdir

done