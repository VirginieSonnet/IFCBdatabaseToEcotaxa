###############################
# Images metadata for EcoTaxa # 
###############################

# Goal: query all the necessary information to fill an input file for 
#       EcoTaxa for manually classified images 

# 1. Connect to the database 
# 2. Query the required information 
# 3. Fill in the columns to match Ecotaxa 
# 4. Export to tsv 

# Input: file example_columns_ecotaxa.tsv
# Output: file ecotaxa_manual_images.tsv

# Created by Virginie Sonnet on 2021-10-31 

rm(list=ls())
gc()

library(tidyverse) # data manipulation 
library(RMySQL) # database 
library(stringr) # strings manipulation => development version for str_split_n function
library(lubridate) # date manipulation


# 1. Database connection -----------------------------------------------------

Sys.setenv(MYSQL_PWD_VIRGINIE="pwd") 
db <- dbConnect(MySQL(),dbname="ifcb_mouw2", host="host.data.uri.edu", 
                port=3306, user="user", password=Sys.getenv("MYSQL_PWD_VIRGINIE"))


# 2. Query  ------------------------------------------------------------------

# reference columns 
ex <- read_tsv("data/example_columns_ecotaxa.tsv")

# new table 
ecotaxa <- ex[-c(2:5),]

# query 
y <- dbGetQuery(conn = db, statement = "SELECT class_ecotaxa,  first, last, 
                serial_no, latitude, longitude, location, depth,filename,
                date,mL_counted,qc_file, roi.* FROM manual_class
JOIN people ON manual_class.people_id=people.id
JOIN classes ON manual_class.class_id=classes.id
JOIN raw_files ON manual_class.raw_file_id=raw_files.id
JOIN deployments ON raw_files.deployment_id=deployments.id
JOIN instruments ON deployments.instrument_id=instruments.id
JOIN locations ON raw_files.location_id=locations.id
JOIN depths ON raw_files.depth_id=depths.id
JOIN roi ON manual_class.roi_id=roi.id;")
x <- y 

# 3. Fill in the columns  ---------------------------------------------------

#### update email in database


# add fixed columns 
# -> no need to add them all, and update for your database and case
x <- x %>% 
    add_column(object_link="http://phyto-optics.gso.uri.edu:8888/GSODock",
               object_depth_max=0,
               object_annotation_status="validated",
               object_annotation_person_email="sonnet.virginie@neuf.fr",
               object_annotation_date=format(Sys.Date(),"%Y%m%d"), 
               object_annotation_time=format(Sys.time(),"%H%M%S"),
               object_annotation_hierarchy=NA_character_,
               sample_dataportal_descriptor=NA_character_,
               sample_source="flowthrough",
               sample_vessel="NO VESSEL",
               sample_reference=NA_character_,
               sample_station=NA_character_,
               sample_cast=NA_integer_,
               sample_source_id=NA_character_,
               sample_culture_species=NA_character_,
               sample_concentration=NA_real_,
               process_id=NA_character_,
               process_soft="MATLAB",
               process_soft_version="2021b",
               process_script="IFCBdatabaseToEcoTaxa",
               process_script_version=1,
               process_library="ifcb_analysis",
               process_library_version=3,
               process_date=format(Sys.Date(),"%Y%m%d"), 
               process_time=format(Sys.time(),"%H%M%S"),
               acq_instrument="IFCB",
               acq_resolution_pixels_per_micron=3.4)
               

# rename columns 
x <- x %>% 
    rename(object_annotation_category=class_ecotaxa, 
           sample_flag=qc_file,
           sample_cruise=location,
           object_depth_min=depth,
           object_lat=latitude,
           object_lon=longitude) %>% 
    rename_with(~paste("object",.,sep="_"), roi_number:fluor_peak)

# combine columns 
x <- x %>% 
    # roi_number
    mutate(object_roi_number=as.character(object_roi_number)) %>% 
    mutate(object_roi_number=case_when(str_length(object_roi_number)==1 ~ paste("0000",object_roi_number,sep=""),
                         str_length(object_roi_number)==2 ~ paste("000",object_roi_number,sep=""),
                         str_length(object_roi_number)==3 ~ paste("00",object_roi_number,sep=""),
                         str_length(object_roi_number)==4 ~ paste("0",object_roi_number,sep=""),
                         TRUE ~ as.character(object_roi_number))) %>% 
    # object_id
    mutate(object_id=paste(str_split_n(filename,".r", 1),object_roi_number,sep="_")) %>%
    # img_file_name
    mutate(img_file_name=paste(object_id,"png",sep=".")) %>% 
    # date and time 
    mutate(object_date=str_remove_all(str_split_n(date," ",1),"-"),
           object_time=str_remove_all(str_split_n(date," ",2),":")) %>% 
    # annotation person 
    mutate(object_annotation_person_name=paste(first,last)) %>% 
    # sample_id 
    mutate(sample_id=paste(sample_cruise,sample_source,object_id,
                           str_split(filename,".r", n = 1),sep="_")) %>% 
    # acq_id 
    mutate(acq_id=paste("IFCB_MOUW",sample_id,sep="_"))
    
# change the uppercase to underscore+lowercase 
colnames(x) = tolower(gsub("(?<=[a-z0-9])(?=[A-Z])", "_", colnames(x), perl = TRUE))

# remove the columns not necessary
setdiff(colnames(x),colnames(ecotaxa))
x <- select(x, -setdiff(colnames(x),colnames(ecotaxa)))


# 4. Export -----------------------------------------------------------------

# convert all to characters 
x <- mutate_all(x, as.character)

# combine the two datasets 
ecotaxa = bind_rows(ecotaxa, x)

# export
write_tsv(ecotaxa,"data/manual_images/ecotaxa_manual_images.tsv")
