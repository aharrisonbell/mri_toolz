#!/bin/bash
# Written by OJ, amended by AHB, June 22, 2015
files=`ls *meas*ep*.dat`
echo ".....Number of files: "
echo $files | wc -w
for i in $files
do
	# echo $i
	size=`ls -l $i| awk '{print $5}'`
	# echo `ls -lh $i| awk '{print $5}'`
	if (($size > 0)); 
	then
	#echo $i

	cmd0=`echo "getdate.sh $i"`
	date=`$cmd0`
	PatientID=`head -4000 $i | strings  | grep -n "\"PatientID\">" | awk -F"\"" '{print $4}'`
	subjectname=`head -4000 $i | strings  | grep -n "\"PatientName\">" | awk -F"\"" '{print $4}'`
	# siemens_to_ismrmrd
	basnameout=`echo "$i" | cut -d'.' -f1`
	FID=`echo "$i" | awk -F"_" '{print $NF}'| cut -d'.' -f1`
	mkdir -p $FID
	#rm -f $FID/*.h5
	outname=`echo "$FID/${subjectname}_${PatientID}_${FID}_${date}.h5"`
	testname=`echo "$FID/*.h5"`
	if [ -f $testname ]
	then 
		#rm $outname
		echo "......h5 file already exists -- skipping "$FID
	else
		echo "......Converting "$FID
		cmd=`echo "siemens_to_ismrmrd -f $i -x IsmrmrdParameterMap_Siemens_EPI.xsl -o $outname -X"`
		#echo $cmd 
		$cmd > /tmp/dump.txt
	fi	
fi
done	
