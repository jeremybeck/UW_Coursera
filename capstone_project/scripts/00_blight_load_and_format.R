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

call311_dat$geohash <- gh_encode(call311_dat$lat, call311_dat$lng, 10)
call311_dat$unique_key <- paste0('call311_',seq(1,nrow(call311_dat)))


blight_viols <- blight_viols %>%
	mutate(coord = str_extract_all(ViolationAddress, "\\([^()]+\\)")) %>%
	transform(coord = gsub('[()]','', coord)) %>%
	separate(coord, c('lat', 'lng'), ', ') %>%
	mutate(geohash = gh_encode(as.numeric(lat), as.numeric(lng), 10),
				 unique_key = paste0('blightviol_',row_number()))

demo_permits <- demo_permits %>%
	mutate(coord = str_extract_all(site_location, "\\([^()]+\\)")) %>%
	transform(coord = gsub('[()]','', coord)) %>%
	separate(coord, c('lat', 'lng'), ', ') %>%
	mutate(geohash = gh_encode(as.numeric(lat), as.numeric(lng), 10),
				 unique_key = paste0('demo_',row_number()))

crime_dat$geohash <- gh_encode(crime_dat$LAT, crime_dat$LON, 10)
crime_dat$unique_key <- paste0('crime_',seq(1,nrow(crime_dat)))



#--------------------------------------------------
# Create a Comprehensive List of Unique Properties
#--------------------------------------------------




																		