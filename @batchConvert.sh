#!/bin/tcsh
# @batchConvert.sh
# Uses AFNI, FSL, etc. to preprocess fMRI data
# by AHB, started April 2015
set version = 1.10-04-2015
# Oxford Script

if ($1 == "-help") then
	echo " "
	echo "***********************************"
	echo "@batchConvert.sh by AHB"$version
	echo "***********************************"
	echo " "
	echo "Run this script in a directory containing multiple subdirectories."
	echo "Each subdirectory should contain *MI00* and itself, a subdirectory called"
	echo "nii_files.  If it doesn't the program will attempt to create nii_files."
	echo " "
	goto exit
endif

set rootdir = $PWD
foreach datadir (`find ./ -name '*_MI*' -type d`)
	set dirname = $datadir:t
	echo "Processing "$dirname
	cd $dirname
	set datedone = `date +%Y-%m-%d`
	
	# Step 1 - convert dicoms to nifti using @Convert2nii
	if ( -e ${rootdir}/done_1convert2nifti_${dirname} == 1) then
		
		echo "...Conversion to nifti already completed - skipping"
		
	else # if done flag does not exist...
		set dicomdir = `find ./ \( -name 'dic*' -type d -o -name 'MAC*' -type d \)`
		set dicomname = $dicomdir:t
		echo $dicomname
		@Convert2nii $dicomname nii_files # > ${rootdir}/done_1convert2nifti_${dirname}
		echo "job done "$datedone >> ${rootdir}/done_1convert2nifti_${dirname}
	endif

	cd $rootdir
	
end # directory



exit:
