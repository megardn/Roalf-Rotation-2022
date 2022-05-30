#!/bin/bash

#######################################################################################################
##DEFINE PATHS## SANDBOX!!!
inputs=/project/bbl_roalf_cest_predict/data/outputs #path to processed GluCEST data from glucest_script.sh
outputpath=/project/bbl_roalf_cest_predict/data/cest_values
log_file=/project/bbl_roalf_cest_predict/logs/cest_extract_test.log
#######################################################################################################

#mkdir $outputpath

for i in $(ls $inputs)
do
    case=${i##*/}
    #mkdir $outputpath/$case

##HARVARD OXFORD SUBCORTICAL ATLAS MEASURE EXTRACTION##
echo "## $case HARVARD OXFORD SUBCORTICAL ATLAS MEASURE EXTRACTION##"
    #Create output measures csv
    if [ ! -f $outputpath/GluCEST-HarvardOxford-Subcortical-Measures.csv ]
    then
    touch $outputpath/GluCEST-HarvardOxford-Subcortical-Measures-hdrtest.csv
	touch $outputpath/GluCEST-HarvardOxford-Subcortical-Measures-datatest.csv
echo "Subject	L_CerebralWM_mean	L_CerebralWM_numvoxels	L_CerebralWM_SD	L_CerebralCortex_mean	L_CerebralCortex_numvoxels	L_CerebralCortex_SD	L_LatVent_mean	L_LatVent_numvoxels	L_LatVent_SD	L_Thalamus_mean	L_Thalamus_numvoxels	L_Thalamus_SD	L_Caudate_mean	L_Caudate_numvoxels	L_Caudate_SD	L_Putamen_mean	L_Putamen_numvoxels	L_Putamen_SD	L_Pallidum_mean	L_Pallidum_numvoxels	L_Pallidum_SD	BrainStem_mean	BrainStem_numvoxels	Brainstem_SD	L_Hipp_mean	L_Hipp_numvoxels	L_Hipp_SD	L_Amygdala_mean	L_Amygdala_numvoxels	L_Amygdala_SD	L_Accumbens_mean	L_Accumbens_numvoxels	L_Accumbens_SD	R_CerebralWM_mean	R_CerebralWM_numvoxels	R_CerebralWM_SD	R_CerebralCortex_mean	R_CerebralCortex_numvoxels	R_CerebralCortex_SD	R_LatVent_mean	R_LatVent_numvoxels	R_LatVent_S	R_Thalamus_mean	R_Thalamus_numvoxels	R_Thalamus_SD	R_Caudate_mean	R_Caudate_numvoxels	R_Caudate_SD	R_Putamen_mean	R_Putamen_numvoxels	R_Putamen_SD	R_Pallidum_mean	R_Pallidum_numvoxels	R_Pallidum_SD	R_Hipp_mean	R_Hipp_numvoxels	R_Hipp_SD	R_Amygdala_mean	R_Amygdala_numvoxels	R_Amygdala_SD	R_Accumbens_mean	R_Accumbens_numvoxels	R_Accumbens_SD" >> $outputpath/GluCEST-HarvardOxford-Subcortical-Measures-hdrtest.csv
    fi
    
    if ! [ -e $log_file ]
    then
    touch $log_file
    fi

        #Enter data into study output measures csv
        sed -n 'p' $outputpath/$case/$case-HarvardOxford-Subcortical-GluCEST-measures.csv >> $outputpath/GluCEST-HarvardOxford-Subcortical-Measures-datatest.csv

###Harvard Oxford Subcortical: GM Mask###
#echo "## $case HARVARD OXFORD SUBCORTICAL GM MEASURE EXTRACTION##"

        #if [ -e $outputpath/GMDensity-HarvardOxford-Subcortical-Measures.csv ]
            #then
            #rm $outputpath/GMDensity-HarvardOxford-Subcortical-Measures.csv
        #fi
    #Create output measures csv
    #if [ ! -f $outputpath/GMDensity-HarvardOxford-Subcortical-Measures.csv ]
    #then
    #touch $outputpath/GMDensity-HarvardOxford-Subcortical-Measures.csv
    #echo "Subject	L_CerebralWM_mean	L_CerebralWM_numvoxels	L_CerebralWM_SD	L_CerebralCortex_mean	L_CerebralCortex_numvoxels	L_CerebralCortex_SD	L_LatVent_mean	L_LatVent_numvoxels	L_LatVent_SD	L_Thalamus_mean	L_Thalamus_numvoxels	L_Thalamus_SD	L_Caudate_mean	L_Caudate_numvoxels	L_Caudate_SD	L_Putamen_mean	L_Putamen_numvoxels	L_Putamen_SD	L_Pallidum_mean	L_Pallidum_numvoxels	L_Pallidum_SD	BrainStem_mean	BrainStem_numvoxels	Brainstem_SD	L_Hipp_mean	L_Hipp_numvoxels	L_Hipp_SD	L_Amygdala_mean	L_Amygdala_numvoxels	L_Amygdala_SD	L_Accumbens_mean	L_Accumbens_numvoxels	L_Accumbens_SD	R_CerebralWM_mean	R_CerebralWM_numvoxels	R_CerebralWM_SD	R_CerebralCortex_mean	R_CerebralCortex_numvoxels	R_CerebralCortex_SD	R_LatVent_mean	R_LatVent_numvoxels	R_LatVent_SD	R_Thalamus_mean	R_Thalamus_numvoxels	R_Thalamus_SD	R_Caudate_mean	R_Caudate_numvoxels	R_Caudate_SD	R_Putamen_mean	R_Putamen_numvoxels	R_Putamen_SD	R_Pallidum_mean	R_Pallidum_numvoxels	R_Pallidum_SD	R_Hipp_mean	R_Hipp_numvoxels	R_Hipp_SD	R_Amygdala_mean	R_Amygdala_numvoxels	R_Amygdala_SD	R_Accumbens_mean	R_Accumbens_numvoxels	R_Accumbens_SD" >> $outputpath/GMDensity-HarvardOxford-Subcortical-Measures.csv
    #fi

        #Enter data into study output measures csv
        #sed -n '2p' $outputpath/$case/$case-HarvardOxford-Subcortical-GMDensity-measures.csv >> $outputpath/GMDensity-HarvardOxford-Subcortical-Measures.csv

done

#######################################################################################################
