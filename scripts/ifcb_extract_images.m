function ifcb_extract_images(DBC, roi_id, extract_path)

% ifcb_extract_images(roi_id, extract_path)
%
% Extract images and save as .png files. Based on roi_id, will retrieve
% file names and go get specified images. Assumes data are on data optics. 
%
% Inputs:
%  DBC          = database connection, database.jdbc.connection
%  roi_id       = ids from roi table 
%  extract_path = full path where extracted images will be stored, make
%                 this local to your machine
%

% Created on 2017-06-23 by ABC, updated 2018-06-05 by AC
% Modified on 2021-10-27 by VS

%% Get file names and locations

query=['SELECT raw_files.path,raw_files.filename,roi.roi_number FROM roi JOIN raw_files ON raw_files.id=roi.raw_file_id WHERE ' db_make_or_clause('roi.id',num2cell(roi_id))];
result=fetch(exec(DBC,query));
dat=result.Data;
close(result);
clear query result

%% Heidi's code is not a batch processing script, only does one file at a time

[u,a,b]=unique(dat.filename);
for uu=1:length(u)
    export_png_from_ROIlist(fullfile(dat.path{a(uu)},u{uu}(1:end-4)),extract_path,dat.roi_number(b==uu));
end
