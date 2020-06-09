# USAGE
# 1) optional: open f.nii by fslview and choose the target volume (using fslview convention)
# 2) sh prepare_epi.sh <folder of the target 4D data>  <optional: target volume starting from 0>
# 3) edit the mask f_t_brain created in the session folder
# 4) on matlab, go to the session folder and run prepare_epi_mask to create overlay.dat 
# 5) Run Align_EPI script, ignore steps 1 and 2, IMPORTANT: in target volume should be +1, i.e. starting from 1

# BC, last update 20140331

path=$1;
cd $path/e*
path=$(pwd)
volume="${2:-"none"}"

FSLOUTPUTTYPE=NIFTI;

cd $path

if [ $volume = "none" ]; then
    fslmaths f.nii -Tmean mean_f
    echo ">>Calculating variance map"
    fslmaths f.nii -sub mean_f temp
    fslmaths temp -mul temp temp
    echo ">>Finding the best volume"
    fslmeants -i temp -o var.txt
     
    y=0;
    minx=999999999999999999
    for x in $(cat var.txt); do
        x=${x%.*};
        if [ $y -eq 1 ] ||  [ $x -lt $minx ]; then 
            minx=$x; miny=$y;
        fi;
        y=`expr $y + 1`;
    done; 
    volume=$miny
    echo ">>Target volume: (fsl) "$volume"   (jip)"`expr $volume + 1`
    fslroi f.nii ../f_t.nii $volume 1;
    echo ">>Check the volume, pass this volume to Align_EPI using JIP convention"
    fslview f ../f_t &
    read -p ">>ENTER to use the target volume as reference, CTRL+C to cancel"
    echo;
    echo;
    rm temp.nii
    rm mean_f.nii

else
    fslroi f.nii ../f_t.nii $volume 1
fi


if [ -f "../f_t_brain_mask.nii" ]
then
    echo ">>Warning: mask exists, continue to overwrite the mask? (Y/N)"
    while [ "$do_bet" != "y" ] && [ "$do_bet" != "n" ]
    do
        read -n1 do_bet
        echo
    done
else
    do_bet=y;
fi









### Correct orientation
do_swap=0
echo ">>Correct orientation for all images in the whole session? (Y/N)"
while [ "$do_swap" != "y" ] && [ "$do_swap" != "n" ]
do
    read -n1 do_swap
    echo
done

cd $path
cd ..
if [ "$do_swap" == "y" ]; then
    for input in `ls *nii`; do
        fslorient -deleteorient $input
        fslswapdim $input x -y z $input
        fslorient -setqformcode 1 $input
        echo "${input} corrected"
    done
    for input in `ls */*nii`; do
        fslorient -deleteorient $input
        fslswapdim $input x -y z $input
        fslorient -setqformcode 1 $input
        echo "${input} corrected"
    done
fi
#######

cd $path
cd ..
if [ "$do_bet" == "y" ]; then
    bet f_t.nii f_t_brain -f 0.3 -m;
fi
fslview f_t f_t_brain_mask &
echo ""; echo "";
echo ">>Now edit the mask, save it and then run the MATLAB script prepare_epi_mask in the session folder";
echo "";






