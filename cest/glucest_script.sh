#!/bin/bash

#This script post-processes GluCEST data output by Matlab GUI using structural data from structural_script-ML.sh.
# Updated by MG from script post-processing Matlab cest2d_TERRA_SYRP, copied MG from `/project/bbl_roalf_syrp/sandbox/sydnor_pmacsv/scripts` Jan 2022. 
# This script requires that:
#1. The structural_script-ML.sh has been run
#2. The CEST data has been processed via the Matlab GUI cest2d_TERRA_SYRP and outputs converted to nifti format

#The processing pipeline includes:
#B0 and B1 map thresholding of GluCEST images
#CSF removal from GluCEST images  
#GluCEST brain (re)masking
#registration of atlases from MNI space to participant UNI or MPRAGE images
#registration of FAST segmentation to GluCEST images
#generation HarvardOxford cortical and subcortical masks
#######################################################################################################
#INPUTS: 
   #GUI CEST niftis ($cest/$case/*-B0map.nii, $cest/$case/*-B1map.nii & $cest/$case/*-B0B1CESTmap.nii)
   #FAST segmentations of structural images from structural_script-ML.sh
      # 3-part segmentation ($outputs/$case/structural/fast/${case}_seg.nii.gz)
      # GM segmentation ($outputs/$case/structural/fast/${case}_seg_1.nii.gz)
#OUTPUTS:
  #FAST 3-part segmentation in 2D CEST slab ($outputs/$case/fast/$case-2d-FAST.nii)
  #GM mask in 2D CEST slab ($outputs/$case/fast/$case-2d-FASTGMseg.nii)
  #non-CSF segmentation ($outputs/$case/fast/$case-tissuemap-bin.nii.gz)
  #non-CSF mask ($outputs/$case/fast/$case-tissuemap-bin.nii.gz)
  #thresholded, brain-masked and CSF-excluded GluCEST image ($outputs/$case/$case-GluCEST.nii.gz)
  #Harvard Cortical and Subcortical Atlases transformed into native space of CEST slab w/ CSF removed ($outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii.gz)
#######################################################################################################
## HELPFUNCTION ##
helpFunction()
{
   echo ""
   echo "Usage: $0 -c cest -o outputs -m templates -p case -t scantype -l logdir"
   echo -e "\t-c Path to preprocessed GluCEST inputs"
   echo -e "\t-o Path to structural and GluCEST postprocessing output directory"
   echo -e "\t-m Path to MNI templates directory"
   echo -e "\t-p Case (BBLID_ScanSession)"
   echo -e "\t-t Scanner Type ('ONM' or 'Terra')"
   echo -e "\t-l Path to log subdirectory"
   exit 1 # Exit script after printing help
}
while getopts "c:o:m:p:t:l:" opt
do
   case "$opt" in
	c ) cest="$OPTARG" ;;
	o ) outputs="$OPTARG" ;;
   m ) templates="$OPTARG" ;;
	p ) case="$OPTARG" ;;
   t ) scantype="$OPTARG" ;;
   l ) logdir="$OPTARG" ;;
   ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$cest" ] || [ -z "$outputs" ] || [ -z "$templates" ] || [ -z "$case" ] || [ -z "$scantype" ] || [ -z "$logdir" ]
then
   echo "Some or all of the arguments are empty";
   helpFunction
fi
#######################################################################################################
## INITALIZE LOGFILE ##
logfile=$logdir/${case}_glucest_script.log
(
echo "--------Processing GluCEST data for $case---------" 
sleep 1.5
echo "CEST Inputs: $cest"
echo "Outputs from structural_script-ML.sh and CEST Outputs: $outputs"
echo "MNI templates: $templates"
echo "Case: $case"
echo "Scanner: $scantype"
#######################################################################################################
## THRESHOLD B0 AND B1 MAPS ##
echo "## THRESHOLD B0 AND B1 MAPS ##"
#threshold b0 from -1 to 1 ppm (relative to water resonance)
fslmaths $cest/$case/*-B0map.nii -add 10 $outputs/$case/$case-B0MAP-pos.nii.gz # make B0 map values positive to allow for thresholding with fslmaths
fslmaths $outputs/$case/$case-B0MAP-pos.nii.gz -thr 9 -uthr 11 $outputs/$case/$case-B0MAP-thresh.nii.gz #threshold from -1(+10=9) to 1(+10=11)
fslmaths $outputs/$case/$case-B0MAP-thresh.nii.gz -bin $outputs/$case/$case-b0.nii.gz #binarize thresholded B0 map
#threshold b1 from 0.3 to 1.3
fslmaths $cest/$case/*-B1map.nii -thr 0.3 -uthr 1.3 $outputs/$case/$case-B1MAP-thresh.nii.gz #threshold from 0.3 to 1.3
fslmaths $outputs/$case/$case-B1MAP-thresh.nii.gz -bin $outputs/$case/$case-b1.nii.gz #binarize thresholded B1 map
#######################################################################################################
## ALIGN FSL FAST OUTPUT TO GLUCEST IMAGES ##
echo "## ALIGN FSL FAST OUTPUT TO GLUCEST IMAGES ##"
#check after running structural script to make sure that ONM vs Terra branching isn't needed in this chunk

/project/bbl_projects/apps/melliott/scripts/extract_slice2.sh -MultiLabel $outputs/$case/structural/fast/${case}_seg.nii.gz $cest/$case/*-B0B1CESTmap.nii $outputs/$case/fast/$case-2d-FAST.nii
gzip $outputs/$case/fast/$case-2d-FAST.nii  #FAST 3-part segmentation in 2D CEST slab (no partial volumes or probabilities, just segmentation 1 - 3 segmentation)
/project/bbl_projects/apps/melliott/scripts/extract_slice2.sh $outputs/$case/structural/fast/${case}_seg_1.nii.gz $cest/$case/*-B0B1CESTmap.nii $outputs/$case/fast/$case-2d-FASTGMseg.nii
gzip $outputs/$case/fast/$case-2d-FASTGMseg.nii #GM mask in 2D CEST slab
#######################################################################################################
## APPLY THRESHOLDED B0 MAP, B1 MAP, and TISSUE MAP (CSF removed) TO GLUCEST IMAGES ##
echo "## APPLY THRESHOLDED B0 MAP, B1 MAP, and TISSUE MAP (CSF removed) TO GLUCEST IMAGES ##"
#exclude voxels with B0 offset greater than +- 1 pmm from GluCEST images
fslmaths $cest/$case/*-B0B1CESTmap.nii -mul $outputs/$case/$case-b0.nii.gz $outputs/$case/$case-CEST_b0thresh.nii.gz
#exclude voxels with B1 values outside the range of 0.3 to 1.3 from GluCEST images
fslmaths $outputs/$case/$case-CEST_b0thresh.nii.gz -mul $outputs/$case/$case-b1.nii.gz $outputs/$case/$case-CEST_b0b1thresh.nii.gz
#exclude CSF voxels from GluCEST images
fslmaths $outputs/$case/fast/$case-2d-FAST.nii.gz -thr 2 $outputs/$case/fast/$case-tissuemap.nii.gz
fslmaths $outputs/$case/fast/$case-tissuemap.nii.gz -bin $outputs/$case/fast/$case-tissuemap-bin.nii.gz #make non-CSF mask from FAST segmentation
fslmaths $outputs/$case/$case-CEST_b0b1thresh.nii.gz -mul $outputs/$case/fast/$case-tissuemap-bin.nii.gz $outputs/$case/$case-CEST-finalthresh.nii.gz #apply non-CSF mask - ALSO skull-strips ONM CEST images!!!
#######################################################################################################
## MASK THE PROCESSED GLUCEST IMAGE ##
echo "## MASK THE PROCESSED GLUCEST IMAGE ##"
fslmaths $cest/$case/*-B1map.nii -bin $outputs/$case/CEST-masktmp.nii.gz
fslmaths $outputs/$case/CEST-masktmp.nii.gz -ero -kernel sphere 1 $outputs/$case/CEST-masktmp-er1.nii.gz #ero: Erode by zeroing non-zero voxels when zero voxels found in kernel
fslmaths $outputs/$case/CEST-masktmp-er1.nii.gz -ero -kernel sphere 1 $outputs/$case/CEST-masktmp-er2.nii.gz
fslmaths $outputs/$case/CEST-masktmp-er2.nii.gz -ero -kernel sphere 1 $outputs/$case/$case-CEST-mask.nii.gz
fslmaths $outputs/$case/$case-CEST-finalthresh.nii.gz -mul $outputs/$case/$case-CEST-mask.nii.gz $outputs/$case/$case-GluCEST.nii.gz #final processed GluCEST Image
#######################################################################################################
#clean up and organize, whistle while you work 
## check this!!!
echo "clean up and organize"
mv -f $outputs/$case/*masktmp* $logdir
mv -f $outputs/$case/$case-B0MAP-pos.nii.gz $logdir/$case-b0MAP-pos.nii.gz
mv -f $outputs/$case/$case-B0MAP-thresh.nii.gz $logdir/$case-B0MAP-thresh.nii.gz
mv -f $outputs/$case/$case-B1MAP-thresh.nii.gz $logdir/$case-B1MAP-thresh.nii.gz

cp $cest/$case/*-B0map.nii $cest/$case/*-B1map.nii $cest/$case/*-B0B1CESTmap.nii $outputs/$case/orig_data
#######################################################################################################
## REGISTER MNI HARVARD OXFORD ATLAS TO UNI IMAGES OR MPRAGE AND GLUCEST IMAGES ##
echo "## REGISTER MNI HARVARD OXFORD ATLAS TO STRUCT AND GLUCEST IMAGES ##"
#note: preserve native space as much as possible b/c 2D! moving object gets smoothed
## - copied from Joelle B's scripts 03_cest_postproc_terra_glucest.sh

#Harvard Oxford Atlases
for atlas in cort sub
do
    if [ $scantype == "Terra" ]
    then
    antsApplyTransforms -d 3 -r $outputs/$case/structural/$case-UNI-masked.nii.gz -i $templates/HarvardOxford-$atlas-maxprob-thr25-0.8mm.nii.gz -n MultiLabel -o $outputs/$case/structural/atlases/$case-HarvardOxford-$atlas.nii.gz  -t [$outputs/$case/structural/MNI_transforms/$case-UNIinMNI-0GenericAffine.mat,1] -t $outputs/$case/structural/MNI_transforms/$case-UNIinMNI-1InverseWarp.nii.gz
    /project/bbl_projects/apps/melliott/scripts/extract_slice2.sh -MultiLabel $outputs/$case/structural/atlases/$case-HarvardOxford-$atlas.nii.gz $cest/$case/*-B0B1CESTmap.nii $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii
    gzip $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii
    fslmaths $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii.gz -mul $outputs/$case/fast/$case-tissuemap-bin.nii.gz $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii.gz
    elif [ $scantype == "ONM" ]
    then
    antsApplyTransforms -d 3 -r $outputs/$case/structural/$case-mprage-masked.nii.gz -i $templates/HarvardOxford-$atlas-maxprob-thr25-0.8mm.nii.gz -n MultiLabel -o $outputs/$case/structural/atlases/$case-HarvardOxford-$atlas.nii.gz  -t [$outputs/$case/structural/MNI_transforms/$case-mprageinMNI-0GenericAffine.mat,1] -t $outputs/$case/structural/MNI_transforms/$case-mprageinMNI-1InverseWarp.nii.gz
    /project/bbl_projects/apps/melliott/scripts/extract_slice2.sh -MultiLabel $outputs/$case/structural/atlases/$case-HarvardOxford-$atlas.nii.gz $cest/$case/*-B0B1CESTmap.nii $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii
    gzip $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii
    fslmaths $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii.gz -mul $outputs/$case/fast/$case-tissuemap-bin.nii.gz $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii.gz
    fi
done
#inverse matrix brings things back to native space 
#######################################################################################################


# checking that some output files exist (if prior steps exited with errors, these files do not exist)
if [ -f $outputs/$case/$case-GluCEST.nii.gz ] \
	&& [ -f $outputs/$case/atlases/$case-2d-HarvardOxford-$atlas.nii.gz ]
then	
	echo -e "\n$case SUCCESFULLY PROCESSED.\n\n\n"
else
	echo -e "\n$case seems to have some issues.\n\n\n"
fi

)  | tee "$logfile"
