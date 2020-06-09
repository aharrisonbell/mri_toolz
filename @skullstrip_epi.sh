#!/bin/tcsh
# @skullstrip_epi.sh
set version = 1.13-04-2016
# Script to generate conduct brain extraction on monkey brains using 3dSkullStrip

if ($#argv < 1) then
	echo " "
	echo "*******************************"
	echo "@skullstrip_epi.sh, V."$version
	echo "*******************************"
	echo " "
	echo "INPUT: @skullstrip_epi.sh <epi_vol> "
	echo "where: "
	echo "	-in <FILENAME> (mandatory): is the T2-weighted image to be brain-extracted (incl extension)" 
	goto exit
endif

set invol=$1
set mininvol=${invol:r}
echo "Skullstripping "$invol
3dSkullStrip -input ${invol} -prefix tempSSout -monkey -orig_vol
3dAFNItoNIFTI tempSSout+orig. 
fslmaths $invol -mas tempSSout.nii ${mininvol:r}_skullstripped
rm -f tempSSout*

exit:

