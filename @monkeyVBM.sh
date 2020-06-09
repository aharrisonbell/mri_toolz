#!/bin/tcsh
# @monkeyVM
set version = 1.05-02-2015
# Performs voxel-based morphometry analysis on monkey data, using FSL


####################################################################################################
#       SET UP VARIABLES HERE*
#
# Directories
set home_dir = $PWD
set orig_dir = $PWD/orig_data
set scriptdir = ~/Documents/_Current_Projects/scripts # specifies location of TOPUP, etc.
set email = "andrew.bell@psy.ox.ac.uk"
#
# Standard Atlases
set caret_atlas = ~/Documents/_Current_Projects/caret_brain/caretbrain.nii.gz
set mni_dir = ~/Documents/_Current_Projects/mni_brain/
set caret_priors_dir = ~/Documents/_Current_Projects/caret_brain/F99_data/
set GM_pve_prior = ~/Documents/_Current_Projects/caret_brain/F99_data/struct_brain_pve_1.nii.gz
set GM_seg_prior = ~/Documents/_Current_Projects/caret_brain/F99_data/struct_brain_seg_1.nii.gz
#
# Program Options
set REV_OPTION = "y" # (y/n) - calls up FSLVIEW window after each step (USEFUL!!)
set AFNI_OPTION = "n" # (y/n) - includes AFNI-based skull stripping.  Useful to compare
#
# *so non-coders, don't f**k with stuff below this section and then complain to me that
#  the code doesn't work :)
####################################################################################################

if ($#argv == 0) then
	echo " "
	echo "*******************************"
	echo "@monkeyVBM, V."$version
	echo "*******************************"
	echo " "
	echo "INPUT: @monkeyVBM -prefix <string> -reg <a/n> -step <step> -template <template>"
	echo "where: "
	echo "	-prefix <STRING> (mandatory): is the prefix for all files to be included in template" 
	echo "	-reg <a/n> (optional): calls for (a)ffine or (n)on-linear registration (affine is default)" 
	echo "  -template <filename> (optional): use following files as templates (no extension)"
	goto exit
endif

# Steps in VBM analysis (adapted from FSL-VBM scripts)
# 1) Move all skull-stripped data to single directory (masks, segmented volumes, T1s)
# 2) Examine Data to make sure segments are good
# 3) Create study-specific GM template
# 3a) align all GM to template (in this case we will use 
#

# Establish Defaults
set reg = a
set step = 0
set template=$PWD/template.txt

# Read in flags
set numarg = `expr $#`
set cnt = 0
while ($cnt < $numarg)
	switch ($1) 
	case -prefix:
		set prefix=$2
		breaksw
	case -reg:
		set reg=$2
		breaksw
	case -step:
		set step=$2
		breaksw
	case -template:
		set template=$2
		breaksw
	default:
	endsw
	set cnt = `expr $cnt + 1`
	shift
end

# Prepare and clean directories
mkdir -p $PWD/temp
mkdir -p $PWD/orig_data
set temp_dir = $PWD/temp

# Step 1 - align all volumes to standard GM volume (F99)
if ($step =~ *1* || $step == 0) then
	rm -f $PWD/template.txt
	echo > $PWD/template.txt
	mkdir -p $PWD/align2template
	foreach f (`ls ${orig_dir}/${prefix}*_StrippedAnat_native_pve_1.nii.gz`)
		set fname = `basename $f`
		set pref = `echo $f:r:t:r`
		echo "Aligning $fname to template"
		#fsl_reg $f $GM_pve_prior $PWD/align2template/${pref}_align2temp -$reg
		echo $PWD/align2template/${pref}_align2temp >> $PWD/template.txt
	end
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then
		fslview $GM_pve_prior $PWD/align2template/*_align2temp.nii.gz &
	endif
	echo "Be sure to appropriately edit TEMPLATE.TXT"
endif
	
# Step 2 - Create template volume by concatenating and averaging volumes listed in $template
if ($step =~ *2* || $step == 0) then
	# First Pass template creation
	echo "Using $template for firstpass template creation"
	fslmerge -t template_4D_GM `more $template.txt`
	fslmaths template_4D_GM -Tmean template_GM
	fslswapdim template_GM -x y z template_GM_flipped
	fslmaths template_GM -add template_GM_flipped -div 2 template_GM_init
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then
		fslview template_GM_init &
	endif
		
	# Second pass alignment 
	rm -f $PWD/template_init.txt
	echo > $PWD/template_init.txt
	foreach f (`ls ${orig_dir}/${prefix}*_StrippedAnat_native_pve_1.nii.gz`)
		set fname = `basename $f`
		set pref = `echo $f:r:t:r`
		echo "Aligning $fname to study specific (INIT) template"
		#fsl_reg $f template_GM_init $PWD/align2template/${pref}_GM_to_T_init -$reg
		echo $PWD/align2template/${pref}_GM_to_T_init >> $PWD/template_init.txt
	end
endif

if ($step =~ *3* || $step == 0) then
	# Second pass template creation
	echo "Using ${template}_init for secondpass template creation"
	fslmerge -t template_4D_GM `more ${template}_init.txt`
	fslmaths template_4D_GM -Tmean template_GM
	fslswapdim template_GM -x y z template_GM_flipped
	fslmaths template_GM -add template_GM_flipped -div 2 template_GM_init
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then
		fslview template_GM &
	endif
endif


if ($step =~ *4* || $step == 0) then
	# Preprocessing of data
	mkdir -p ${PWD}/jac
	foreach f (`ls ${orig_dir}/${prefix}*_StrippedAnat_native_pve_1.nii.gz`)
		set fname = `basename $f`
		set pref = `echo $f:r:t:r`
		echo "Preprocessing $fname"
		#fsl_reg $f template_GM $PWD/jac/${pref}_GM_to_template_GM -fnirt "--config=/Users/ab03/Documents/_Current_Projects/caret_brain/F99_data/GM_2_caretGM_1mm.cnf --jout=${PWD}/jac/${pref}_JAC_nl"
        fslmaths $PWD/jac/${pref}_GM_to_template_GM -mul $PWD/jac/${pref}_JAC_nl $PWD/jac/${pref}_GM_to_template_GM_mod -odt float
	end
	if ($REV_OPTION == "y" || $REV_OPTION == "Y") then
		fslview template_GM.nii.gz $PWD/jac/*_GM_to_template_GM.nii.gz &
	endif
endif

if ($step =~ *5* || $step == 0) then
	# Preprocessing of data
	cd $home_dir
	mkdir -p ${home_dir}/stats
    imcp template_GM ${home_dir}/stats/template_GM
	echo "Concatenate preprocessed volumes"
    #fslmerge -t ./stats/GM_merg `imglob ${home_dir}/jac/*_GM_to_template_GM.*`
    #fslmerge -t ./stats/GM_mod_merg `imglob ${home_dir}/jac/*_GM_to_template_GM_mod.*`
	#fslmaths ./stats/GM_merg -Tmean -thr 0.01 -bin ./stats/GM_mask -odt char

	cp $home_dir/design.* ${home_dir}/stats
	cd stats

cat <<stage_preproc2 > fslvbm3b
#!/bin/sh
	
for i in GM_mod_merg ; do
  for j in 2 3 4 ; do
    \$FSLDIR/bin/fslmaths \$i -s \$j \${i}_s\${j} 
    \$FSLDIR/bin/randomise -i \${i}_s\${j} -o \${i}_s\${j} -m GM_mask -d design.mat -t design.con -V
  done
done			
stage_preproc2
chmod a+x fslvbm3b

#fslvbm3b_id=`${FSLDIR}/bin/fsl_sub -T 15 -N fslvbm3b -j $fslvbm3a_id ./fslvbm3b`

#echo Doing subject concatenation and initial randomise: ID=$fslvbm3b_id



endif












