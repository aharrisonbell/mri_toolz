#!/bin/tcsh
# @sc_tracts_master.sh
# by AHB, started May 2013
set version = 1.28-05-2015

####################################################################################################
#       SET UP VARIABLES HERE*
#
# Directories
set homedir = $PWD
set scriptdir = ~/Documents/fMRI_Data/scripts # specifies location of TOPUP, etc.
set nhp_in = ~/Documents/_Current_Projects/DTI_SC_Project/Data/Monkey_Data
set nhp_out = ~/Documents/_Current_Projects/DTI_SC_Project/Data/Monkey_Analysis/
set temp_dir = $nhp_out/temp_dir
set email = "andrew.bell@psy.ox.ac.uk"
#
set kernel = 1 # diameter in mm of dilation
set kernel_nhp = 0.5 # diameter in mm of dilation
set threshold = 10
#
# Standard Atlases
set caret_brain = ~/Documents/fMRI_Data/caret_brain/CaretBrain_skullstripped.nii.gz
set caret_dir = ~/Documents/fMRI_Data/caret_brain
set human_brain = ~/Documents/fMRI_Data/human_brain/human_standard.nii.gz
#
# Program Options
set REV_OPTION = "y" # (y/n) - calls up FSLVIEW window after each step (USEFUL!!)
####################################################################################################

echo " "
echo "*******************************"
echo "@sc_tracts_master.sh by AHB, V"$version
echo "*******************************"
echo " "
echo "Script for compiling DTI data for SC Project (Bangor/Oxford/CBU)"
echo " "

mkdir -p $nhp_out $temp_dir
mkdir -p ${nhp_out}/omats
mkdir -p ${nhp_out}/caret_aligned

goto part4

# Part 1 - Generate tracts
part1:
foreach nhp_subj (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo "Part 1: Generating tracts in "$nhp_subj
	cd ${nhp_in}/${nhp_subj}
	@sc_tracts.sh $nhp_subj 234
end

# Part 2 - Process/overlap tracts
part2:
foreach nhp_subj (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo "Part 2: Processing tracts for "$nhp_subj
	cd ${nhp_in}/${nhp_subj}/DTI_SC
	foreach hemi (L R)
		echo " Hemisphere: "$hemi
		#flirt -in ${nhp_in}/${nhp_subj}/${nhp_subj}hr_StrippedAnat_native.nii.gz -ref $caret_brain -omat ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_struct2caret

		echo "  2.1: align each streamline to standard atlas"
		flirt -in tract_${hemi}_SC-Pul-Amyg-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_caret
		flirt -in tract_${hemi}_Amyg-Pul-SC-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_caret
		flirt -in tract_${hemi}_StriaTerm_Forward-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret
		flirt -in tract_${hemi}_StriaTerm_Backward-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret
		
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_bin_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_bin_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_bin_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_bin_caret
		
		echo "  2.2: Create overlapping streamlines in both native and standard space"
		# Native Space 
		rm -f ${temp_dir}/tempvolume*
		fslmaths tract_${hemi}_SC-Pul-Amyg-n3_struct.nii.gz -bin ${temp_dir}/tempvolume 
		fslmaths tract_${hemi}_Amyg-Pul-SC-n3_struct.nii.gz -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_native
		rm -f ${temp_dir}/tempvolume*
		fslmaths tract_${hemi}_StriaTerm_Forward-n3_struct.nii.gz -bin ${temp_dir}/tempvolume
		fslmaths tract_${hemi}_StriaTerm_Backward-n3_struct.nii.gz -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_native
		
		# Standard Space
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_caret -bin ${temp_dir}/tempvolume 
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_caret -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_caret
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin ${temp_dir}/tempvolume
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_caret
		
		echo "  2.3: Dilate tracts and re-create overlapping streamlines in standard space (dilate tracts by *kernel* mm)"	
		# Standard Space
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_caret -bin -kernel sphere $kernel_nhp -dilM ${temp_dir}/tempvolume 
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_caret -bin -kernel sphere $kernel_nhp -dilM -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_OverlapDilate_caret
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin -kernel sphere $kernel_nhp -dilM ${temp_dir}/tempvolume
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin -kernel sphere $kernel_nhp -dilM -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_OverlapDilate_caret
		
		echo "  2.4: Threshold standard space volumes (both intact and dilated)"
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_thr_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_thr_caret
		
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_OverlapDilate_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_OverlapDilate_thr_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_OverlapDilate_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_OverlapDilate_thr_caret
	end
end

part3:
foreach nhp_subj (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo "Part 3: Processing tracts for "$nhp_subj
	cd ${nhp_in}/${nhp_subj}/DTI_SC
	foreach hemi (L R)
		echo " Hemisphere: "$hemi
		#flirt -in ${nhp_in}/${nhp_subj}/${nhp_subj}hr_StrippedAnat_native.nii.gz -ref $caret_brain -omat ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_struct2caret

		echo "  2.1: align each streamline to standard atlas"
		flirt -in tract_${hemi}_SC-Amyg-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_caret
		flirt -in tract_${hemi}_Amyg-SC-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_Amyg-SC_caret
		flirt -in tract_${hemi}_StriaTerm_Forward-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret
		flirt -in tract_${hemi}_StriaTerm_Backward-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret
		
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_bin_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-SC_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_Amyg-SC_bin_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_bin_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_bin_caret
		
		echo "  2.2: Create overlapping streamlines in both native and standard space"
		# Native Space 
		rm -f ${temp_dir}/tempvolume*
		fslmaths tract_${hemi}_SC-Amyg-n3_struct.nii.gz -bin ${temp_dir}/tempvolume 
		fslmaths tract_${hemi}_Amyg-SC-n3_struct.nii.gz -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_Overlap_native
		rm -f ${temp_dir}/tempvolume*
		fslmaths tract_${hemi}_StriaTerm_Forward-n3_struct.nii.gz -bin ${temp_dir}/tempvolume
		fslmaths tract_${hemi}_StriaTerm_Backward-n3_struct.nii.gz -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_native
		
		# Standard Space
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_caret -bin ${temp_dir}/tempvolume 
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-SC_caret -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_Overlap_caret
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin ${temp_dir}/tempvolume
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_caret
		
		echo "  2.3: Dilate tracts and re-create overlapping streamlines in standard space (dilate tracts by *kernel* mm)"	
		# Standard Space
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_caret -bin -kernel sphere $kernel_nhp -dilM ${temp_dir}/tempvolume 
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-SC_caret -bin -kernel sphere $kernel_nhp -dilM -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_OverlapDilate_caret
		rm -f ${temp_dir}/tempvolume*
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin -kernel sphere $kernel_nhp -dilM ${temp_dir}/tempvolume
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin -kernel sphere $kernel_nhp -dilM -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_OverlapDilate_caret
		
		echo "  2.4: Threshold standard space volumes (both intact and dilated)"
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_Overlap_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_Overlap_thr_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_thr_caret
		
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_OverlapDilate_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_SC-Amyg_OverlapDilate_thr_caret
		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_OverlapDilate_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_OverlapDilate_thr_caret
	end
end



# Part 4 - Process/overlap tracts
part4:
		
		
cd $nhp_out
echo "Part 4: Compiling datasets from all subjects..."
fslmaths MI00112_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00114_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00115_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00117_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00119_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00120_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00121_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00123_L_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00112_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00114_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00115_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00117_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00119_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00120_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00121_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   -add MI00123_R_SC-Pul-Amyg_Overlap_thr_caret.nii.gz \
   nhp_SC-Pul-Amyg_Overlap_thr_caret -odt int
   
fslmaths MI00112_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00114_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00115_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00117_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00119_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00120_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00121_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00123_L_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00112_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00114_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00115_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00117_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00119_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00120_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00121_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   -add MI00123_R_SC-Pul-Amyg_OverlapDilate_thr_caret.nii.gz \
   nhp_SC-Pul-Amyg_OverlapDilate_thr_caret -odt int
   
fslmaths MI00112_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00114_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00115_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00117_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00119_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00120_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00121_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00123_L_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00112_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00114_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00115_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00117_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00119_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00120_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00121_R_SC-Pul-Amyg_bin_caret.nii.gz \
   -add MI00123_R_SC-Pul-Amyg_bin_caret.nii.gz \
   nhp_SC-Pul-Amyg_bin_caret -odt int

fslmaths MI00112_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00114_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00115_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00117_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00119_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00120_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00121_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00123_L_SC-Amyg_bin_caret.nii.gz \
   -add MI00112_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00114_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00115_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00117_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00119_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00120_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00121_R_SC-Amyg_bin_caret.nii.gz \
   -add MI00123_R_SC-Amyg_bin_caret.nii.gz \
   nhp_SC-Amyg_bin_caret -odt int

fslmaths MI00112_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00114_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00115_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00117_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00119_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00120_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00121_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00123_L_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00112_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00114_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00115_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00117_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00119_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00120_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00121_R_StriaTerm_Overlap_thr_caret.nii.gz \
   -add MI00123_R_StriaTerm_Overlap_thr_caret.nii.gz \
   nhp_StriaTerm_Overlap_thr_caret -odt int
   
fslmaths MI00112_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00114_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00115_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00117_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00119_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00120_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00121_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00123_L_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00112_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00114_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00115_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00117_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00119_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00120_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00121_R_StriaTerm_Forward_bin_caret.nii.gz \
   -add MI00123_R_StriaTerm_Forward_bin_caret.nii.gz \
   nhp_StriaTerm_Forward_bin_caret -odt int
   
exit:

