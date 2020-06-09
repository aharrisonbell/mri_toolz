#!/bin/bash
# @CreateImage_HPA_MATLAB.sh
# by AHB, created June 2014
version="1.11-07-2014"
# Basic script to create a tarball of all files necessary to conduct MATLAB analysis locally

# Need to copy the following:
# ~/Documents/MATLAB/HPA*
# ~/Documents/MATLAB/hpa_study/*

rm -f ~/Desktop/HPA_Matlab_Files.tar
tar cvf ~/Desktop/HPA_Matlab_Files.tar ~/Documents/MATLAB/HPA*
tar rvf ~/Desktop/HPA_Matlab_Files.tar ~/Documents/MATLAB/hpa_study/*
gzip ~/Desktop/HPA_Matlab_Files.tar





