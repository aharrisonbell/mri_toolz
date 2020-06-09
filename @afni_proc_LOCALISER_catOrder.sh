#!/bin/tcsh
# @afni_proc_LOCALISER_catOrder.sh
# by AHB, started July 26, 2016
set version = 1.27-06-2016

if ($#argv < 1) then
	echo " "
	echo "*********************************"
	echo "@afni_proc_LOCALISER_catOrder by AHB"$version
	echo "*********************************"
	echo " "
	echo "Script to perform preprocessing and GLM analysis on a single session's worth of"
	echo "fMRI data from the LOCALISER task."
	echo " "
	echo "INPUT: @afni_proc_LOCALISER.sh ..."
	echo "	-sess_id <SESSION ID>"
	echo "	-firstRun <first run number>"
	echo "	-lastRun <last run number>"
	echo "	-tr <TR>"
	echo "	-baseRun <volume number to align all other volumes>"
	echo "	-MONKEY <MONKEY NAME IN UPPER CASE>"
	echo "	-monkey <monkey name in lower case>"
	echo " "
	goto exit
endif

# Set Defaults
set session=$1
set firstRunNum=3
set lastRunNum=15
set baseRun=005
set tr=2
set monkey_uc=RANGER
set monkey_lc=ranger

set numSlices=31

# Read in flags
set numarg = `expr $#`
set cnt = 0
while ($cnt < $numarg)
	switch ($1) 
	case -sess_id:
		set session=$2
		breaksw
	case -firstRun:
		set firstRunNum=$2
		breaksw
	case -lastRun:
		set lastRunNum=$2
		breaksw
	case -tr:
		set tr=$2
		breaksw
	case -baseRun:
		set baseRun=$2
		breaksw
	case -MONKEY:
		set monkey_uc=$2
		breaksw
	case -monkey:
		set monkey_lc=$2
		breaksw
	default:
	endsw
	set cnt = `expr $cnt + 1`
	shift
end
set subj=${monkey_lc}_${session}

# PART 0 : Setup defaults 

mkdir -p ./tmp/ # make sure tmp directory exists

# PART 1.1 : Convert to AFNI format; Skullstrip; Correct TR
foreach run (`count $firstRunNum $lastRunNum -digits 3`)
	if ( -f "./rundata/${subj}_run${run}_ss+orig.HEAD" ) then 
		echo "Files already exist - skipping "$run
	else
		rm -f ./rundata/${subj}_run${run}*+orig* ./rundata/${subj}_run${run}*+orig.*
		
		echo "** Converting NIFTIs to AFNI format, run "${run}
		3dcalc -a ./rundata/${monkey_uc}_${session}_run${run}.nii.gz -expr 'a' -prefix ./rundata/tmp/${subj}_run${run}_temp
		3dTcat -tr ${tr} -prefix ./rundata/${subj}_run${run} ./rundata/tmp/${subj}_run${run}_temp+orig.
		
		echo "** Skullstripping, run "${run}
 		3dSkullStrip -input ./rundata/${subj}_run${run}+orig. -monkey -orig_vol \
 			-prefix ./rundata/${subj}_run${run}_ss_mask
 		3dcalc -a ./rundata/${subj}_run${run}_ss_mask+orig. -b ./rundata/${subj}_run${run}+orig. \
 			-expr '(a/a)*b' -prefix ./rundata/${subj}_run${run}_ss+orig.
		
		# echo "** Masking with epimask used during Hauke Kolster recon, run "${run}
 		# 3dcalc -a ./rundata/${subj}_run${run}+orig. -b ${subj}_epimask.nii.gz \
 		#	-expr '(b/b)*a' -prefix ./rundata/${subj}_run${run}_ssM
 		rm -f ./rundata/tmp/${subj}_run${run}_temp+orig.*
	endif
end

# PART 1.2 : Preprocessing
rm -f proc.${subj} # remove any pre-existing proc.* files
rm -Rf ${subj}_catOrder.results # remove any results directory

echo "Generating afni_proc_script"
afni_proc.py -verb 2 -subj_id ${subj}_catOrder -dsets ./rundata/${subj}_run*_ss+orig.HEAD \
	-copy_files ./rundata/${subj}_run${baseRun}+orig.HEAD ./rundata/${subj}_run${baseRun}+orig.BRIK \
		./rundata/${subj}_run${baseRun}_ss+orig.HEAD ./rundata/${subj}_run${baseRun}_ss+orig.BRIK \
#	-check_results_dir no \
	-bash \
	-blocks tcat despike volreg blur mask scale regress \
	-outlier_count yes \
	-test_stim_files yes \
	-despike_mask \
	-volreg_compute_tsnr yes \
	-volreg_interp -quintic \
	-volreg_zpad 4 \
	-blur_size 3 \
	-mask_dilate 3 \
	-mask_apply epi \
	-regress_censor_motion 0.3 \
	-regress_compute_tsnr yes \
	-regress_censor_outliers 0.1 \
	-regress_apply_mot_types demean deriv \
	-regress_run_clustsim yes \
	-regress_est_blur_errts \
	-regress_stim_labels faces places objects scrambled \
	-regress_stim_files \
		./stimfiles/${monkey_uc}_${session}_CatOrderStim1_Faces.txt \
		./stimfiles/${monkey_uc}_${session}_CatOrderStim2_Places.txt \
		./stimfiles/${monkey_uc}_${session}_CatOrderStim3_Objects.txt \
		./stimfiles/${monkey_uc}_${session}_CatOrderStim4_Scrambled.txt \
	-regress_opts_3dD \
		-jobs 4 \
		-num_glt 11 \
		-gltsym 'SYM: +faces +places +objects +scrambled' -glt_label 1 all_conds \
		-gltsym 'SYM: +faces -places' -glt_label 2 faces-places \
		-gltsym 'SYM: +faces -objects' -glt_label 3 faces-objects \
		-gltsym 'SYM: +faces -scrambled' -glt_label 4 faces-scrambled \
 		-gltsym 'SYM: +places -objects' -glt_label 5 places-objects \
 		-gltsym 'SYM: +places -scrambled' -glt_label 6 places-scrambled \
 		-gltsym 'SYM: +objects -scrambled' -glt_label 7 objects-scrambled \
 		-gltsym 'SYM: +faces -0.5*places -0.5*objects' -glt_label 8 faces-allconds \
 		-gltsym 'SYM: -0.5*faces +places -0.5*objects' -glt_label 9 places-allconds \
 		-gltsym 'SYM: -0.5*faces -0.5*places +objects' -glt_label 10 objects-allconds \
 		-gltsym 'SYM: +faces -scrambled \ +places -scrambled \ +objects -scrambled' -glt_label 11 allconds-scrambled_corr \
		-progress 10000 \
	-regress_polort 2 \
	-move_preproc_files \
	-scr_overwrite \
	-execute


#	-fitts ${subj}_MultiReg -fout -tout -full_first -nobout -bucket ${subj}_bucket
#	-write_3dD_script ${monkey_lc}_${session}_deconvolve.sh
