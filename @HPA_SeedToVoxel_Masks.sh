#!/bin/bash
# @HPA_SeedToVoxel_Masks
# by AHB, June 2014
version="1.13-06-2014"
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
# 	MASK_DIR="$1"
# 	cd $MASK_DIR
# 	echo "Threshold the standard masks..."
# 	fslmaths ../stdMasks/rwLobes_01_MedialWall_L.nii -thr ${maskThr} ../stdMasks/mskThr_LmedWall
# 	fslmaths ../stdMasks/rwLobes_01_MedialWall_R.nii -thr ${maskThr} ../stdMasks/mskThr_RmedWall
# 	fslmaths ../stdMasks/rwLobes_04_Parietal_L.nii -thr ${maskThr} ../stdMasks/mskThr_Lparietal
# 	fslmaths ../stdMasks/rwLobes_04_Parietal_R.nii -thr ${maskThr} ../stdMasks/mskThr_Rparietal
# 	fslmaths ../stdMasks/rwLobes_05_Frontal_L.nii -thr ${maskThr} ../stdMasks/mskThr_Lfrontal
# 	fslmaths ../stdMasks/rwLobes_05_Frontal_R.nii -thr ${maskThr} ../stdMasks/mskThr_Rfrontal
# 	fslmaths ../stdMasks/rwLobes_06_medialTemporal_L.nii -thr ${maskThr} ../stdMasks/mskThr_LmedTemp
# 	fslmaths ../stdMasks/rwLobes_06_medialTemporal_R.nii -thr ${maskThr} ../stdMasks/mskThr_RmedTemp
# 	fslmaths ../stdMasks/rwLobes_07_Temporal_L.nii -thr ${maskThr} ../stdMasks/mskThr_Ltemporal
# 	fslmaths ../stdMasks/rwLobes_07_Temporal_R.nii -thr ${maskThr} ../stdMasks/mskThr_Rtemporal
# 	fslmaths ../stdMasks/rwLobes_08_Occipital_L.nii -thr ${maskThr} ../stdMasks/mskThr_Loccipital
# 	fslmaths ../stdMasks/rwLobes_08_Occipital_R.nii -thr ${maskThr} ../stdMasks/mskThr_Roccipital
# 		
# 	for volume in AvgWin1_zC_RsThr05 AvgWin2_zC_RsThr05; do
# 		for hemi in L R; do
# 			for mask in medWall parietal frontal medTemp temporal occipital
# 			do
# 			echo "Separate the data according to lobe and hemisphere..."
# 				rm -f ${volume}_${hemi}${mask}_rois+tlrc.*
# 				rm -f ${volume}_${hemi}${mask}_rois.nii*
# 				fslmaths $volume -mas ../stdMasks/mskThr_${hemi}${mask}.nii ${volume}_${hemi}${mask}
# 				3dmerge -prefix ${volume}_${hemi}${mask}_rois -1clust_order 0 $vmul -1clip $coeff ${volume}_${hemi}${mask}.nii.gz
# 				3dAFNItoNIFTI ${volume}_${hemi}${mask}_rois+tlrc.
# 			done
# 		done
# 		rm -f *+tlrc.*
# 		gzip *nii
# 	done
# fi


# OR DIFFERENT METHOD
	MASK_DIR="$1"
	cd $MASK_DIR
	outDIR=$PWD
	echo "Threshold the standard masks..."
	mkdir -p  ${outDIR}/maskClusters
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
