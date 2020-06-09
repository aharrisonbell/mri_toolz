#!/bin/tcsh
# @Rafal_Monkey2
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
echo "@Rafal_Monkey2a.sh by AHB, V"$version
echo "*******************************"
echo " "
echo "Script for compiling DTI data for SC Project (Bangor/Oxford/CBU)"
echo " "

mkdir -p $nhp_out $temp_dir
mkdir -p ${nhp_out}/omats
mkdir -p ${nhp_out}/caret_aligned

# Part 1 - Align each subject's data to Caret Brain (standard space)
foreach nhp_subj (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo "Analysing Monkey Subject "$nhp_subj

	cd ${nhp_in}/${nhp_subj}
	@sc_tracts.sh $nhp_subj 4
#	cd ${nhp_in}/${nhp_subj}/DTI_SC
#	foreach hemi (L R)
		#flirt -in ${nhp_in}/${nhp_subj}/${nhp_subj}hr_StrippedAnat_native.nii.gz -ref $caret_brain -omat ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_struct2caret

#		echo "Step 1: align each streamline to standard atlas"
#		flirt -in tract_${hemi}_SC-Pul-Amyg-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_caret
#		flirt -in tract_${hemi}_Amyg-Pul-SC-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_caret
#		flirt -in tract_${hemi}_StriaTerm_Forward-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret
#		flirt -in tract_${hemi}_StriaTerm_Backward-n3_struct.nii.gz -ref $caret_brain -applyxfm -init ${nhp_out}/omats/${nhp_subj}_struct2caret.mat -out ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret
#		
#		echo "Step 2: Create overlapping streamlines in both native and standard space"
#		# Native Space 
#		rm -f ${temp_dir}/tempvolume*
#		fslmaths tract_${hemi}_SC-Pul-Amyg-n3_struct.nii.gz -bin ${temp_dir}/tempvolume 
#		fslmaths tract_${hemi}_Amyg-Pul-SC-n3_struct.nii.gz -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_native
#		rm -f ${temp_dir}/tempvolume*
#		fslmaths tract_${hemi}_StriaTerm_Forward-n3_struct.nii.gz -bin ${temp_dir}/tempvolume
#		fslmaths tract_${hemi}_StriaTerm_Backward-n3_struct.nii.gz -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_native
#		
#		# Standard Space
#		rm -f ${temp_dir}/tempvolume*
#		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_caret -bin ${temp_dir}/tempvolume 
#		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_Amyg-Pul-SC_caret -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_caret
#		rm -f ${temp_dir}/tempvolume*
#		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Forward_caret -bin ${temp_dir}/tempvolume
#		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Backward_caret -bin -add ${temp_dir}/tempvolume ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_caret
#		
#		echo "Step 3: Threshold standard space volumes"
#		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_thr_caret
#		fslmaths ${nhp_out}/${nhp_subj}_${hemi}_StriaTerm_Overlap_caret -thr 1.5 ${nhp_out}/${nhp_subj}_${hemi}_SC-Pul-Amyg_Overlap_thr_caret
#		
#	end
end
goto exit
		
		
		
		
		
		
		


	foreach tract (sc_amyg) # StriaTerm C-Pul-Amyg SC-Amyg Pul-Amyg SC-Pul SC-PulSlice-Amyg)
	echo ".Tract "$tract
		foreach hemi (L R)
			echo ".Hemisphere: "$hemi
			echo "...Step 2 - Normalise datasets by Waytotal"
			set waytotal = (`more ${nhp_subj}_${hemi}_${tract}_waytotal`)
			#echo $waytotal
			fslmaths ${nhp_subj}_${hemi}_${tract}_fdt_paths.nii.gz -div $waytotal ${temp_dir}/${nhp_subj}_temp1 -odt float
			fslmaths ${temp_dir}/${nhp_subj}_temp1.nii.gz -mul 100 ${nhp_subj}_${hemi}_${tract}_fdtNormWT_diff -odt float
			
			echo "...Step 3 - Normalise datasets by Max Value in FDT"
			set temp = `fslstats ${nhp_subj}_${hemi}_${tract}_fdt_paths.nii.gz -R`
			set normaliser = `echo $temp[2]`
			fslmaths ${nhp_subj}_${hemi}_${tract}_fdt_paths.nii.gz -div $normaliser ${temp_dir}/${nhp_subj}_temp1 -odt float
			fslmaths ${temp_dir}/${nhp_subj}_temp1.nii.gz -mul 100 ${nhp_subj}_${hemi}_${tract}_fdtNormMAX_diff -odt float					

			echo "...Step 4 - Threshold by "$threshold	
			fslmaths ${nhp_subj}_${hemi}_${tract}_fdtNormMAX_diff -thra $threshold ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}_diff -odt float
		
			echo "...Step 5 - Binarise MAX volumes aligned to own brain"
			fslmaths ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}_diff -div ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}_diff ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}Bin_diff -odt int
			
			echo "...Step 6 - Align FDT paths to Standard Brain (fdt2caret)"
			flirt -in ${nhp_subj}_mergedB0s_fix.nii.gz -ref $caret_brain -omat ${nhp_subj}_dti2caret.mat -out ${temp_dir}/${nhp_subj}_dti2caret
			flirt -in ${nhp_subj}_${hemi}_${tract}_fdtNormMAX_diff -ref $caret_brain -applyxfm -init ${nhp_subj}_dti2caret.mat -out ${nhp_subj}_${hemi}_${tract}_fdtNormMAX_caret -datatype float
			flirt -in ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}_diff -ref $caret_brain -applyxfm -init ${nhp_subj}_dti2caret.mat -out ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}_caret -datatype float
			flirt -in ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}Bin_diff -ref $caret_brain -applyxfm -init ${nhp_subj}_dti2caret.mat -out ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}Bin_caret -datatype float	
			
			echo "...Step 7 - Smooth Tracts using spherical ROI approach (dilate tracts by *kernel* mm)"	
			fslmaths ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}Bin_caret.nii.gz -kernel sphere $kernel_nhp -dilM ${nhp_subj}_${hemi}_${tract}_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret -odt int
		
			echo "...Step 8 - Compile data for FDT percentages (normalised to waytotals)"
			fslstats ${nhp_subj}_${hemi}_${tract}_fdtNormWT_diff.nii.gz -M > ${nhp_subj}_${hemi}_${tract}_fdt_percentWT
		end
	end
end
goto exit
echo ".Step 9 - Align masks to standard space"
cd ./DTI_SC
foreach mask (`ls *SC_diff_corr.nii*`)
	set newmask = $mask:r
	set newnewmask = $newmask:r # need to remove two extensions
	flirt -in $mask -ref $caret_brain -applyxfm -init ${nhp_dir}/omats/${nhp_subj}_dti2caret.mat -out ${nhp_out}/${newnewmask}_caret
end
foreach mask (`ls *ulvinar_diff_corr.nii*`)
	set newmask = $mask:r
	set newnewmask = $newmask:r # need to remove two extensions
	flirt -in $mask -ref $caret_brain -applyxfm -init ${nhp_dir}/omats/${nhp_subj}_dti2caret.mat -out ${nhp_out}/${newnewmask}_caret
end
foreach mask (`ls *mygdala_diff_corr.nii*`)
	set newmask = $mask:r
	set newnewmask = $newmask:r # need to remove two extensions
	flirt -in $mask -ref $caret_brain -applyxfm -init ${nhp_dir}/omats/${nhp_subj}_dti2caret.mat -out ${nhp_out}/${newnewmask}_caret
end
cd ..
mv ${nhp_out}/${nhp_subj}*caret*nii.gz ${nhp_out}/caret_aligned
end

goto exit

part2:
cd $nhp_out/caret_aligned
echo "Compiling datasets from all subjects..."
fslmaths MI00112_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00114_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00115_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00117_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00119_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00120_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00121_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00123_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00112_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00114_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00115_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00117_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00119_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00120_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00121_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   -add MI00123_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret.nii.gz \
   nhp_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin_caret -odt int

fslmaths MI00112_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00114_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00115_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00117_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00119_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00120_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00121_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00123_L_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00112_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00114_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00115_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00117_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00119_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00120_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00121_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   -add MI00123_R_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret.nii.gz \
   nhp_SC-Pul-Amyg_fdtNormMAXThres${threshold}Bin${kernel_nhp}mmSphere_caret -odt int
if ($REV_OPTION == "y" || $REV_OPTION == "Y") then		
	fslview $caret_brain nhp*.nii.gz &
	afni *.nii.gz &
endif


exit:

