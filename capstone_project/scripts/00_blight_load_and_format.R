#################################################################
# Script Name: 00_blight_load_and_format.R
# Author: Jeremy Beck
# Date: 11/22/2016
# Description:  This script will load and format data for the UW
# 		Coursera Capstone project on understanding blight in cities.
#
#################################################################
library(stringr)
library(tidyr)
library(dplyr)
library(geohash)


#-----------------------------
# Helper Functions
#-----------------------------

# Write A Function to take a lat/lng pair and return all building associated with it 
retrieve_buildings <- function(lat, lng, dataset) {
	require(geohash)
	
	hash <- geohash::gh_encode(lat, lng, precision=8)
	print(hash) 
	
	return(subset(dataset, geohash == hash))
	
}

#-----------------------------
# Load in the Data Sets
#-----------------------------

# 311 Call Data
# Downloaded from https://data.detroitmi.gov/Government/Improve-Detroit-Submitted-Issues/fwz3-w3yn
call311_dat <- read.csv('./data/Improve_Detroit__Submitted_Issues.csv', header=T, na.strings='', stringsAsFactors=F)

# Blight Violations
# Downloaded from https://data.detroitmi.gov/Property-Parcels/Blight-Violations/teu6-anhh
blight_viols <- read.csv('./data/Blight_Violations.csv', header=T, na.strings='', stringsAsFactors=F)

# Demo Permits
# Downloaded from https://data.detroitmi.gov/Property-Parcels/Building-Permits/xw2a-a7tf
demo_permits <- read.csv('./data/Building_Permits.csv', header=T, stringsAsFactors=F)

# Crime Data
# Downloaded from https://data.detroitmi.gov/Public-Safety/DPD-All-Crime-Incidents-2009-Present-Provisional-/b4hw-v6w2
crime_dat <- read.csv('./data/DPD__All_Crime_Incidents__2009_-_Present__Provisional_.csv', header=T, na.strings='', stringsAsFactors=F)

# Detroit Land Parcels
# Downloaded from https://data.detroitmi.gov/Property-Parcels/Parcel-Points-Ownership/eijm-6nr4
parcel_data <- read.csv('./data/Parcel_Points_Ownership.csv', header=T, sep=',', na.strings='', stringsAsFactors=F)

#----------------------------
# Geohash Lat/Long Pairs
#----------------------------
# Geohashing houses with precision 8
# check out this site for a visual: http://www.movable-type.co.uk/scripts/geohash.html
# Alternatively, plug neighbors into the Haversine formula until you get a reasonable distance
# between neighbors

call311_dat$geohash <- gh_encode(call311_dat$lat, call311_dat$lng, 8)
call311_dat$unique_key <- paste0('call311_',seq(1,nrow(call311_dat)))

message('Violation Address has 22k with incorrect lat/long.  maybe look into using MailingAddress')
blight_viols <- blight_viols %>%
	mutate(coord = str_extract_all(ViolationLocation, "\\([^()]+\\)")) %>%
	transform(coord = gsub('[()]','', coord)) %>%
	separate(coord, c('lat', 'lng'), ', ') %>%
	mutate(geohash = gh_encode(as.numeric(lat), as.numeric(lng), 8),
				 unique_key = paste0('blightviol_',row_number()))

demo_permits <- demo_permits %>%
	filter(BLD_PERMIT_TYPE == 'Dismantle') %>%
	mutate(coord = str_extract_all(site_location, "\\([^()]+\\)")) %>%
	transform(coord = gsub('[()]','', coord),
						SITE_ADDRESS = gsub("\\s+", " ", SITE_ADDRESS)) %>%
	separate(coord, c('lat', 'lng'), ', ') %>%
	mutate(geohash = gh_encode(as.numeric(lat), as.numeric(lng), 8),
				 unique_key = paste0('demo_',row_number()))

crime_dat$geohash <- gh_encode(crime_dat$LAT, crime_dat$LON, 8)
crime_dat$unique_key <- paste0('crime_',seq(1,nrow(crime_dat)))


#--------------------------------------------------
# Create a Comprehensive List of Unique Properties
#--------------------------------------------------

all_props <- call311_dat %>%
	select(geohash, unique_key) %>% mutate(source = 'call311') %>% # 311 address is 'address'
	rbind({ blight_viols %>% select(geohash, unique_key) %>% mutate(source = 'viols')}) %>% # ViolationAddress
	rbind({ demo_permits %>% select(geohash, unique_key) %>% mutate(source = 'demos')}) %>% # site_location
	rbind({ crime_dat %>% select(geohash, unique_key) %>% mutate(source = 'crimes')}) # ADDRESS

length(unique(all_props$geohash))

unique_props <- all_props %>% dplyr::select(geohash) %>% unique()

# Check how frequently different geohashes appear in data sets
test <- all_props %>%
	group_by(geohash) %>%
	mutate(HASH_COUNT = n()) %>%
	ungroup() %>%
	group_by(geohash, source) %>%
	summarize(HASH_COUNT = max(HASH_COUNT),
						SOURCE_COUNT = n()) %>%
	arrange(desc(HASH_COUNT), geohash, desc(SOURCE_COUNT))

# Parcel List with flags from Demo Data by ParcelNo
parcel_data <- parcel_data %>%
	filter(!is.na(ParcelNo)) %>%
	transform(Latitude = as.numeric(Latitude),
						Longitude = as.numeric(Longitude)) %>%
	mutate(geohash = gh_encode(Latitude, Longitude, 8),
				 demo_flag = ifelse(ParcelNo %in% demo_permits$PARCEL_NO, 1, 0))

junk <- parcel_data %>% 
	group_by(geohash) %>%
	dplyr::summarize(COUNT = n()) %>%
	arrange(desc(COUNT)) %>%
	head(10)





																		