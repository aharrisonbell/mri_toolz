#!/bin/tcsh -f
# fmri_3dDeconvolve_template_localiser.sh
# by AHB, started July 2015
# Latest update July 14, 2015
# This script serves as a template that can be modified within Matlab
# to run a subject specific GLM for the LOCALISER project


# Script is modified by feeding in silly number of input arguments
set prefix = $1 # Used for naming the outputs
set inputvolume = $2
set maskfile = $3
set concatfile = $4
set motionfile = $5
set censorfile = $6
set stimprefix = $7


rm -f ${prefix}_MultiReg* ${prefix}_bucket*

3dDeconvolve -input ${inputvolume} \
-mask ${maskfile} \
-censor ${censorfile} \
-concat ${concatfile} \
-polort 3 \
-jobs 6 \
-num_stimts 11 \
-stim_file 1 ${stimprefix}0.1D'[1]' -stim_label 1 blank \
-stim_file 2 ${stimprefix}1.1D'[1]' -stim_label 2 faces \
-stim_file 3 ${stimprefix}2.1D'[1]' -stim_label 3 places \
-stim_file 4 ${stimprefix}3.1D'[1]' -stim_label 4 objects \
-stim_file 5 ${stimprefix}4.1D'[1]' -stim_label 5 scrambled \
-stim_file 6 ${motionfile}'[1]' -stim_label 6 roll -stim_base 6\
-stim_file 7 ${motionfile}'[2]' -stim_label 7 pitch -stim_base 7\
-stim_file 8 ${motionfile}'[3]' -stim_label 8 yaw -stim_base 8\
-stim_file 9 ${motionfile}'[4]' -stim_label 9 dS -stim_base 9\
-stim_file 10 ${motionfile}'[5]' -stim_label 10 dL -stim_base 10\
-stim_file 11 ${motionfile}'[6]' -stim_label 11 dP -stim_base 11\
-num_glt 12 \
-gltsym 'SYM: +faces +places +objects +scrambled' -glt_label 1 all_conds \
-gltsym 'SYM: +faces -places' -glt_label 2 faces-places \
-gltsym 'SYM: +faces -objects' -glt_label 3 faces-objects \
-gltsym 'SYM: +faces -scrambled' -glt_label 4 faces-scrambled \
-gltsym 'SYM: +places -objects' -glt_label 5 places-objects \
-gltsym 'SYM: +places -scrambled' -glt_label 6 places-scrambled \
-gltsym 'SYM: +objects -scrambled' -glt_label 7 objects-scrambled \
-gltsym 'SYM: +faces -scrambled \ +places -scrambled \ +objects -scrambled' -glt_label 8 allconds-scrambled \
-gltsym 'SYM: +faces +faces -places -objects' -glt_label 9 ani-inani \
-gltsym 'SYM: +faces -places \ +faces -objects' -glt_label 10  face-all \
-gltsym 'SYM: +places -faces \ +places -objects' -glt_label 11  place-all \
-gltsym 'SYM: +objects -faces \ +objects -places' -glt_label 12  object-all \
-fitts ${prefix}_MultiReg -fout -tout -full_first -nobout -bucket ${prefix}_bucket
