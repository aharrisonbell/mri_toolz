#!/bin/bash
# @HPA_IdentifyTargetROIs.sh
# by AHB, June 2014
version="1.17-06-2014"
# Basic script to allow volumes with different matrices to be viewed in FSL
# Uses AFNI tools to resample dataset
# Set defaults:
coeff="0.30"
vmul="100"
maskThr="0.30"
if [[ $# -ne 1 ]]; then
	echo " "
	echo "@HPA_SeedToVoxel_Masks.sh by AHB, V"$version
	echo " "
	echo "Resamples INPUT to match matrix size of MASTER."
	echo "Creates new volume called OUTPUT"
	echo " "
	echo "INPUT: @ResampleFSL.sh <INPUT> <MASTER> <OUTPUT>"
	echo " "
else
	MASK_DIR="$1"
	cd ~/Documents/_Current_Projects/HPA_Study/matlab_dataAvgSeedToVoxel/${MASK_DIR}
	outDIR=~/Documents/_Current_Projects/HPA_Study/matlab_data/TargetROIs/${MASK_DIR}
	mkdir -p $outDIR 
	







echo "Threshold the standard masks..."
	for volume in AvgWin1_zC_RsThr05 AvgWin2_zC_RsThr05; do
		rm -f ${volume}Mrg*
		3dmerge -prefix ${volume}Mrg -1clust 0 $vmul -1clip $coeff ${volume}.nii.gz
		3dAFNItoNIFTI ${volume}Mrg+tlrc.
		rm -f ${volume}Mrg+tlrc.*
		cd ../stdMasks
		numMasks=0
		numRejects=0
		for mask in *.nii.gz; do
			echo "Masking by "${mask}
			numMasks=$[numMasks + 1]
			# Need to threshold mask
			fslmaths ${mask} -thr $maskThr tempmask
			fslmaths ${outDIR}/${volume}Mrg.nii -mas tempmask.nii.gz ${outDIR}/maskClusters/${volume}Mrg_${mask%%$'.nii.gz'}
			rm tempmask.nii.gz
			
			# Check to see if volume is empty
			cp ${outDIR}/maskClusters/${volume}Mrg_${mask} tempvol.nii.gz
			fslmaths tempvol.nii.gz -div tempvol.nii.gz tempvol2.nii.gz			
			fslstats tempvol2.nii.gz -R > temp.txt
			read minVal maxVal < <(more temp.txt)
			if [[ $maxVal < 1 ]]; then
				echo "...Volume is empty.  Removing it..."
				#echo ${outDIR}/maskClusters/${volume}Mrg_${mask}
				rm -f ${outDIR}/maskClusters/${volume}Mrg_${mask}
				numRejects=$[numRejects + 1]
			fi	
			rm temp.txt tempvol.nii.gz tempvol2.nii.gz
		done
		cd $outDIR
	done	
	echo "Number of masks used: "$numMasks
	echo "Number of masks rejected: "$numRejects
fi
