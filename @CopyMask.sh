#!/bin/tcsh
# @CopyMask
# by AHB, started March 2012
# Version 1.0
# Script to fix orientation of files/masks analysed by MNoonan (i.e., orientation correction left until the end)

if ($#argv < 2) then
	echo " "
	echo "******************************"
	echo "@CopyMask by AHB, V.04.22.2012"
	echo "*******************************"
	echo " "
	echo "Script to copy a STRUCTURAL MASK to DTI and EPI data, by aligning the structural mask"
	echo "to the output of BET (automatic skull stripping)
	echo " "
	echo "INPUT: @FixOrient <INPUT_FILE> <OUTPUT_FILE>"
	echo " "
	goto exit
endif

set in = $1
set ref = $2
set out = $3

flirt -in $1 -ref ${session_name}_TopUpData_60dirs_fix.nii.gz -out $3
flirt -in $1 -ref ${session_name}_TopUpData_60dirs_fix.nii.gz -dof 6 -out $3
flirt -in $1 -ref ${session_name}_TopUpData_60dirs_fix.nii.gz -2D -out $3


flirt -in $1 -ref ${session_name}_betmask_raw.nii.gz -out $3
flirt -in $1 -ref ${session_name}_betmask_raw.nii.gz -dof 6 -out $3
flirt -in $1 -ref ${session_name}_betmask_raw.nii.gz -2D -out $3
