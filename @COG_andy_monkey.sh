#! /bin/tcsh 
set kernel_nhp = 2 # diameter in mm of dilation
# Change directory to tracts aligned to standard brain
cd ~/Documents/_Current_Projects/DTI_SC_Project/Data/Monkey_Tracts/

goto overlap

# SC-AMYG Pathway
foreach sess (mi112 mi114 mi115 mi117 mi119 mi120 mi121 mi123) # new
	echo "Analysing Monkey Subject "$sess
	foreach hemi (L R)
		echo ".Hemisphere: "$hemi
		fslmaths ${sess}_${hemi}_sc_amyg_fdtNormMAXThres10_caret -bin ${sess}_${hemi}_sc_amyg_Bin
		fslmaths ${sess}_${hemi}_sc_amyg_Bin -kernel sphere $kernel_nhp -dilM ${sess}_${hemi}_sc_amyg_Bin_sphere -odt int
	end
end

# StriaTerm Pathway
foreach sess (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123) # new
	echo "Analysing Monkey Subject "$sess
	foreach hemi (L R)#! /bin/tcsh 
cd ~/Documents/_Current_Projects/DTI_SC_Project/Data/Monkey_Analysis

foreach nhp_subj (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo $nhp_subj
	foreach hemi (L R)
		rm -f ${nhp_subj}_${hemi}_data.txt ${nhp_subj}_${hemi}_stria_data.txt
		foreach slice (84 86 88 90 92 94 96 98)
			fslstats ${nhp_subj}_${hemi}_SC-Amyg_bin_caret.nii.gz -k slice${slice}mask.nii.gz -C >> ${nhp_subj}_${hemi}_data.txt
			fslstats ${nhp_subj}_${hemi}_StriaTerm_Forward_bin_caret.nii.gz -k slice${slice}mask.nii.gz -C >> ${nhp_subj}_${hemi}_stria_data.txt
		end
	end
end
	

		echo ".Hemisphere: "$hemi
		fslmaths ${sess}_${hemi}_StriaTerm_fdtNormMAXThres10_caret -bin ${sess}_${hemi}_striaTerm_Bin
		fslmaths ${sess}_${hemi}_striaTerm_Bin -kernel sphere $kernel_nhp -dilM ${sess}_${hemi}_striaTerm_Bin_sphere -odt int
	end
end

overlap:
# Add tracts and find overlap
echo "Creating overlapping tracts"
rm -f Allmonkeys*
fslmaths mi112_L_sc_amyg_Bin.nii.gz -add \
	mi114_L_sc_amyg_Bin.nii.gz -add \
	mi115_L_sc_amyg_Bin.nii.gz -add \
	mi117_L_sc_amyg_Bin.nii.gz -add \
#	mi119_L_sc_amyg_Bin.nii.gz -add \
	mi120_L_sc_amyg_Bin.nii.gz -add \
	mi121_L_sc_amyg_Bin.nii.gz -add \
	mi123_L_sc_amyg_Bin.nii.gz \
	Allmonkeys_L_sc_amyg_bin

fslmaths mi112_R_sc_amyg_Bin.nii.gz -add \
	mi114_R_sc_amyg_Bin.nii.gz -add \
	mi115_R_sc_amyg_Bin.nii.gz -add \
	mi117_R_sc_amyg_Bin.nii.gz -add \
#	mi119_R_sc_amyg_Bin.nii.gz -add \
	mi120_R_sc_amyg_Bin.nii.gz -add \
	mi121_R_sc_amyg_Bin.nii.gz -add \
	mi123_R_sc_amyg_Bin.nii.gz \
	Allmonkeys_R_sc_amyg_bin

# Add tracts and find overlap
fslmaths MI00112_L_StriaTerm_Bin.nii.gz -add \
	MI00114_L_StriaTerm_Bin.nii.gz -add \
	MI00115_L_StriaTerm_Bin.nii.gz -add \
	MI00117_L_StriaTerm_Bin.nii.gz -add \
	MI00119_L_StriaTerm_Bin.nii.gz -add \
	MI00120_L_StriaTerm_Bin.nii.gz -add \
	MI00121_L_StriaTerm_Bin.nii.gz -add \
	MI00123_L_StriaTerm_Bin.nii.gz \
	Allmonkeys_L_StriaTerm_bin
	
# Add tracts and find overlap
fslmaths MI00112_R_StriaTerm_Bin.nii.gz -add \
	MI00114_R_StriaTerm_Bin.nii.gz -add \
	MI00115_R_StriaTerm_Bin.nii.gz -add \
	MI00117_R_StriaTerm_Bin.nii.gz -add \
	MI00119_R_StriaTerm_Bin.nii.gz -add \
	MI00120_R_StriaTerm_Bin.nii.gz -add \
	MI00121_R_StriaTerm_Bin.nii.gz -add \
	MI00123_R_StriaTerm_Bin.nii.gz \
	Allmonkeys_R_StriaTerm_bin

# Add tracts with smoothing and find overlap
fslmaths mi112_L_sc_amyg_Bin_sphere.nii.gz -add \
	mi114_L_sc_amyg_Bin_sphere.nii.gz -add \
	mi115_L_sc_amyg_Bin_sphere.nii.gz -add \
	mi117_L_sc_amyg_Bin_sphere.nii.gz -add \
#	mi119_L_sc_amyg_Bin_sphere.nii.gz -add \
	mi120_L_sc_amyg_Bin_sphere.nii.gz -add \
	mi121_L_sc_amyg_Bin_sphere.nii.gz -add \
	mi123_L_sc_amyg_Bin_sphere.nii.gz \
	Allmonkeys_L_sc_amyg_bin_sphere

fslmaths mi112_R_sc_amyg_Bin_sphere.nii.gz -add \
	mi114_R_sc_amyg_Bin_sphere.nii.gz -add \
	mi115_R_sc_amyg_Bin_sphere.nii.gz -add \
	mi117_R_sc_amyg_Bin_sphere.nii.gz -add \
#	mi119_R_sc_amyg_Bin_sphere.nii.gz -add \
	mi120_R_sc_amyg_Bin_sphere.nii.gz -add \
	mi121_R_sc_amyg_Bin_sphere.nii.gz -add \
	mi123_R_sc_amyg_Bin_sphere.nii.gz \
	Allmonkeys_R_sc_amyg_bin_sphere

# Add tracts and find overlap
fslmaths MI00112_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00114_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00115_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00117_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00119_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00120_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00121_L_StriaTerm_Bin_sphere.nii.gz -add \
	MI00123_L_StriaTerm_Bin_sphere.nii.gz \
	Allmonkeys_L_StriaTerm_bin_sphere
	
# Add tracts and find overlap
fslmaths MI00112_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00114_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00115_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00117_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00119_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00120_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00121_R_StriaTerm_Bin_sphere.nii.gz -add \
	MI00123_R_StriaTerm_Bin_sphere.nii.gz \
	Allmonkeys_R_StriaTerm_bin_sphere	
	
goto exit

foreach slice (`seq 70 110`)
	rm -f slicemask.nii.gz
	set allslice = `fslval CaretBrain.nii.gz dim2`
	echo $slice
	fslmaths CaretBrain.nii.gz -roi 0 -1 0 $slice 0 -1 0 -1 slicemask.nii.gz
	@ x = ($slice + 2)
	fslmaths slicemask.nii.gz -roi 0 -1 0 $x $allslice -1 0 -1 slicemask${slice}
end


# 
foreach sess (MI00112 MI00114 MI00115 MI00117 MI00119 MI00120 MI00121 MI00123)
	echo $sess
	# Create mask coronal slices 70-110
	# Caret brain is x0-143, y0-187, z0-118
	
	
end

# Add tracts and find overlap
fslmaths mi112_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi114_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi115_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi117_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi119_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi120_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi121_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz -add \
	mi123_L_sc_amyg_fdtNormMAXThres10Bin_caret.nii.gz \
	Allmonkeys_L_sc_amyg_NormMAXThres10






foreach sess (mi112 mi114 mi115 mi117 mi119 mi120 mi121 mi123)
	fslmaths
	
goto exit














MI00112_L_StriaTerm_fdtNormMAXThres10_caret.nii




fslstats R_P1_final_onP2.nii.gz -k Mask1.nii.gz -C > RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P1_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P1_final_onP2.nii.gz -k Mask1.nii.gz -C  > LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P1_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt



fslstats R_P2_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P2_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P2_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P2_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt





fslstats R_P3_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P3_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P3_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P3_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt




fslstats R_P4_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P4_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P4_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P4_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt




fslstats R_P5_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P5_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P5_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P5_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt





fslstats R_P6_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P6_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P6_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P6_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt




fslstats R_P7_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P7_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P7_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P7_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt




fslstats R_P8_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P8_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P8_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P8_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt



fslstats R_P9_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P9_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P9_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P9_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt







fslstats R_P10_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P10_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P10_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P10_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt




fslstats R_P11_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P11_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P11_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P11_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt






fslstats R_P12_final_onP2.nii.gz -k Mask1.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask2.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask3.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask4.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask5.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask6.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask7.nii.gz -C  >> RCOG.txt
fslstats R_P12_final_onP2.nii.gz -k Mask8.nii.gz -C  >> RCOG.txt


fslstats L_P12_final_onP2.nii.gz -k Mask1.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask2.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask3.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask4.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask5.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask6.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask7.nii.gz -C  >> LCOG.txt
fslstats L_P12_final_onP2.nii.gz -k Mask8.nii.gz -C  >> LCOG.txt

exit:



