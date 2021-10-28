% ifcb_extract_manual_images
%
% Extract manual images from each class
%

% Created on 2020-10-08 by AC

%% Set-up your database connection 

DBC = db_connect(db='ifcb_mouw2',server='phytoplankton.upmc.edu',user='virginie', pswd='Restmonami');
DBC = db_connect(db='ifcb_mouw2',server='phyto-optics.gso.uri.edu',user='virginie', pswd='SummerAtTheBeach');

%% Query your rois 

% OPTION 1: extract all manual images
query=['SELECT roi.id,manual_class.class_id FROM roi JOIN manual_class on manual_class.roi_id=roi.id'];
result=fetch(exec(DBC,query));
roi=result.Data;
close(result)
clear query result

% OPTION 2: extract images from a specific class with its id (here 65)
% query=['SELECT roi.id,auto_class.class_id FROM roi JOIN auto_class on auto_class.roi_id=roi.id WHERE auto_class.class_id=65'];
% result=fetch(exec(DBC,query));
% roi=result.Data;
% close(result)
% clear query result

%% Export to a specific folder 

% OPTION 1: extract all images to the same folder 
% indicate the path where you want to store the images 
ifcb_extract_images(DBC, roi.id,'/../data/manual_images/');


% OPTION 2: extract 100 random images from each class to a different folder
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
    try
        ifcb_extract_images(roi.id(ind),'/Users/audrey/Desktop/class_bad/');
    catch
        continue;
    end
end


% OPTION 3: extract 100 random images from the selected class 
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

