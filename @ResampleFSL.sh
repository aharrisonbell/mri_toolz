#!/bin/bash
# @ResampleFSL
# by AHB, June 2014
version="1.13-06-2014"
# Basic script to allow volumes with different matrices to be viewed in FSL
# Uses AFNI tools to resample dataset

if [[ $# -ne 3 ]]
then
	echo " "
	echo "@ResampleFSL.sh by AHB, V"$version
	echo " "
	echo "Resamples INPUT to match matrix size of MASTER."
	echo "Creates new volume called OUTPUT"
	echo " "
	echo "INPUT: @ResampleFSL.sh <INPUT> <MASTER> <OUTPUT>"
	echo " "
else
	INPUT="$1"
	MASTER="$2"
	OUTPUT="$3"
	
	echo "Extracting ROI "$mask_num
	3dresample -master $MASTER -inset $INPUT -prefix $OUTPUT
	3dAFNItoNIFTI ${OUTPUT}+tlrc.
	gzip ${OUTPUT}.nii	
	rm -f ${OUTPUT}+tlrc.*
fi