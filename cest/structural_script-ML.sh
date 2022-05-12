#!/bin/bash

#This script processes 7T Terra MP2RAGE & ONM MPRAGE data. 
# will need to adapt to process Magnetom and/or abandoned in favor of HDBET + FAST/FIRST masking - See Joelle B's scripts
# submit jobs using submit_structural_script.sh

# may need to start xbash and module load ANTs/2.3.5 prior to running this (add to .bash_profile).
#Copied by MG from `/project/bbl_roalf_syrp/sandbox/sydnor_pmacsv/scripts` Jan 2022

#######################################################################################################
#The processing pipeline includes:
	#UNI (uniform image) and INV2 dicom to nifti conversion 
	#structural brain masking
	#ANTS N4 bias field correction
	#FSL FAST (for tissue segmentation and gray matter probability maps)
	#UNI to MNI registration with ANTS SyN (rigid+affine+deformable syn)

#######################################################################################################
## HELPFUNCTION ##
helpFunction()
{
   echo ""
   echo "Usage: $0 -o structural -m mni_templates -p case  -d dicoms"
   echo -e "\t-o Path to structural postprocessing output directory"
   echo -e "\t-m Path to MNI templates directory"
   echo -e "\t-p Case (BBLID_ScanSession)"
   echo -e "\t-d Input subdirectory containing structural scan niftis"
   echo -e "\t-t Scanner Type ('ONM' or 'Terra')"
   echo -e "\t-l Path to log subdirectory"
   exit 1 # Exit script after printing help
}
while getopts "o:m:p:d:t:l:" opt
do
   case "$opt" in
	o ) structural="$OPTARG" ;;
	m ) templates="$OPTARG" ;;
   p ) case="$OPTARG" ;;
	d ) niftis="$OPTARG" ;;
   t ) scantype="$OPTARG" ;;
   l ) logdir="$OPTARG" ;;
   ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$structural" ] || [ -z "$templates" ] || [ -z "$case" ] || [ -z "$niftis" ]
then
   echo "Some or all of the arguments are empty";
   helpFunction
fi
#######################################################################################################
## INITALIZE LOGFILE ##

logfile=$logdir/${case}_struct.log
{
echo "--------Processing structural data for $case $session---------"
sleep 1.5
echo "Output dir: $structural"
echo "MNI templates: $templates"
echo "Case: $case"
echo "Input niftis: $niftis"
echo "Scanner: $scantype"

#######################################################################################################
## STRUCTURAL DICOM CONVERSION ##

#add branchpoint to convert UNI & INV2 vs MPRAGE (for Magnetom?)
#worth presorting subject/session? or just sort outputs to correct output dir w/  outputs from pyglucest?

#convert UNI
#dcm2niix_afni -b y -z y -f $case-UNI -o $structural/$case/ $dicoms/$case/*mp2rage_mark_ipat3_0.80mm_UNI_Images

#convert INV2
#dcm2niix_afni -b y -z y -f $case-INV2 -o $structural/$case/ $dicoms/$case/*mp2rage_mark_ipat3_0.80mm_INV2

#######################################################################################################
## STRUCTURAL BRAIN MASKING ##
echo "### STRUCTURAL BRAIN MASKING ###"
#note: This is about to be deprecated (to be replaced with hdBET)

if [ $scantype == "Terra" ]
then
   #create initial mask with BET using INV2 image
   echo "create initial mask with BET using INV2 image"
   bet $niftis/$case/*INV2.nii.gz $structural/$case/structural/$case-bet -m -f 0.2 #binary, low fractional intensity threshold
   mv -f $structural/$case/structural/$case-bet.nii.gz $logdir/$case-bet.nii.gz #move mask created above to log

   #generate final brain mask
   echo "generate final brain mask"
   fslmaths $niftis/$case/*UNI_Images.nii.gz -mul $structural/$case/structural/${case}-bet_mask.nii.gz $structural/$case/structural/$case-UNI_masked1.nii.gz
   mv -f $structural/$case/structural/${case}-bet_mask.nii.gz $logdir/${case}-bet_mask.nii.gz

   fslmaths $structural/$case/structural/$case-UNI_masked1.nii.gz -bin $structural/$case/structural/$case-mask_bin.nii.gz
   fslmaths $structural/$case/structural/$case-mask_bin.nii.gz -ero -kernel sphere 1 $structural/$case/structural/$case-UNI-mask-er.nii.gz
   mv -f $structural/$case/structural/$case-mask_bin.nii.gz $logdir/$case-mask_bin.nii.gz

   #Apply finalized eroded mask to UNI & INV2 images
   echo "Apply finalized eroded mask to UNI & INV2 images"
   fslmaths $structural/$case/structural/$case-UNI_masked1.nii.gz -mas $structural/$case/structural/$case-UNI-mask-er.nii.gz $structural/$case/structural/$case-UNI-masked.nii.gz
   fslmaths $niftis/$case/*INV2.nii.gz -mas $structural/$case/structural/$case-UNI-mask-er.nii.gz $structural/$case/structural/$case-INV2-masked.nii.gz
elif [ $scantype == "ONM" ]
then
# create mask with bet
   echo "create initial mask with BET using mprage image"
   mprage_file=$niftis/$case/*mprage.nii.gz 
   bet $mprage_file $structural/$case/structural/$case-bet -m -f 0.2
   mv -f $structural/$case/structural/$case-bet.nii.gz $logdir/$case-bet.nii.gz

   # apply the mask to the mprage
   echo "generate final brain mask"
   mprage_file=$niftis/$case/$subdirs/*mprage.nii.gz 
   fslmaths $mprage_file -mul $structural/$case/structural/$case-bet_mask.nii.gz $structural/$case/structural/$case-mprage_masked1.nii.gz
   mv -f $structural/$case/structural/$case-bet_mask.nii.gz $logdir/$case-bet_mask.nii.gz 

   # binarize the masked brain
   fslmaths $structural/$case/structural/$case-mprage_masked1.nii.gz -bin $structural/$case/structural/$case-mask_bin.nii.gz
   # erode the binarized mask
   fslmaths $structural/$case/structural/$case-mask_bin.nii.gz -ero -kernel sphere 1 $structural/$case/structural/$case-mprage-mask-er.nii.gz
   mv -f $structural/$case/structural/$case-mask_bin.nii.gz $logdir/$case-mask_bin.nii.gz

   # only apply once to mprage
   echo "apply finalized eroded mask to mprage image"
   fslmaths $structural/$case/structural/$case-mprage_masked1.nii.gz -mas $structural/$case/structural/$case-mprage-mask-er.nii.gz $structural/$case/structural/$case-mprage-masked.nii.gz
   # fslmaths $mprage_file -mas $structural/$participant/$session/$participant-$session-mprage-mask-er.nii.gz $structural/$participant/$session/$participant-$session-mprage-masked.nii.gz
fi
#######################################################################################################
## BIAS FIELD CORRECTION ##
echo "## BIAS FIELD CORRECTION ##"

if [ $scantype == "Terra" ]
then
N4BiasFieldCorrection -d 3 \
	-i $structural/$case/structural/$case-UNI-masked.nii.gz \
	-o $structural/$case/structural/$case-UNI-processed.nii.gz \
	-x $structural/$case/structural/$case-UNI-mask-er.nii.gz
N4BiasFieldCorrection -d 3 \
	-i $structural/$case/structural/$case-INV2-masked.nii.gz \
	-o $structural/$case/structural/$case-INV2-processed.nii.gz \
	-x $structural/$case/structural/$case-UNI-mask-er.nii.gz #UNI mask
elif [ $scantype == "ONM" ]
then
N4BiasFieldCorrection -d 3 \
	-i $structural/$case/structural/$case-mprage-masked.nii.gz \
	-o $structural/$case/structural/$case-mprage-processed.nii.gz \
	-x $structural/$case/structural/$case-mprage-mask-er.nii.gz
fi
#######################################################################################################
## FAST TISSUE SEGMENTATION ##
echo "## FAST TISSUE SEGMENTATION ##"
#note: This is about to be deprecated (replaced with Choi et al paper method or FAST&FIRST)

if [ $scantype == "Terra" ]
then
fast -n 3 -t 1 -g -p -o $structural/$case/structural/fast/$case $structural/$case/structural/$case-INV2-processed.nii.gz
elif [ $scantype == "ONM" ]
then
fast -n 3 -t 1 -g -p -o $structural/$case/structural/fast/$case $structural/$case/structural/$case-mprage-processed.nii.gz
fi
#######################################################################################################
## UNI TO MNI152 0.8MM BRAIN REGISTRATION ##
echo "## UNI TO MNI152 0.8MM BRAIN REGISTRATION ##"

if [ $scantype == "Terra" ]
then
#register processed UNI to upsampled MNI T1 template
# MNI152 T1 1mm template was upsampled to match UNI voxel resolution: ResampleImage 3 MNI152_T1_1mm_brain.nii.gz MNI152_T1_0.8mm_brain.nii.gz 0.8223684430X0.8223684430X0.8199999928 0 4
antsRegistrationSyN.sh -d 3 -f $templates/MNI152_T1_0.8mm_brain.nii.gz -m $structural/$case/structural/$case-UNI-processed.nii.gz -o $structural/$case/structural/MNI_transforms/$case-UNIinMNI-
elif [ $scantype == "ONM" ]
then
antsRegistrationSyN.sh -d 3 -f $templates/MNI152_T1_0.8mm_brain.nii.gz -m $structural/$case/structural/$case-mprage-processed.nii.gz -o $structural/$case/structural/MNI_transforms/$case-mprageinMNI-
fi
#######################################################################################################
#clean up

mv $structural/$case/structural/*.log  $logdir/

if ([ -f $structural/$case/structural/MNI_transforms/$case-mprageinMNI-Warped.nii.gz ] \
	&& [ -f $structural/$case/structural/fast/${case}_seg.nii.gz ]) \
   || ([ -f $structural/$case/structural/MNI_transforms/$case-UNIinMNI-Warped.nii.gz ] \
	&& [ -f $structural/$case/structural/fast/${case}_seg.nii.gz ])
then	
	echo -e "\n$case SUCCESFULLY PROCESSED.\n\n\n"
else
	echo -e "\n$case seems to have some issues.\n\n\n"
fi
} | tee "$logfile"
