#!/bin/tcsh
# @Rafal_Monkey0 (Prepare Masks)
# by AHB, started May 2015
set version = 1.15-05-2015
# Script to process and segment DTI data collected at BSB
# This script assumes that the data has already been converted from DICOMs and is in the proper
# orientation. If not, try using @Convert2nii.
# This script also assumes the data have been collected in a certain way (e.g., B0 fields at beginning
# of each run, 60 dirs split into 3 files + 8 dir, alternating phase-encoding dirs, etc.).  If your
# data have been collected in a different way, you may have to change the script.

####################################################################################################
#       SET UP VARIABLES HERE*
#
# Directories
set home_dir = $PWD
set nii_dir = $PWD/nii_files
set out_dir = $PWD/DTI_SC
set dti_dir = $PWD/DTI_data
set anat_dir = $PWD/structurals
set temp_dir = $PWD/temp
set new_mask_dir = ~/Documents/_Current_Projects/DTI_SC_Project/newCaretMasks
set scriptdir = ~/Documents/_Current_Projects/scripts # specifies location of TOPUP, etc.
#set scriptdir = ~/Desktop/scripts # specifies location of TOPUP, etc.
set email = "andrew.bell@psy.ox.ac.uk"
#
# Standard Atlases
set mni_atlas = ~/Documents/fMRI_Data/mni_brain/mni_brain_strip.nii
set caret_atlas = ~/Documents/fMRI_Data/caret_brain/caretbrain.nii.gz
#set mni_atlas = /imaging/ab03/mni_brain/mni_brain_strip.nii
#set caret_atlas = /imaging/ab03/caret_brain/CaretBrain_skullstripped.nii.gz
set mni_dir = ~/Documents/fMRI_Data/mni_brain/
set caret_dir = ~/Documents/fMRI_Data/caret_brain
#set mni_dir = /imaging/ab03/mni_brain/
#set caret_dir = /imaging/ab03/caret_brain/
#
# incoming data labels (the script identifies input data by searching for these threads)
set DTI_label = DTImosaicb100010mm
set PE_axis = 2 # (x,y,z) = (LR/parallel to B0/up-down) therefore in monkey space = (LR/IS/PA)
set thr = 0.5 # threshold for masks
#
# Program Options
set REV_OPTION = "y" # (y/n) - calls up FSLVIEW window after each step (USEFUL!!)
set AFNI_OPTION = "n" # (y/n) - includes AFNI-based skull stripping.  Useful to compare
#
# *so non-coders, don't f**k with stuff below this section and then complain to me that
#  the code doesn't work :)
####################################################################################################

if ($#argv == 0) then
	echo " "
	echo "*******************************"
	echo "@Rafal_Monkey0 by AHB, V"$version
	echo "*******************************"
	echo " "
	echo "Script for processing DTI data for the DTI SC-amygdala project (Rafal et al.)"
	echo "This script assumes the data have been run through @DTIScript  until at least step 8 (Bedpostx)"
	echo "This script is also specific for NHP data"
	echo "This is PART 0 - Preparing Masks"
	echo " "
	echo "INPUT: @Rafal_Monkey0 <SESSION>"
	echo " "
	echo "This script "
	echo "where:"
	echo " session_name = Label for data"
	echo " "
	echo " step (optional): perform step X where..."
	echo "   1) Align new Caret-aligned masks to Structural Data"
	echo " "
	goto exit
endif

set session_name = $1
if ($#argv == 1) then
	set step = 0
else
	set step = $2
endif
mkdir -p $out_dir $temp_dir
mkdir -p $nii_dir/temp
set session_mask_dir = $home_dir/${session_name}_aligned_masks_StructSpace
mkdir -p ${session_mask_dir}/unthr


###################################################################################################
# Step 1: Align Structural to DTI (and STANDARD ATLASES, etc.)
# This step is necessary to creat the *struct2dti.mat matrix
date
echo "Step 1: Align caret brain to native structural..."	
flirt -in $caret_atlas -ref ${session_name}hr_StrippedAnat_native.nii.gz \
-dof 9 -omat $out_dir/${session_name}_caret2struct.mat -out $out_dir/${session_name}_caret2struct

echo "...Align caret-aligned masks to structural space.."
cd $new_mask_dir
foreach mask (`ls *.nii*`)
	set newmask = $mask:r
	set newnewmask = $newmask:r # need to remove two extensions
	flirt -in $mask -ref $home_dir/${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_caret2struct.mat \
	-out $session_mask_dir/unthr/${newnewmask}_struct_unthr
	fslmaths ${session_mask_dir}/unthr/${newnewmask}_struct_unthr -thr $thr -bin $session_mask_dir/${newnewmask}_align
end
cd $home_dir
echo "Step 1: Done."
