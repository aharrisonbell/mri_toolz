#!/bin/bash
# @SplitVolume
# by AHB, May 2014
#set verbose # for debugging purposes
version="1.16-05-2014"
# Script to break apart a single volume into multiple masks

INPUT="$1"
OUTPUT="$2"
total="$3"
mkdir -p ./newMasks
				
for mask_num in $(seq -f "%02g" 1 $total)
do
	echo "Extracting value "$mask_num
	fslmaths $INPUT -thr $mask_num -uthr $mask_num+1 ./newMasks/${OUTPUT}_${mask_num}_Both
	#fslmaths $INPUT -thr $mask_num -uthr $mask_num+1 -mas Caret_left_hemisphere.nii.gz ./newMasks/${OUTPUT}_${mask_num}_L
	#fslmaths $INPUT -thr $mask_num -uthr $mask_num+1 -mas Caret_right_hemisphere.nii.gz ./newMasks/${OUTPUT}_${mask_num}_R

done