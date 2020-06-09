#!/bin/tcsh


set monkey=$1
if ($monkey == "RANGER") then 
	foreach sess_id (MI00937 MI00950 MI00962 MI00997 MI01005) # RANGER
		if ( -f "${monkey}_${sess_id}_motion_outliers.txt" ) then
			echo "file already exists for "${sess_id}
		else
			fsl_motion_outliers -i ${monkey}_${sess_id}_allruns_skullstripped_epimask.nii.gz -o ${monkey}_${sess_id}_motion_outliers.txt \
			-v -p ${monkey}_${sess_id}_motionOutliers_graph
		endif
	end
endif

if ($monkey == "SEB") then 
	foreach sess_id (MI00925 MI00931 MI00940 MI00953 MI01001) # SEB
		if ( -f "${monkey}_${sess_id}_motion_outliers.txt" ) then
			echo "file already exists for "${sess_id}
		else		
			fsl_motion_outliers -i ${monkey}_${sess_id}_allruns_skullstripped_epimask.nii.gz -o ${monkey}_${sess_id}_motion_outliers.txt \
			-v -p ${monkey}_${sess_id}_motionOutliers_graph
		endif
	end
endif

if ($monkey == "STEVIE") then 
	foreach sess_id (MI00932 MI00949 MI00952 MI00955 MI00959 MI01008) # STEVIE
		if ( -f "${monkey}_${sess_id}_motion_outliers.txt" ) then
			echo "file already exists for "${sess_id}
		else
			fsl_motion_outliers -i ${monkey}_${sess_id}_allruns_skullstripped_epimask.nii.gz -o ${monkey}_${sess_id}_motion_outliers.txt \
			-v -p ${monkey}_${sess_id}_motionOutliers_graph
		endif
	end
endif

if ($monkey == "SCOTTIE") then 
	foreach sess_id (MI00933 MI00943 MI00956 MI01009 MI01011) # SCOTTIE
		if ( -f "${monkey}_${sess_id}_motion_outliers.txt" ) then
			echo "file already exists for "${sess_id}
		else
			fsl_motion_outliers -i ${monkey}_${sess_id}_allruns_skullstripped_epimask.nii.gz -o ${monkey}_${sess_id}_motion_outliers.txt \
			-v -p ${monkey}_${sess_id}_motionOutliers_graph
		endif
	end
endif

