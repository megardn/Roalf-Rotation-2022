#!/bin/bash

#This script post-processes GluCEST data output by Matlab GUI using structural data from structural_script-ML.sh.
# Updated by MG from script post-processing Matlab cest2d_TERRA_SYRP, copied MG from `/project/bbl_roalf_syrp/sandbox/sydnor_pmacsv/scripts` Jan 2022. 
# This script requires that:
#1. The MP2RAGE processing script MP2RAGE_Processing_Pipeline.sh has been run (QUESTION what is this?)
#2. The CEST data has been processed via the Matlab GUI cest2d_TERRA_SYRP and output in dicom format


#The processing pipeline includes:
#B0 and B1 map thresholding of GluCEST images
#CSF removal from GluCEST images 
#GluCEST brain masking - now in pyglucest???
#registration of atlases from MNI space to participant UNI images
#registration of FAST segmentation and reward atlas slices to GluCEST images
#generation of reward network anatomical and valence-encoding subcomponent masks
#######################################################################################################
## DEFINE PATHS ##  QUESTION: IDK why what's up with dicom vs structural paths, switching paths over to outputs dir which holds pyGluCEST nifti and structural_script.sh nifti outputs
cest=/project/bbl_roalf_cest_dti/margaret_sandbox/data/outputs #path to processed GluCEST data
structural=$cest/structural_script
log_dir=/project/bbl_roalf_cest_dti/margaret_sandbox/logs
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
logfile=$log_dir/${case}_glucest_script.log
(
echo "--------Processing GluCEST data for $case---------" 
sleep 1.5

#######################################################################################################
## THRESHOLD B0 AND B1 MAPS ##
#threshold b0 from -1 to 1 ppm (relative to water resonance)
fslmaths $cest/$case/$case-B0MAP.nii -add 10 $cest/$case/$case-B0MAP-pos.nii.gz # make B0 map values positive to allow for thresholding with fslmaths
fslmaths $cest/$case/$case-B0MAP-pos.nii.gz -thr 9 -uthr 11 $cest/$case/$case-B0MAP-thresh.nii.gz #threshold from -1(+10=9) to 1(+10=11)
fslmaths $cest/$case/$case-B0MAP-thresh.nii.gz -bin $cest/$case/$case-b0.nii.gz #binarize thresholded B0 map
#threshold b1 from 0.3 to 1.3
fslmaths $cest/$case/$case-B1MAP.nii -thr 0.3 -uthr 1.3 $cest/$case/$case-B1MAP-thresh.nii.gz #threshold from 0.3 to 1.3
fslmaths $cest/$case/$case-B1MAP-thresh.nii.gz -bin $cest/$case/$case-b1.nii.gz #binarize thresholded B1 map
#######################################################################################################
## ALIGN FSL FAST OUTPUT TO GLUCEST IMAGES ##
mkdir $cest/$case/fast
/project/bbl_projects/apps/melliott/scripts/extract_slice2.sh -MultiLabel $structural/$case/fast/${case}_seg.nii.gz $cest/$case/$case-B0B1CESTMAP.nii $cest/$case/fast/$case-2d-FAST.nii
gzip $cest/$case/fast/$case-2d-FAST.nii  
/project/bbl_projects/apps/melliott/scripts/extract_slice2.sh $structural/$case/fast/${case}_prob_1.nii.gz $cest/$case/$case-B0B1CESTMAP.nii $cest/$case/fast/$case-2d-FASTGMprob.nii
gzip $cest/$case/fast/$case-2d-FASTGMprob.nii
#######################################################################################################
## APPLY THRESHOLDED B0 MAP, B1 MAP, and TISSUE MAP (CSF removed) TO GLUCEST IMAGES ##
#exclude voxels with B0 offset greater than +- 1 pmm from GluCEST images
fslmaths $cest/$case/$case-B0B1CESTMAP.nii -mul $cest/$case/$case-b0.nii.gz $cest/$case/$case-CEST_b0thresh.nii.gz
#exclude voxels with B1 values outside the range of 0.3 to 1.3 from GluCEST images
fslmaths $cest/$case/$case-CEST_b0thresh.nii.gz -mul $cest/$case/$case-b1.nii.gz $cest/$case/$case-CEST_b0b1thresh.nii.gz
#exclude CSF voxels from GluCEST images
fslmaths $cest/$case/fast/$case-2d-FAST.nii.gz -thr 2 $cest/$case/fast/$case-tissuemap.nii.gz
fslmaths $cest/$case/fast/$case-tissuemap.nii.gz -bin $cest/$case/fast/$case-tissuemap-bin.nii.gz
fslmaths $cest/$case/$case-CEST_b0b1thresh.nii.gz -mul $cest/$case/fast/$case-tissuemap-bin.nii.gz $cest/$case/$case-CEST-finalthresh.nii.gz
#######################################################################################################
## MASK THE PROCESSED GLUCEST IMAGE ##
fslmaths $cest/$case/$case-B1MAP.nii -bin $cest/$case/CEST-masktmp.nii.gz
fslmaths $cest/$case/CEST-masktmp.nii.gz -ero -kernel sphere 1 $cest/$case/CEST-masktmp-er1.nii.gz
fslmaths $cest/$case/CEST-masktmp-er1.nii.gz -ero -kernel sphere 1 $cest/$case/CEST-masktmp-er2.nii.gz
fslmaths $cest/$case/CEST-masktmp-er2.nii.gz -ero -kernel sphere 1 $cest/$case/$case-CEST-mask.nii.gz
fslmaths $cest/$case/$case-CEST-finalthresh.nii.gz -mul $cest/$case/$case-CEST-mask.nii.gz $cest/$case/$case-GluCEST.nii.gz #final processed GluCEST Image
#######################################################################################################
#clean up and organize, whistle while you work
mv -f $cest/$case/*masktmp* $log_files
mv -f $cest/$case/*log* $log_files
mv -f $cest/$case/$case-B0MAP-pos.nii.gz $log_files/$case-b0MAP-pos.nii.gz
mv -f $cest/$case/$case-B0MAP-thresh.nii.gz $log_files/$case-B0MAP-thresh.nii.gz
mv -f $cest/$case/$case-B1MAP-thresh.nii.gz $log_files/$case-B1MAP-thresh.nii.gz

mkdir $cest/$case/orig_data
mv $cest/$case/$case-B0MAP.nii $cest/$case/$case-B1MAP.nii $cest/$case/$case-B0B1CESTMAP.nii $cest/$case/orig_data
#######################################################################################################
## REGISTER MNI HARVARD OXFORD ATLAS TO UNI IMAGES AND GLUCEST IMAGES preserve native space as much as possible b/c 2D! moving object gets smoothed
## - copied from Joelle B's scripts 03_cest_postproc_terra_glucest.sh
mkdir $cest/$participant/$session/atlases
#Harvard Oxford Atlases
for atlas in cort sub
do
antsApplyTransforms -d 3 -r $structural/$participant/$session/$case-UNI-masked.nii.gz -i $mni_templates/HarvardOxford/HarvardOxford-$atlas-maxprob-thr25-0.8mm.nii.gz -n MultiLabel -o $structural/$participant/$session/atlases/$case-HarvardOxford-$atlas.nii.gz  -t [$structural/$participant/$session/MNI_transforms/$case-UNIinMNI-0GenericAffine.mat,1] -t $structural/$participant/$session/MNI_transforms/$case-UNIinMNI-1InverseWarp.nii.gz
/project/bbl_projects/apps/melliott/scripts/extract_slice2.sh -MultiLabel $structural/$participant/$session/atlases/$case-HarvardOxford-$atlas.nii.gz $niftis/$participant/$session/$subdirs/$case-B0B1CESTmap.nii $cest/$participant/$session/atlases/$case-2d-HarvardOxford-$atlas.nii
gzip $cest/$participant/$session/atlases/$case-2d-HarvardOxford-$atlas.nii
fslmaths $cest/$participant/$session/atlases/$case-2d-HarvardOxford-$atlas.nii.gz -mul $cest/$participant/$session/fast/$case-tissuemap-bin.nii.gz $cest/$participant/$session/atlases/$case-2d-HarvardOxford-$atlas.nii.gz
done
#inverse matrix brings things back to native space 
#######################################################################################################
echo -e "\n$case SUCCESFULLY PROCESSED\n\n\n"
)  | tee "$logfile"
else
echo "$case is either missing data or already processed. Will not process"
sleep 1.5
fi
done

#Question: add measure extraction script? (see old_cest_postproc_neasure_extraction.sh in Joelle B's Scripts dir)