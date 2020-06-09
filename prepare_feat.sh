# prepare_feat
# USAGE: sh prepare_feat.sh <session folder> <subject name> <optional: number of volumes>


ID=$1
subj=$2
vols="${3:-"none"}"
session_folder=${ID:`expr ${#ID} - 7`}

# specific to study
anat=/Volumes/Bay_2/bolton/mk_fmri/anatomy/${subj}_anat_crop/structural_brain_restore.nii
path=/Volumes/Bay_2/bolton/mk_fmri/scans_3c2s/corrected_data/

# BC last update 20141217

# # # # # # 

path=${path}${session_folder}/
ID_path=${ID}/e*
cd $ID_path
ID_path=$(pwd)

mkdir ${path}
if [ "$vols" = "none" ]
then
	cp ${ID_path}/far.nii ${path}/
else
	fslroi ${ID_path}/far.nii ${path}/far 0 $vols
fi
cp ${anat} ${path}

cd $path


# Brain extract epi data
mkdir ${path}/bet
cp ${ID_path}/../ref_brain_mask.nii ${path}/bet
echo "Check the mask for brain extraction";echo ""; echo "";
fslmaths bet/ref_brain_mask -s 5 -thr 0.1 -bin bet/ref_brain_mask_loose
fslview far bet/ref_brain_mask_loose &
fslmaths far -mul bet/ref_brain_mask_loose far

fslmaths ${ID_path}/../align_anatomy/RresE -mul bet/ref_brain_mask ${path}/alt_ref

rm -r ${path}/bet
gzip ${path}/*.nii

echo ""; echo "Now ready for FEAT preprocessing and analysis"