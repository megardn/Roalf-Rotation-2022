#!/bin/bash

# This script creates a separate command to process each subject/session structural data (using structural_script-ML.sh) and submits it as jobs to bsub on PMACS. 
# Adapted from Joelle B's script 03_cest_postproc_structural_config.sh
# start xbash and module load ANTs/2.3.5 prior to running this (added to .bash_profile).

#The processing pipeline includes:
	#UNI (uniform image) and INV2 dicom to nifti conversion 
	#structural brain masking
	#ANTS N4 bias field correction
	#FSL FAST (for tissue segmentation and gray matter probability maps)
	#UNI to MNI registration with ANTS SyN (rigid+affine+deformable syn)

#######################################################################################################
## DEFINE PATHS ##
structural=/project/bbl_roalf_cest_predict/data/outputs
niftis=/project/bbl_roalf_cest_predict/data/outputs/inputs #path to nifti inputs
templates=/project/bbl_roalf_cest_predict/templates/ # path to templates
logdir=/project/bbl_roalf_cest_predict/structural_logs
#ANTSPATH=/appl/ANTs-2.3.1/bin/ #added to .bash_profile
#######################################################################################################

#######################################################################################################
## IDENTIFY CASES FOR PROCESSING ##

for i in $(ls $niftis)
do
    case=${i##*/}

    #checking that subject has necessary input directories 
    if ([ -d $structural ] && [ -f $niftis/$case/*INV2.nii.gz ] && [ -f $niftis/$case/*UNI_Images.nii.gz ]) \
    || ([ -d $structural ] && [ -f $niftis/$case/*mprage.nii.gz ])
    #making logflile and necessary directories
    
    then
    mkdir $structural/$case
    mkdir $structural/$case/structural
    mkdir $structural/$case/structural/fast
    mkdir $structural/$case/structural/MNI_transforms

    mkdir $logdir #Store logfiles here.

    #define scantype based on structural scans available
        if [ -f $niftis/$case/*INV2.nii.gz ] && [ -f $niftis/$case/*UNI_Images.nii.gz ]
        then scantype="Terra" #not sure if need "" here
        elif [ -f $niftis/$case/*mprage.nii.gz ]
        then scantype="ONM" 
        fi

    # submit job to bsub ~ two -o flags, may be causing issue?
    bsub -o $logdir/jobinfo.log bash structural_script-ML.sh -o $structural -m $templates -p $case -d $dicoms -t $scantype -l $logdir
    
    else
    echo "$case is missing structural niftis. Will not process"
    sleep 1.5

    fi

done

#TO DO:
##worth presorting subject/session? or just sort outputs to correct output dir w/  outputs from pyglucest?
##why not use .nii that're already in raw_data/sub/ses/mp2rage INV2 and UNI dirs?