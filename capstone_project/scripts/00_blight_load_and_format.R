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
# Load in the Data Sets
#-----------------------------

# 311 Call Data
call311_dat <- read.csv('./data/detroit-311.csv', header=T, na.strings='', stringsAsFactors=F)

# Blight Violations
blight_viols <- read.csv('./data/detroit-blight-violations.csv', header=T, na.strings='', stringsAsFactors=F)

# Demo Permits
demo_permits <- read.csv('./data/detroit-demolition-permits.tsv', header=T, sep='\t', na.strings='', stringsAsFactors=F)

# Crime Data
crime_dat <- read.csv('./data/detroit-crime.csv', header=T, na.strings='', stringsAsFactors=F)


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
	mutate(coord = str_extract_all(MailingAddress, "\\([^()]+\\)")) %>%
	transform(coord = gsub('[()]','', coord)) %>%
	separate(coord, c('lat', 'lng'), ', ') %>%
	mutate(geohash = gh_encode(as.numeric(lat), as.numeric(lng), 8),
				 unique_key = paste0('blightviol_',row_number()))

demo_permits <- demo_permits %>%
	mutate(coord = str_extract_all(site_location, "\\([^()]+\\)")) %>%
	transform(coord = gsub('[()]','', coord)) %>%
	separate(coord, c('lat', 'lng'), ', ') %>%
	mutate(geohash = gh_encode(as.numeric(lat), as.numeric(lng), 8),
				 unique_key = paste0('demo_',row_number()))

crime_dat$geohash <- gh_encode(crime_dat$LAT, crime_dat$LON, 8)
crime_dat$unique_key <- paste0('crime_',seq(1,nrow(crime_dat)))


#--------------------------------------------------
# Create a Comprehensive List of Unique Properties
#--------------------------------------------------

all_props <- call311_dat %>%
	select(geohash, unique_key) %>% # 311 address is 'address'
	rbind({ blight_viols %>% select(geohash, unique_key)}) %>% # ViolationAddress
	rbind({ demo_permits %>% select(geohash, unique_key)}) %>% # site_location
	rbind({ crime_dat %>% select(geohash, unique_key)}) # ADDRESS 

length(unique(all_props$geohash))

unique_props <- all_props %>% dplyr::select(geohash) %>% unique()

# Check how frequently different properties appear
all_props %>% 
	group_by(geohash) %>%
	summarize(COUNT = n()) %>%
	arrange(desc(COUNT)) %>%
	head(20)

# Parcel File obtained from the URL:
# https://data.detroitmi.gov/Property-Parcels/Parcel-Points-Ownership/eijm-6nr4/data
# This was used to map latitude and longitude to parcel number for missing permit data
# and also contains a wealth of information about sales prices, improvements, and cost
# per sq. foot. 

detroit_data <- read.csv('./data/Parcel_Points_Ownership.csv', header=T, sep=',', na.strings='', stringsAsFactors=F)

detroit_data <- detroit_data %>%
	transform(Latitude = as.numeric(Latitude),
						Longitude = as.numeric(Longitude)) %>%
	mutate(geohash = gh_encode(Latitude, Longitude, 8))

detroit_data %>% 
	group_by(geohash) %>%
	dplyr::summarize(COUNT = n()) %>%
	arrange(desc(COUNT)) %>%
	head(10)
																		