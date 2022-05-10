#!/bin/bash

#pull CEST preprocessed in matlab and structural data to `bbl_roalf_cest_predict` project

#######################################################################################################
## DEFINE PATHS ##
source=/project/bbl_roalf_cest_dti/CEST
dest=/project/bbl_roalf_cest_predict/data/data.pull
datalist=/project/bbl_roalf_cest_predict/data/data.pull/datalist.txt
#######################################################################################################

while read var; do
    sub="${var%/*}"
    ses="${var#*/}"
    #mkdir $dest/$sub_ses
    mkdir $dest/$sub
    #mkdir $dest/$sub/$ses
    datapath=$(find $source/*/$sub `pwd -P` -maxdepth 4 -type d -name $ses)
    #echo $datapath
    rsync -rh $datapath $dest/$sub
    #echo $sub_ses
done < $datalist