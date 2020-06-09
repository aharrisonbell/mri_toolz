% 
% Function to generate .bvecs file from a Siemens format DiffusionVectors.txt file. 
%
% function [dirs] = generate_bvecs(infile,outbase);
%
%    input:  infile  - input file in Siemens format (default 'DiffusionVectors.txt')
%            outbase - basename for output files
%    output: dirs    - struct containing directions in file
%
% Karla Miller, University of Oxford
% 6 August 2007
%
function [dirs] = generate_bvecs(infile,outbase);

% default filenames
if (nargin<1) infile='DiffusionVectors.txt'; end;
if (nargin<2) outbase=strtok(infile,'.'); end;

% read in input file & propagate dirs cell array
fid=fopen(infile,'rt');
while ( ~feof(fid) )
    [c pos]=textscan(fid,'[directions=%d]');
    n=c{1};
    [c pos]=textscan(fid,'coordinatesystem[%d]=%s');
    [c pos]=textscan(fid,'normalisation[%d]=%s');
    [c pos]=textscan(fid,'vector[%d]=(%f,%f,%f)');
    norm=sqrt(c{2}.^2+c{3}.^2+c{4}.^2);
    in=c{1}; x=c{2}./norm; y=c{3}./norm; z=c{4}./norm;
    dirs{n}=[x y z];
end

% write out bvecs files
for j=1:length(dirs)
    if length(dirs{j}>0),
       fname=sprintf('%s_%02d.bvecs',outbase,j)
       fid=fopen(fname,'wt');
       fprintf(fid,'%1.8f ',dirs{j}(:,1)); fprintf(fid,'\n');
       fprintf(fid,'%1.8f ',dirs{j}(:,2)); fprintf(fid,'\n');
       fprintf(fid,'%1.8f ',dirs{j}(:,3)); fprintf(fid,'\n');
    end
end
