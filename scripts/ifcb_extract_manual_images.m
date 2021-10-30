% ifcb_extract_manual_images
%
% Extract manual images from each class
%

% Created on 2020-10-08 by AC

%% Set-up your database connection 

% update with your connection settings: database name, host, username, password 
DBC = db_connect('ifcb_mouw2','phytoplankton.upmc.edu','virginie', 'Restmonami');

%% Query your rois 

% OPTION 1: extract all manual images
query=['SELECT roi.id,manual_class.class_id FROM roi JOIN manual_class on manual_class.roi_id=roi.id'];
result=fetch(exec(DBC,query));
roi=result.Data;
close(result)
clear query result

% OPTION 2: extract images from a specific class with its id (here 65)
query=['SELECT roi.id,auto_class.class_id FROM roi JOIN auto_class on auto_class.roi_id=roi.id WHERE auto_class.class_id=65'];
result=fetch(exec(DBC,query));
roi=result.Data;
close(result)
clear query result

%% Export to a specific folder 

% OPTION 1: extract all images to the same folder 
% update the path where you want to store the images 
% if you try to export too many images at once, you might want to create a
% loop to not time out the connection to your database (and also know where
% you are at if you add a disp command!)
ifcb_extract_images(DBC, roi.id,'/Volumes/Desktop/IFCBdatabaseToEcotaxa/data/manual_images');


% OPTION 2: extract 100 random images from each class to a different folder
% update the path where you want to store the images 
[u,~,b]=unique(roi.class_id);
for uu=1:length(u)
    query=['SELECT classes.class FROM classes WHERE id=' num2str(u(uu))];
    result=fetch(exec(DBC,query));
    c=result.Data.class{1};
    close(result)
    clear query result
    
    % check if it is already a folder 
    if ~isfolder(fullfile(paths.manual,'extracted_images',c)); mkdir(fullfile(paths.manual,'extracted_images',c)); end
    
    % get 100 random images
    ind=find(b==uu);
    if length(ind)>100
        ind=ind(randi(length(ind),100,1));
    end
    
    ifcb_extract_images(roi.id(ind),fullfile(paths.manual,'extracted_images',c));
end


% OPTION 3: extract 100 random images from the selected class 
% update the path where you want to store the images 
[u,a,b]=unique(roi.class_id);
query=['SELECT classes.class FROM classes WHERE id=' num2str(u(1))];
result=fetch(exec(DBC,query));
c=result.Data.class{1};
close(result)
clear query result

% get 100 random images
ind=find(b==1);
if length(ind)>100
    ind=ind(randi(length(ind),100,1));
end

% extract the images 
ifcb_extract_images(roi.id(ind),'/Users/virginie/Desktop/thalassiosira/');

