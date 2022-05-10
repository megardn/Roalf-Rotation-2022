#!/bin/bash

#######################################################################################################
##DEFINE PATHS##
inputs=/project/bbl_roalf_cest_predict/data/outputs #path to processed GluCEST data from cest_postproc_..._glucest.sh
outputpath=/project/bbl_roalf_cest_predict/data/outputs/cest_values
#######################################################################################################

mkdir $outputpath

##HARVARD OXFORD SUBCORTICAL ATLAS MEASURE EXTRACTION##
echo "##HARVARD OXFORD SUBCORTICAL ATLAS MEASURE EXTRACTION##"
    if [ -e $inputs/$case/GluCEST-HarvardOxford-Subcortical-Measures.csv ]
    then
    rm $outputpath/GluCEST-HarvardOxford-Subcortical-Measures.csv
    fi

    #Create output measures csv
        touch $outputpath/GluCEST-HarvardOxford-Subcortical-Measures.csv
        echo "Subject	Frontal_Pole_mean	Frontal_Pole_numvoxels	Frontal_Pole_SD" >> $outputpath/GluCEST-HarvardOxford-Cortical-Measures.csv

        #Extract subject measures for each GM ROI in GluCEST image (3dROIstats = AFNI command)
        3dROIstats -mask $cest/$participant/$session/atlases/$case-2d-HarvardOxford-cort.nii.gz -numROI 48 -zerofill NaN -nomeanout -nzmean -nzsigma -nzvoxels -nobriklab -1DRformat $cest/$participant/$session/$case-GluCEST.nii.gz >> $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GluCEST-measures.csv

        #Format subject csvs
        sed -i 's/name/Subject/g' $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GluCEST-measures.csv
        cut -f2-3 --complement $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GluCEST-measures.csv >> $outputpath/$participant/$session/tmp.csv
        mv $outputpath/$participant/$session/tmp.csv $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GluCEST-measures.csv

        #Enter data into study output measures csv
        sed -n "2p" $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GluCEST-measures.csv >> $outputpath/GluCEST-HarvardOxford-Cortical-Measures.csv

        ###Harvard Oxford Cortical: GM Density###

        if [ -e $outputpath/GMDensity-HarvardOxford-Cortical-Measures.csv ]
            then
            rm $outputpath/GMDensity-HarvardOxford-Cortical-Measures.csv
        fi

        #Create output measures csv
        touch $outputpath/GMDensity-HarvardOxford-Cortical-Measures.csv
        echo "Subject	Frontal_Pole_mean	Frontal_Pole_numvoxels	Frontal_Pole_SD	Insular_Cortex_mean	Insular_Cortex_numvoxels	Insular_Cortex_SD	SFG_mean	SFG_numvoxels	SFG_SD	MFG_mean	MFG_numvoxels	MFG_SD	IFG_parstriangularis_mean	IFG_parstriangularis_numvoxels	IFG_parstriangularis_SD	IFG_parsopercularis_mean	IFG_parsopercularis_numvoxels	IFG_parsopercularis_SD	Precentral_Gyrus_mean	Precentral_Gyrus_numvoxels	Precentral_Gyrus_SD	Temporal_Pole_mean	Temporal_Pole_numvoxels	Temporal_Pole_SD	Superior_Temporal_Gyrus_ant_mean	Superior_Temporal_Gyrus_ant_numvoxels	Superior_Temporal_Gyrus_ant_SD	Superior_Temporal_Gyrus_post_mean	Superior_Temporal_Gyrus_post_numvoxels	Superior_Temporal_Gyrus_post_SD	Middle_Temporal_Gyrus_ant_mean	Middle_Temporal_Gyrus_ant_numvoxels	Middle_Temporal_Gyrus_ant_SD	Middle_Temporal_Gyrus_post_mean	Middle_Temporal_Gyrus_post_numvoxels	Middle_Temporal_Gyrus_post_SD	Middle_Temporal_Gyrus_temporoocc_mean	Middle_Temporal_Gyrus_temporoocc_numvoxels	Middle_Temporal_Gyrus_temporoocc_SD	Inferior_Temporal_Gyrus_ant_mean	Inferior_Temporal_Gyrus_ant_numvoxels	Inferior_Temporal_Gyrus_ant_SD	Inferior_Temporal_Gyrus_post_mean	Inferior_Temporal_Gyrus_post_numvoxels	Inferior_Temporal_Gyrus_post_SD	Inferior_Temporal_Gyrus_temporocc_mean	Inferior_Temporal_Gyrus_temporocc_numvoxels	Inferior_Temporal_Gyrus_temporocc_SD	Postcentral_Gyrus_mean	Postcentral_Gyrus_numvoxels	Postcentral_Gyrus_SD	Superior_Parietal_Lobule_mean	Superior_Parietal_Lobule_numvoxels	Superior_Parietal_Lobule_SD	Supramarginal_Gyrus_ant_mean	Supramarginal_Gyrus_ant_numvoxels	Supramarginal_Gyrus_ant_SD	Supramarginal_Gyrus_post_mean	Supramarginal_Gyrus_post_numvoxels	Supramarginal_Gyrus_post_SD	Angular_Gyrus_mean	Angular_Gyrus_numvoxels	Angular_Gyrus_SD	Lateral_Occipital_Cortex_sup_mean	Lateral_Occipital_Cortex_sup_numvoxels	Lateral_Occipital_Cortex_sup_SD	Lateral_Occipital_Cortex_inf_mean	Lateral_Occipital_Cortex_inf_numvoxels	Lateral_Occipital_Cortex_inf_SD	Intracalcarine_Cortex_mean	Intracalcarine_Cortex_numvoxels	Intracalcarine_Cortex_SD	Frontal_Medial_Cortex_mean	Frontal_Medial_Cortex_numvoxels	Frontal_Medial_Cortex_SD	Juxtapositional_Lobule_Cortex_mean	Juxtapositional_Lobule_Cortex_numvoxels	Juxtapositional_Lobule_Cortex_SD	Subcallosal_Cortex_mean	Subcallosal_Cortex_numvoxels	Subcallosal_Cortex_SD	Paracingulate_Gyrus_mean	Paracingulate_Gyrus_numvoxels	Paracingulate_Gyrus_SD	Anterior_cingulate_mean	Anterior_cingulate_numvoxels	Anterior_cingulate_SD	Posterior_cingulate_mean	Posterior_cingulate_numvoxels	Posterior_cingulate_SD	Precuneous_Cortex_mean	Precuneous_Cortex_numvoxels	Precuneous_Cortex_SD	Cuneal_Cortex_mean	Cuneal_Cortex_numvoxels	Cuneal_Cortex_SD	OFC_mean	OFC_numvoxels	OFC_SD	Parahippocampal_Gyrus_ant_mean	Parahippocampal_Gyrus_ant_numvoxels	Parahippocampal_Gyrus_ant_SD	Parahippocampal_Gyrus_post_mean	Parahippocampal_Gyrus_post_numvoxels	Parahippocampal_Gyrus_post_SD	Lingual_Gyrus_mean	Lingual_Gyrus_numvoxels	Lingual_Gyrus_SD	Temporal_Fusiform_Cortex_ant_mean	Temporal_Fusiform_Cortex_ant_numvoxels	Temporal_Fusiform_Cortex_ant_SD	Temporal_Fusiform_Cortex_post_mean	Temporal_Fusiform_Cortex_post_numvoxels	Temporal_Fusiform_Cortex_post_SD	Temporal_Occipital_Fusiform_Cortex_mean	Temporal_Occipital_Fusiform_Cortex_numvoxels	Temporal_Occipital_Fusiform_Cortex_SD	Occipital_Fusiform_Gyrus_mean	Occipital_Fusiform_Gyrus_numvoxels	Occipital_Fusiform_Gyrus_SD	Frontal_Operculum_Cortex_mean	Frontal_Operculum_Cortex_numvoxels	Frontal_Operculum_Cortex_SD	Central_Opercular_Cortex_mean	Central_Opercular_Cortex_numvoxels	Central_Opercular_Cortex_SD	Parietal_Operculum_Cortex_mean	Parietal_Operculum_Cortex_numvoxels	Parietal_Operculum_Cortex_SD	Planum_Polare_mean	Planum_Polare_numvoxels	Planum_Polare_SD	Heschls_Gyrus_mean	Heschls_Gyrus_numvoxels	Heschls_Gyrus_SD	Planum_Temporale_mean	Planum_Temporale_numvoxels	Planum_Temporale_SD	Supracalcarine_Cortex_mean	Supracalcarine_Cortex_numvoxels	Supracalcarine_Cortex_SD	Occipital_Pole_mean	Occipital_Pole_numvoxels	Occipital_Pole_SD" >> $outputpath/GMDensity-HarvardOxford-Cortical-Measures.csv


        #Extract subject measures
        3dROIstats -mask $cest/$participant/$session/atlases/$case-2d-HarvardOxford-cort.nii.gz -numROI 48 -zerofill NaN -nomeanout -nzmean -nzsigma -nzvoxels -nobriklab -1DRformat $cest/$participant/$session/fast/$case-2d-FASTGMprob.nii.gz >> $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GMDensity-measures.csv


        #Format subject csvs
        sed -i 's/name/Subject/g' $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GMDensity-measures.csv
        cut -f2-3 --complement $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GMDensity-measures.csv >> $outputpath/$participant/$session/tmp.csv
        mv $outputpath/$participant/$session/tmp.csv $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GMDensity-measures.csv

        #Enter data into study output measures csv
        sed -n "2p" $outputpath/$participant/$session/$case-HarvardOxford-Cortical-GMDensity-measures.csv >> $outputpath/GMDensity-HarvardOxford-Cortical-Measures.csv

#######################################################################################################
