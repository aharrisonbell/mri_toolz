#!/bin/tcsh
# @fixOrient.sh
# by AHB, started April 2015
# Version 1.0
# Script to fix orientation of files/masks from @Convert2nii

set in = $1
set out = $2

$FSLDIR/bin/fslswapdim $in -x z y tempvolume1
$FSLDIR/bin/fslorient -deleteorient tempvolume1
$FSLDIR/bin/fslorient -setqformcode 1 tempvolume1

fslswapdim tempvolume1 x z y $out
fslorient -deleteorient $out
fslorient -setqformcode 1 $out
rm tempvolume1.nii.gz


