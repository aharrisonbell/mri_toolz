#!/bin/tcsh
# @GadgetronConvert.sh
# by AHB, started March 2015
set version = 1.24-06-2015
# Oxford Script

if ($1 == "-help") then
	echo " "
	echo "***********************************"
	echo "@GadgetronConvert.sh by AHB"$version
	echo "***********************************"
	echo " "
	echo "Script to reconstruct raw GRAPPA data into NIFTI files"
	echo "Requires: "
	echo "  -- Gadgetron be installed (running on 64-bit system, with NVIDIA card + CUDA"
	echo "  -- siemens_to_ismrmrd client"
	echo " "
	echo "INPUT: @GadgetronConvert.sh (OPTIONAL FOLDER FILTER)"
	echo " "
	echo "	(optional) = string to specify which folders to examine"
	echo "   e.g., @GadgetronConvert.sh RANGER* will only look at folders starting with RANGER"
	echo "Run this program from a directory containing several session directories (in the form of MONKEY_MI00XXX)"
	echo "Raw data SUBdirectories should be located within these and must begin with MI0***"
	echo "This program will ONLY PROCESS session folders that include a rawdata subdirectory"
	echo " "
	echo "This program will create small text files to indicate if a given step"
	echo "has already been completed."
	echo " "
	echo "This program requires that Gadgetron has been started in a separate terminal window!!"
	goto exit
endif

set rootdir = $PWD
set folderfilter='*_MI*'
set sequence_filter = ep2d_fmri_GRAPPA_asc
if ($#argv == 1) then
	folderfilter=$1
end

# Scroll through each directory looking
foreach datadir (`find ${folderfilter}/MI* -maxdepth 0 -type d`)
	cd ${rootdir}/${datadir}
	set subdatadir = `echo ${datadir:h}`
	echo " "
	echo "-->Processing "$subdatadir
	if (! -f ${rootdir}/done_1convert2ismrmrd_${subdatadir} ) then
		set datedone = `date +%Y-%m-%d`
		# Step 1 - convert to h5	
		echo "...Converting to *.h5 format"
		loop_convert2ismrmrd_ahb.sh # > ${rootdir}/done_1convert2ismrmrd_${subdatadir}
		echo "job done" > ${rootdir}/done_1convert2ismrmrd_${subdatadir}
	else
		echo "...Conversion to h5 already completed - skipping"
	endif

	# Step 2 - Gadgetron reconstruction 
	if (! -f ${rootdir}/done_2gadgetronrecon_${subdatadir}) then
		mkdir -p /tmp/gadget_recon_${subdatadir}
		mkdir -p ${rootdir}/${datadir}/gdt_nii_files
		foreach fiddir (`find FID** -type d`)
			echo "...Reconstructing "$fiddir
			mkdir -p /tmp/gadget_recon_${subdatadir}/gdt_${fiddir}
			cd /tmp/gadget_recon_${subdatadir}/gdt_${fiddir}
			rm -f *.nii.gz
			gadgetron_ismrmrd_client -f ${rootdir}/${datadir}/${fiddir}/*.h5 -c epi_gtplus_grappa_nhp.xml >> ${rootdir}/done_2gadgetronrecon_${subdatadir}
			
			# Step 3 - DICOMtoNIFTI (using dcm2nii)
			rm -f *.xml
			cd ..
			dcm2nii -g Y /tmp/gadget_recon_${subdatadir}/gdt_${fiddir} > /tmp/dump2.txt
			mv -f /tmp/gadget_recon_${subdatadir}/gdt_${fiddir}/*.nii.gz \
				${rootdir}/${datadir}/gdt_nii_files/${subdatadir}_${fiddir}.nii.gz
			echo "job done "$fiddir >> ${rootdir}/done_2gadgetronrecon_${subdatadir}
			rm -f *.dcm

		end	
		rm -Rf /tmp/gadget_recon_${subdatadir} # dangerous!!! (but necessary)	
	else #
		echo "...Gadgetron reconstruction already complete - skipping"
	endif
	
	cd ${rootdir}
end

goto exit


exit:
