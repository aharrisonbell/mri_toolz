# USAGE
# 1) sh prepare_anat.sh <folder of the target GRE, or session folder if borrow GRE> <subj name for retrieving structural> <optional: session folder of the GRE mask to be borrowed> <DOF for borrowing mask>  <optional: folder of the GRE to be borrowed, default: "none"> 
# 2) on matlab, go to the session folder and run prepare_anat_mask to create overlay_gre.dat and overlay_ref.dat 
# 3) Run Align_EPI script, ignore the steps for creating masks

# BC, last update 20140610

path=$(pwd)/${1};
current=$(pwd)/;


subj_name=$2;
anat_full=/Volumes/Bay_2/bolton/mk_fmri/anatomy/${subj_name}_anat/structural_restore.nii;
anat_crop=/Volumes/Bay_2/bolton/mk_fmri/anatomy/${subj_name}_anat_crop/structural_brain_restore.nii;

FSLOUTPUTTYPE=NIFTI
borrow_gre_mask_folder="${3:-"none"}"
if [ "$borrow_gre_mask_folder" != "none" ] ; then
    borrow_gre_mask_folder=${current}${borrow_gre_mask_folder}
fi
borrow_gre_folder="${5:-"none"}"
if [ "$borrow_gre_folder" != "none" ] ; then
    borrow_gre_folder=${current}${borrow_gre_folder}
fi

degree=$4
anat_path=${path}/align_anatomy/
# if [ "$borrow_gre_folder" != "none" ]; then
# 	# remove the last "/"
# 	if [ "${borrow_gre_folder:`expr ${#borrow_gre_folder} - 1`}" = "/" ]
# 	then
# 		borrow_gre_folder=${borrow_gre_folder:0:`expr ${#borrow_gre_folder} - 1`}
# 	fi
# 	cp -r ${borrow_gre_folder} ${path}
# fi

mkdir $anat_path
cp $anat_full $anat_path/brain.nii
echo "";

# Brain extract mean EPI

cd $path
cd e*
if [ -f "mask_fm.nii" ]
then
    echo ">>Warning: mask for mean EPI exist, continue brain extract EPI? (Y/N)"
    while [ "$do_bet" != "y" ] && [ "$do_bet" != "n" ]
    do
        read -n1 do_bet
        echo
    done
else
    echo ">>Creating mean EPI mask (mask_fm.nii)"
    cp fm.nii whole_fm.nii
    do_bet=y;
fi


if [ "$do_bet" == "y" ]; then
    cd $path
    cd e*
    echo
    
    if [ -f "whole_fm.nii" ]
    then
        echo
    else
        cp fm.nii whole_fm.nii
    fi
  
    f_num=0.5;
    while [ "$f_num" != "y" ] && [ "$f_num" != "e" ]
    do
        bet whole_fm fm -f $f_num -m
        mv fm_mask.nii mask_fm.nii
        echo "Check brain extracted mean EPI (f=${f_num}), you can consider editing the mask. Exit FSLVIEW when finished"
        fslview whole_fm mask_fm
        echo "Accept brain extraction? Y to accept the (edited) mask, 0.0 - 1.0 to adjust"
        read f_num
        echo
    done
    if [ "$f_num" == "y" ]; then
        fslmaths whole_fm -mul mask_fm fm
    fi
fi


use_f_t=n # not to borrow the EPI mask from f_t
if [ "$do_bet" == "y" ] && [ "use_f_t" == "y" ]
then
    flirt -in ../f_t -ref fm -out temp -omat mask_fm_xfm.mat -dof 6
    rm temp.n*
    flirt -in ../f_t_brain_mask -ref fm -applyxfm -init mask_fm_xfm.mat -out mask_fm
    fslmaths mask_fm -thr 0.5 mask_fm
    echo ">>Now edit the EPI mask. Brain extraction once exit FSLVIEW"
    echo
    fslview whole_fm mask_fm
    fslmaths whole_fm -mul mask_fm fm
fi





# borrow the whole GRE data
cd $path
if [ "$borrow_gre_folder" != "none" ] ; then
	# temp=$(pwd)
	# cd ${path}/gre_*
	# path=$(pwd)
	# cd $temp
    mkdir gre_99999
	flirt -in ${borrow_gre_folder}/../align_anatomy/E -ref align_anatomy/E -out gre_99999/temp -omat gre_99999/gre_xfm.mat -dof 6
	rm gre_99999/temp.ni*
	flirt -in ${borrow_gre_folder}/fg -ref ${borrow_gre_folder}/fg -applyxfm -init gre_99999/gre_xfm.mat -out gre_99999/fg
    flirt -in ${borrow_gre_folder}/fg_brain_mask -ref ${borrow_gre_folder}/fg -applyxfm -init gre_99999/gre_xfm.mat -out gre_99999/fg_brain_mask

	fslview gre_99999/fg gre_99999/fg_brain_mask align_anatomy/E &
	# fslview align_anatomy/E &
	echo ;echo ;echo 
	read -p ">>GRE data is borrowed, check alignment with EPI, press ENTER if good, CTRL C if bad"; echo""
    fslmaths gre_99999/fg_brain_mask -thr 0.5 -bin gre_99999/fg_brain_mask
	# cp gre_99999/fg.nii ${path}/../align_anatomy/G.nii
fi


echo;
echo $path
read -p ">>Now switch on the Align_Anatomy matlab script and Preprocess Volumes. Then press ENTER here"


# takes care of the anat here
cd $path
echo "Preparing anatomy mask"
flirt -in $anat_full -ref $anat_path/RresE -omat ref_brain_mat.mat -out ref_brain_full -dof 6
fslmaths $anat_crop -bin ref_brain_mask
flirt -in ref_brain_mask -ref $anat_path/RresE -applyxfm -init ref_brain_mat.mat -out ref_brain_mask
fslmaths ref_brain_mask -thr 0.3 -bin ref_brain_mask
rm ref_brain_full.nii


cd $path
if [ -f "fg_brain_mask.nii" ]; then
    echo "Warning: GRE mask exist! Replace old mask or not? (Y/N)"
    while [ "$rep_gre" != "y" ] && [ "$rep_gre" != "n" ]
    do
        read -n1 rep_gre
        echo
    done
    if [ "$rep_gre" == "n" ]; then
        echo
        echo ">>Now edit the GRE and REF masks and save them"
        fslview fg fg_brain_mask 
        fslview $anat_path/RresE ref_brain_mask 
        echo "";
        echo ${path}" done"
        echo ">>Now run the MATLAB script prepare_anat_mask in the session folder";
        echo ""
        exit
    fi
fi


# borrow GRE mask
cd $path
cd gre*
cp fg.nii ..
if [ "$borrow_gre_mask_folder" = "none" ] && [ "$borrow_gre_folder" = "none" ] ; then
	# No GRE mask to borrow, create one using bet
	bet fg fg_brain -f 0.3 -m;
elif [ "$borrow_gre_mask_folder" != "none" ]; then
	# Borrow a GRE mask
	echo "Borrowing a GRE mask";echo ""
	flirt -in ${borrow_gre_mask_folder}/fg -ref fg -out ../fg_refgre_flirt -omat fg_refgre_flirt.mat -dof  $degree
	flirt -in ${borrow_gre_mask_folder}/fg_brain_mask -ref fg -applyxfm -init fg_refgre_flirt.mat -out fg_brain_mask
	fslmaths fg_brain_mask -bin fg_brain_mask
fi

echo ">>Now edit the GRE and REF masks and save them"

cd $path
cd gre*
fslview fg fg_brain_mask 
cp fg_brain_mask.n* .. 
cd ..
fslview $anat_path/RresE ref_brain_mask 




echo "";
echo ${path}" done"
echo "Now run the MATLAB script prepare_anat_mask in the session folder";
echo "";


