#! /bin/tcsh
cd ~/Documents/_Current_Projects/DTI_SC_Project/Data/Monkey_Analysis

foreach nhp_subj (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo $nhp_subj
	foreach hemi (L R)
		rm -f ${nhp_subj}_${hemi}_data.txt ${nhp_subj}_${hemi}_stria_data.txt
		foreach slice (84 86 88 90 92 94 96 98 100 102 104 106 108 110)
			echo $slice
			fslstats ${nhp_subj}_${hemi}_SC-Amyg_bin_caret.nii.gz -k slice${slice}mask.nii.gz -C >> ${nhp_subj}_${hemi}_data.txt
			fslstats ${nhp_subj}_${hemi}_StriaTerm_Forward_bin_caret.nii.gz -k slice${slice}mask.nii.gz -C >> ${nhp_subj}_${hemi}_stria_data.txt
		end
	end
end
	
