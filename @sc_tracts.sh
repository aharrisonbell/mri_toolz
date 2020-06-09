#!/bin/tcsh
# @Rafal_Monkey1 (Run Tracts)
# by AHB, started May 2013
set version = 1.19-05-2015
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
set scriptdir = ~/Documents/fMRI_Data/scripts # specifies location of TOPUP, etc.
#set scriptdir = ~/Desktop/scripts # specifies location of TOPUP, etc.
set email = "andrew.bell@psy.ox.ac.uk"
#
# Standard Atlases
set mni_atlas = ~/Documents/fMRI_Data/mni_brain/mni_brain_strip.nii
set caret_atlas = ~/Documents/fMRI_Data/caret_brain/CaretBrain_skullstripped.nii.gz
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
	echo "@sc_tracts.sh by AHB, V"$version
	echo "*******************************"
	echo " "
	echo "Script for processing DTI data for the DTI SC-amygdala project (Rafal et al.)"
	echo "This script assumes the data have been run through @DTIScript  until at least step 8 (Bedpostx)"
	echo "This script is also specific for NHP data"
	echo "This is PART 1 - Running Probtractx"
	echo " "
	echo "INPUT: @Rafal_Monkey1 <SESSION> <STEP>"
	echo " "
	echo "This script "
	echo "where:"
	echo " session_name = Label for data"
	echo " "
	echo " step (optional): perform step X where..."
	echo "   1) Align structurals and masks to DTI data"
	echo "   2) Run standard tracts"
	echo "   3) Run non-standard tracts"
	echo " "
	goto exit
endif

set session_name = $1
if ($#argv == 1) then
	set step = 0
else
	set step = $2
endif
set mask_dir = $PWD/${session_name}_aligned_masks_StructSpace

mkdir -p $out_dir $temp_dir

mkdir -p $nii_dir/temp
mkdir -p $out_dir/masks_diffspace $out_dir/masks_diffspace/unthr

###################################################################################################
# Step 1: Align Structural to DTI (and STANDARD ATLASES, etc.)
# This step is necessary to creat the *struct2dti.mat matrix
if ($step =~ *1* || $step == 0) then
	date
	echo "Step 1: Align structural to DTI..."	
	flirt -in ${session_name}hr_StrippedAnat_native.nii.gz -ref $dti_dir/nodif_brain.nii.gz \
	-dof 9 -omat $out_dir/${session_name}_struct2dti.mat -out $out_dir/${session_name}_struct2dti

	echo "...Align structural-aligned masks to diffusion space.."
	cd $mask_dir
	foreach mask (`ls *.nii*`)
		echo $mask
		set newmask = $mask:r
		set newnewmask = $newmask:r # need to remove two extensions
		flirt -in $mask -ref $dti_dir/nodif_brain.nii.gz -applyxfm -init $out_dir/${session_name}_struct2dti.mat -out $out_dir/masks_diffspace/unthr/${newnewmask}_diff_unthr
		fslmaths $out_dir/masks_diffspace/unthr/${newnewmask}_diff_unthr -thr $thr -bin $out_dir/masks_diffspace/${newnewmask}_diff # threshold and binarise
	end
	cp $out_dir/masks_diffspace/Caret_left_hemisphere_align_diff.nii.gz $out_dir/${session_name}_lefthemi_diff.nii.gz # copy left and right hemisphere masks
	cp $out_dir/masks_diffspace/Caret_right_hemisphere_align_diff.nii.gz $out_dir/${session_name}_righthemi_diff.nii.gz # copy left and right hemisphere masks
	cd $home_dir
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then		
		fslview $out_dir/${session_name}_struct2dti.nii.gz $dti_dir/nodif_brain.nii.gz $out_dir/masks_diffspace/*.nii.gz &
	endif
	echo "Step 1: Done.  You are now ready to proceed to PROBTRACKX, using *_struct2dti.mat as a translation matrix."
	
endif  

###################################################################################################
# Step 2: Run Standard Tracts - SC-Pulv-Amyg
if ($step =~ *2* || $step == 0) then
	echo "Step 2: Run standard tracts..."
	echo " "
	echo "Note: this step requires the following masks: "
	echo "	${session_name}_SuperiorColliculus_struct_diff.nii.gz"
	echo "	${session_name}_Pulvinar_struct_diff.nii.gz"
	echo "	${session_name}_Amygdala_struct_diff.nii.gz"
	echo "	${session_name}_BNST_struct_diff.nii.gz"
	echo "	${session_name}_Stria_struct_diff.nii.gz"
	echo "	${session_name}_righthemi_diff.nii.gz"
	echo "	${session_name}_lefthemi_diff.nii.gz"
	echo " "
	convert_xfm -omat $out_dir/${session_name}_dti2struct.mat -inverse $out_dir/${session_name}_struct2dti.mat
	
	# MAIN PATHWAY - FORWARD DIRECTION
	# Create waypoints.txt file
	echo `ls ${out_dir}/masks_diffspace/${session_name}_Pulvinar_struct_diff.nii.gz` > $out_dir/waypoints_SC-Pul-Amyg.txt 
	echo `ls ${out_dir}/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz` >> $out_dir/waypoints_SC-Pul-Amyg.txt 

	# R-SC-Pulv-Amyg
	set path_dir = R_SC-Pul-Amyg-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_lefthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_righthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionLeftHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionLeftHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_SC-Pul-Amyg.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	# L-SC-Pulv-Amyg
	set path_dir = L_SC-Pul-Amyg-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_righthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_lefthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionRightHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionRightHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_SC-Pul-Amyg.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	# MAIN PATHWAY - OTHER DIRECTION
	# Create waypoints.txt file
	echo `ls ${out_dir}/masks_diffspace/${session_name}_Pulvinar_struct_diff.nii.gz` > $out_dir/waypoints_Amyg-Pul-SC.txt 
	echo `ls ${out_dir}/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz` >> $out_dir/waypoints_Amyg-Pul-SC.txt 

	# R-Amyg-Pulv-SC
	set path_dir = R_Amyg-Pul-SC-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_lefthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_righthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionLeftHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionLeftHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_Amyg-Pul-SC.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	# L-Amyg-Pulv-SC
	set path_dir = L_Amyg-Pul-SC-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_righthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_lefthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionRightHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionRightHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_Amyg-Pul-SC.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz
		
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then		
		fslview $out_dir/${session_name}_struct2dti.nii.gz \
		$out_dir/tract*-n3.nii.gz &
	endif
	echo "Step 2: Done."
	
endif


###################################################################################################
# Step 3: Run Stria Terminalis Tracts
if ($step =~ *3* || $step == 0) then
	echo "Step 3: Run Stria Terminalis tracts..."
	echo " "
	echo "Note: this step requires the following masks: "
	echo "	${session_name}_SuperiorColliculus_struct_diff.nii.gz"
	echo "	${session_name}_Pulvinar_struct_diff.nii.gz"
	echo "	${session_name}_Amygdala_struct_diff.nii.gz"
	echo "	${session_name}_BNST_struct_diff.nii.gz"
	echo "	${session_name}_Stria_struct_diff.nii.gz"
	echo "	${session_name}_righthemi_diff.nii.gz"
	echo "	${session_name}_lefthemi_diff.nii.gz"
	echo " "
	convert_xfm -omat $out_dir/${session_name}_dti2struct.mat -inverse $out_dir/${session_name}_struct2dti.mat
	
	rm -f $out_dir/tract_*_StriaTerm-n3*
	
	# STRIA PATHWAY - ONE DIRECTION (Amygdala to BNST)
	# R-Stria
	set path_dir = R_StriaTerm_Forward-n3
	echo "***** Tracing "$path_dir
	# Create dilated masks
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_R_StriaTerm-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/R_striaterm_dilate
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_R_BNST-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/R_bnst_dilate
 	fslmaths $out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz -mas $out_dir/${session_name}_righthemi_diff.nii.gz $out_dir/R_amygdala
	# Create waypoints.txt file
	# echo `ls $out_dir/R_striaterm_dilate.nii.gz` > $out_dir/waypoints_Amyg-BNST-Stria.txt 
	echo `ls $out_dir/R_bnst_dilate.nii.gz` > $out_dir/waypoints_Amyg-BNST-Stria.txt 
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/R_amygdala.nii.gz -l --onewaycondition --wayorder --pd -c 0.1 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	#--avoid=$out_dir/TotalExclusionLeftHemi_diff.nii.gz \
	--stop=$out_dir/R_bnst_dilate.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_Amyg-BNST-Stria.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz
	
	# L-Stria
	set path_dir = L_StriaTerm_Forward-n3
	echo "***** Tracing "$path_dir
	# Create dilated masks
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_L_StriaTerm-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/L_striaterm_dilate
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_L_BNST-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/L_bnst_dilate
	fslmaths $out_dir/masks_diffspace/Caret_Amgydala_NEW_mask_align_diff.nii.gz -mas $out_dir/${session_name}_lefthemi_diff.nii.gz $out_dir/L_amygdala
	# Create waypoints.txt file
	# echo `ls $out_dir/L_striaterm_dilate.nii.gz` > $out_dir/waypoints_Amyg-BNST-Stria.txt 
	echo `ls $out_dir/L_bnst_dilate.nii.gz` > $out_dir/waypoints_Amyg-BNST-Stria.txt 
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/L_amygdala.nii.gz -l --onewaycondition --wayorder --pd -c 0.1 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	#--avoid=$out_dir/TotalExclusionRightHemi_diff.nii.gz \
	--stop=$out_dir/L_bnst_dilate.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_Amyg-BNST-Stria.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz


	# STRIA PATHWAY - OTHER DIRECTION (BNST to Amygdala)
	
	# R-Stria	
	set path_dir = R_StriaTerm_Backward-n3
	echo "***** Tracing "$path_dir
	# Create dilated masks
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_R_StriaTerm-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/R_striaterm_dilate
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_R_BNST-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/R_bnst_dilate
 	fslmaths $out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz -mas $out_dir/${session_name}_righthemi_diff.nii.gz $out_dir/R_amygdala
	# Create waypoints.txt file
	# echo `ls $out_dir/R_striaterm_dilate.nii.gz` > $out_dir/waypoints_BNST-Amyg-Stria.txt 
	echo `ls $out_dir/R_amygdala.nii.gz` > $out_dir/waypoints_BNST-Amygdala-Stria.txt 
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/R_bnst_dilate.nii.gz -l --onewaycondition --wayorder --pd -c 0.1 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	#--avoid=$out_dir/TotalExclusionLeftHemi_diff.nii.gz \
	--stop=$out_dir/R_amygdala.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_BNST-Amygdala-Stria.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz
	
	# L-Stria
	set path_dir = L_StriaTerm_Backward-n3
	echo "***** Tracing "$path_dir
	# Create dilated masks
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_L_StriaTerm-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/L_striaterm_dilate
	fslmaths $out_dir/masks_diffspace/unthr/CaretBrain_L_BNST-mask_align_diff_unthr.nii.gz -kernel sphere 1 -dilM -bin $out_dir/L_bnst_dilate
	fslmaths $out_dir/masks_diffspace/Caret_Amgydala_NEW_mask_align_diff.nii.gz -mas $out_dir/${session_name}_lefthemi_diff.nii.gz $out_dir/L_amygdala
	# Create waypoints.txt file
	# echo `ls $out_dir/L_striaterm_dilate.nii.gz` > $out_dir/waypoints_BNST-Amyg-Stria.txt 
	echo `ls $out_dir/L_amygdala.nii.gz` > $out_dir/waypoints_BNST-Amygdala-Stria.txt 
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/L_bnst_dilate.nii.gz -l --onewaycondition --wayorder --pd -c 0.1 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	#--avoid=$out_dir/TotalExclusionRightHemi_diff.nii.gz \
	--stop=$out_dir/L_amygdala.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_BNST-Amygdala-Stria.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then		
		fslview $out_dir/${session_name}_struct2dti.nii.gz \
		$out_dir/tract*-n3.nii.gz &
	endif
	echo "Step 3: Done."
	
endif

###################################################################################################
# Step 4: Run Standard Tracts - SC-Amyg
if ($step =~ *4* || $step == 0) then
	echo "Step 4: Run standard tracts WITHOUT pulvinar mask"
	echo " "
	echo "Note: this step requires the following masks: "
	echo "	${session_name}_SuperiorColliculus_struct_diff.nii.gz"
	echo "	${session_name}_Pulvinar_struct_diff.nii.gz"
	echo "	${session_name}_Amygdala_struct_diff.nii.gz"
	echo "	${session_name}_BNST_struct_diff.nii.gz"
	echo "	${session_name}_Stria_struct_diff.nii.gz"
	echo "	${session_name}_righthemi_diff.nii.gz"
	echo "	${session_name}_lefthemi_diff.nii.gz"
	echo " "
	convert_xfm -omat $out_dir/${session_name}_dti2struct.mat -inverse $out_dir/${session_name}_struct2dti.mat
	
	# MAIN PATHWAY - FORWARD DIRECTION
	# Create waypoints.txt file
	echo `ls ${out_dir}/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz` > $out_dir/waypoints_SC-Amyg.txt 

	# R-SC-Amyg
	set path_dir = R_SC-Amyg-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_lefthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_righthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionLeftHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionLeftHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_SC-Amyg.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	# L-SC-Pulv-Amyg
	set path_dir = L_SC-Amyg-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_righthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_lefthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionRightHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionRightHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_SC-Amyg.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	# MAIN PATHWAY - OTHER DIRECTION
	# Create waypoints.txt file
	echo `ls ${out_dir}/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz` > $out_dir/waypoints_Amyg-SC.txt 

	# R-Amyg-Pulv-SC
	set path_dir = R_Amyg-SC-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_lefthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_righthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionLeftHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionLeftHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_Amyg-SC.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz

	# L-Amyg-Pulv-SC
	set path_dir = L_Amyg-SC-n3
	echo "***** Tracing "$path_dir
	# Compile exclusion mask:
	fslmaths $out_dir/${session_name}_righthemi_diff.nii.gz -sub \
	$out_dir/${session_name}_lefthemi_diff.nii.gz -thr 1 $out_dir/masks_diffspace/TotalExclusionRightHemi_diff
	# Conduct probabilistic tractography
	probtrackx2 -V 2 -x $out_dir/masks_diffspace/${session_name}_Amygdala_struct_diff.nii.gz -l --onewaycondition --wayorder --pd -c 0.2 -S 5000 \
	--steplength=0.1 --randfib=1 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 \
	--avoid=$out_dir/masks_diffspace/TotalExclusionRightHemi_diff.nii.gz \
	--stop=$out_dir/masks_diffspace/${session_name}_SuperiorColliculus_struct_diff.nii.gz --forcedir --opd \
	-s $dti_dir/BedpostX/merged -m $dti_dir/BedpostX/nodif_brain_mask \
	--dir=$out_dir/$path_dir \
	--waypoints=$out_dir/waypoints_Amyg-SC.txt --waycond=AND
	cp $out_dir/$path_dir/fdt_paths.nii.gz $out_dir/tract_${path_dir}.nii.gz
	flirt -in $out_dir/tract_${path_dir}.nii.gz -ref ${session_name}hr_StrippedAnat_native.nii.gz -applyxfm -init $out_dir/${session_name}_dti2struct.mat -out $out_dir/tract_${path_dir}_struct.nii.gz
		
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then		
		fslview $out_dir/${session_name}_struct2dti.nii.gz \
		$out_dir/tract*-n3.nii.gz &
	endif
	echo "Step 4: Done."
	
endif

goto exit

exit:
