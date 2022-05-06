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
cest=/project/bbl_roalf_cest_dti/margaret_sandbox/data/inputs #path to processed GluCEST data inputs
outputs=/project/bbl_roalf_cest_predict/data/outputs #path to structural_script.sh outputs AND where GluCEST outputs will be saved
templates=/project/bbl_roalf_cest_predict/templates/ #path to templates
logdir=/project/bbl_roalf_cest_predict/cest_logs
#######################################################################################################

#######################################################################################################
## IDENTIFY CASES FOR PROCESSING ##

for i in $(ls $cest)
do
    case=${i##*/}

    #checking that subject has necessary input directories UPDATE THIS!!!
    if ([ -f $cest/$case/*INV2.nii.gz ] && [ -f $cest/$case/*UNI_Images.nii.gz ]) \
    || ([ -d $structural ] && [ -f $cest/$case/*mprage.nii.gz ])
    #making logflile and necessary directories
    
    then
    mkdir $logdir #Store logfiles here
    
    #define scantype based on structural scans available
        if [ -f $cest/$case/*INV2.nii.gz ] && [ -f $cest/$case/*UNI_Images.nii.gz ]
        then scantype="Terra" #not sure if need "" here
        elif [ -f $cest/$case/*mprage.nii.gz ]
        then scantype="ONM" 
        fi

    # submit job to bsub ~ two -o flags, may be causing issue?
    bsub -o $logdir/jobinfo.log bash glucest_script.sh -c $cest -o $outputs -m $templates -p $case -t $scantype -l $logdir
    
    else
    echo "$case is missing structural niftis. Will not process"
    sleep 1.5

    fi

done


#######################################################################################################
## IDENTIFY CASES FOR PROCESSING ##
for i in $(ls $cest)
do
case=${i##*/}
echo "CASE: $case"
#check for structural data
if [ -e $structural/$case/$case-UNI-processed.nii.gz ] && [ -e $structural/$case/fast/${case}_seg.nii.gz ]
then
echo "Structural Data exists for $case"
sleep 1.5
else
echo "Oh No! Structural Data is missing. Cannot process CEST!"
sleep 1.5
fi
#check for GluCEST GUI data - update to -f .nii.gz
if [ -d $cest/$case/*B0MAP ] && [ -d $cest/$case/*B1MAP ] && [ -d $cest/$case/*B0B1CESTMAP ] 
then
echo "CEST GUI Data exists for $case"
sleep 1.5
else
echo "Oh No! CEST GUI Data is missing. Cannot process CEST!"
sleep 1.5
fi
if ! [ -d $cest/$case ] && [ -d $cest/$case/*B0MAP ] && [ -d $cest/$case/*B1MAP ] && [ -d $cest/$case/*B0B1CESTMAP ] && [ -e $structural/$case/fast/${case}_seg.nii.gz ]
then