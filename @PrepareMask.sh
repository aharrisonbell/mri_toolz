#!/bin/bash
# @PrepareMask
# by AHB, May 2014
version="1.16-05-2014"

master="StewieHRanat_align2caret"
thres=0.40
# 
# # Step 1 - Convert and reorient native space T1
# 3dAFNItoNIFTI $master
# fslreorient2std StewieHRanat_align2caret.nii StewieHRanat_align2caret_reorient2std
# 
# # Step 2 - Resample individual category masks to native space dimensions
# master="StewieHRanat_align2caret"
# mkdir -p temp
# 3dresample -master StewieHRanat_align2caret_reorient2std.nii.gz -rmode NN \
# 	-prefix ./temp/faces_resample -inset Faces_align2caret_Both+orig.
# 3dresample -master StewieHRanat_align2caret_reorient2std.nii.gz -rmode NN \
# 	-prefix ./temp/places_resample -inset Places_align2caret_Both+orig.
# 3dresample -master StewieHRanat_align2caret_reorient2std.nii.gz -rmode NN \
# 	-prefix ./temp/objects_resample -inset Objects_align2caret_Both+orig.
# 3dresample -master StewieHRanat_align2caret_reorient2std.nii.gz -rmode NN \
# 	-prefix ./temp/bparts_resample -inset BodyParts_align2caret_Both+orig.
# 		
# 3dAFNItoNIFTI ./temp/faces_resample+orig.
# 3dAFNItoNIFTI ./temp/places_resample+orig.
# 3dAFNItoNIFTI ./temp/objects_resample+orig.
# 3dAFNItoNIFTI ./temp/bparts_resample+orig.
# 	
# # Step 3 - SkullStrip native space 
# @MonkeyBet -in StewieHRanat_align2caret_reorient2std.nii.gz -bigmonkey
# 
# # Step 4 - Align skullstripped native space to standard space (112RM/McLaren)
# echo "Step 4 - aligning skullstripped native space brain to standard space"
# flirt -in StewieHRanat_align2caret_reorient2std_Brain.nii.gz -ref 112RM-SL-T1.nii.gz \
# 	-omat Stew_to_112RM.mat -out StewieBrain_align_to_112RM
# 
# # Step 5 - Align resampled masks to standard space
# echo "Step 5 - aligning resampled masks to standard space"
# flirt -in ./temp/faces_resample.nii -ref StewieBrain_align_to_112RM.nii.gz -applyxfm \
# 	-init Stew_to_112RM.mat -out ./temp/faces_to_112RM
# flirt -in ./temp/places_resample.nii -ref StewieBrain_align_to_112RM.nii.gz -applyxfm \
# 	-init Stew_to_112RM.mat -out ./temp/places_to_112RM
# flirt -in ./temp/objects_resample.nii -ref StewieBrain_align_to_112RM.nii.gz -applyxfm \
# 	-init Stew_to_112RM.mat -out ./temp/objects_to_112RM
# flirt -in ./temp/bparts_resample.nii -ref StewieBrain_align_to_112RM.nii.gz -applyxfm \
# 	-init Stew_to_112RM.mat -out ./temp/bparts_to_112RM

# Step 6 - Dilate, mask with GM priors and threshold
echo "Step 6 - dilating masks, masking with GM priors, and thresholding to "$thres
fslmaths gm_priors_ohsu+uw.nii.gz -thr $thres ./temp/tempGMpriors
fslmaths ./temp/faces_to_112RM.nii.gz -kernel sphere 1 -dilM -mas ./temp/tempGMpriors.nii.gz -thr $thres \
	-bin ./temp/faces_dilate_all
fslmaths ./temp/places_to_112RM.nii.gz -kernel sphere 1 -dilM -mas ./temp/tempGMpriors.nii.gz -thr $thres \
	-bin ./temp/places_dilate_all
fslmaths ./temp/objects_to_112RM.nii.gz -kernel sphere 1 -dilM -mas ./temp/tempGMpriors.nii.gz -thr $thres \
	-bin ./temp/objects_dilate_all
fslmaths ./temp/bparts_to_112RM.nii.gz -kernel sphere 1 -dilM -mas ./temp/tempGMpriors.nii.gz -thr $thres \
	-bin ./temp/bparts_dilate_all

# Step 7 - Split into individual ROIs
echo "Step 7 - split mask volumes into individual ROIs"
rm -f *s_rois+orig.* *s_rois.nii
3dmerge -1clust_order 0 10 -prefix faces_rois ./temp/faces_dilate_all.nii.gz
3dmerge -1clust_order 0 10 -prefix places_rois ./temp/places_dilate_all.nii.gz
3dmerge -1clust_order 0 10 -prefix objects_rois ./temp/objects_dilate_all.nii.gz
3dmerge -1clust_order 0 10 -prefix bparts_rois ./temp/bparts_dilate_all.nii.gz

3dAFNItoNIFTI faces_rois+orig.
3dAFNItoNIFTI places_rois+orig.
3dAFNItoNIFTI objects_rois+orig.
3dAFNItoNIFTI bparts_rois+orig.