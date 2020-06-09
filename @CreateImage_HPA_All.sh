#!/bin/bash
# @CreateImage_HPA.sh
# by AHB, June 2014
version="1.24-06-2014"
# Basic script to create a tarball of all files necessary to conduct MATLAB analysis locally

# Need to copy the following:
# ~/Documents/MATLAB/HPA*
# ~/Documents/MATLAB/hpa_study/*
# ~/Documents/_Current_Projects/HPA_Study/matlab_data/*

rm -f ~/Desktop/All_HPA_Files.tar
tar cvf ~/Desktop/All_HPA_Files.tar ~/Documents/MATLAB/HPA*
tar rvf ~/Desktop/All_HPA_Files.tar ~/Documents/MATLAB/hpa_study/*
tar rvf ~/Desktop/All_HPA_Files.tar ~/Documents/_Current_Projects/HPA_Study/matlab_data/*
gzip ~/Desktop/All_HPA_Files.tar





