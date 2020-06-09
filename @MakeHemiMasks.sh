#!/bin/bash
# @MakeHemiMasks.sh
# by AHB, May 2014
#set verbose # for debugging purposes
version="1.19-05-2014"
# Script to take one F99-aligned mask into one per hemisphere

mkdir -p ./HemiMasks
				
for mask in *_Both.nii
do
	echo "Making LEFT/RIGHT masks for "$mask
	newname="${mask%%Both.*}"
	fslmaths $mask -mas Caret_left_hemisphere.nii.gz ./HemiMasks/${newname}L
	fslmaths $mask -mas Caret_right_hemisphere.nii.gz ./HemiMasks/${newname}R

done
