#!/bin/tcsh
# @sc_tracts_human.sh
# by AHB, started June 2015
set version = 1.05-06-2015

####################################################################################################
#       SET UP VARIABLES HERE*
#
# Directories
set homedir = ~/Documents/_Current_Projects/DTI_SC_Project/fromKristin/Final
set scriptdir = ~/Documents/fMRI_Data/scripts # specifies location of TOPUP, etc.
set temp_dir = $homedir/temp_dir
# Standard Atlases
set human_brain = $homedir/T1_P2_nodif_brain.nii.gz
#
####################################################################################################

echo " "
echo "*******************************"
echo "@sc_tracts_human.sh by AHB, V"$version
echo "*******************************"
echo " "

cd $homedir
mkdir -p $homedir/temp_dir

foreach subjid (1 2 3 4 5 6 7 8 9 10 11 12)
	echo "Prepping subject "$subjid
	foreach hemi (L R)
		fslmaths ${hemi}_final_P${subjid}onP2.nii.gz -bin $temp_dir/${hemi}_subject${subjid}_binariseTract
	end
end

cd $temp_dir
fslmaths L_subject1_binariseTract.nii.gz \
   -add L_subject2_binariseTract.nii.gz \
   -add L_subject3_binariseTract.nii.gz \
   -add L_subject4_binariseTract.nii.gz \
   -add L_subject5_binariseTract.nii.gz \
   -add L_subject6_binariseTract.nii.gz \
   -add L_subject7_binariseTract.nii.gz \
   -add L_subject8_binariseTract.nii.gz \
   -add L_subject9_binariseTract.nii.gz \
   -add L_subject10_binariseTract.nii.gz \
   -add L_subject11_binariseTract.nii.gz \
   -add L_subject12_binariseTract.nii.gz \
   human_L_SC-Amyg_Overlap_group -odt int
   
fslmaths R_subject1_binariseTract.nii.gz \
   -add R_subject2_binariseTract.nii.gz \
   -add R_subject3_binariseTract.nii.gz \
   -add R_subject4_binariseTract.nii.gz \
   -add R_subject5_binariseTract.nii.gz \
   -add R_subject6_binariseTract.nii.gz \
   -add R_subject7_binariseTract.nii.gz \
   -add R_subject8_binariseTract.nii.gz \
   -add R_subject9_binariseTract.nii.gz \
   -add R_subject10_binariseTract.nii.gz \
   -add R_subject11_binariseTract.nii.gz \
   -add R_subject12_binariseTract.nii.gz \
   human_R_SC-Amyg_Overlap_group -odt int
   
   
exit:

