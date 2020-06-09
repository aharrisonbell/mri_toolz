#!/bin/tcsh
# @fixOrient.sh
# by AHB, started April 2015
# Version 1.0
# Script to fix orientation of files/masks from @Convert2nii

set in = $1
set out = $2

fslswapdim $in x z y $out
fslorient -deleteorient $out
fslorient -setqformcode 1 $out
rm temp1.nii.gz


