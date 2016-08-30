library(dplyr)
library(ggplot2)
library(lubridate)
#library(ggmap)

#------------------------
# Data Load
#------------------------
wd_path <- '~/Library/Mobile\ Documents/com~apple~CloudDocs/UW_Coursera/datasci_course_materials/assignment6/'

sf_dat <- read.csv(paste0(wd_path,'sanfrancisco_incidents_summer_2014.csv'), 
									 stringsAsFactors=F, header=T, sep=',')

seattle_dat <- read.csv(paste0(wd_path, 'seattle_incidents_summer_2014.csv'), 
												stringsAsFactors=F, header=T, sep=',')


#-------------------------------
# Basic Date/Time Processing & Crime Codes
#-------------------------------
crime_codes <- read.csv(paste0(wd_path, 'offense_codes.csv'), header=T, stringsAsFactors=F)
crime_codes$OFFENSE_CODE <- as.character(crime_codes$OFFENSE_CODE)
crime_codes <- crime_codes %>%
	select(OFFENSE_CODE, OFFENSE_CATEGORY_NAME)
crime_codes <- crime_codes[!duplicated(crime_codes$OFFENSE_CODE),]

seattle_dat <- seattle_dat %>%
	transform(Date = mdy(substr(Occurred.Date.or.Date.Range.Start,1,10)),
						Time = hms(substr(Occurred.Date.or.Date.Range.Start,12,22)))
message('Figure out why this join is bad!')
seattle_dat <- left_join(seattle_dat, crime_codes, by=c("Offense.Code"="OFFENSE_CODE"))

seattle_dat$Time@hour <- ifelse(substr(seattle_dat$Occurred.Date.or.Date.Range.Start,21,22) == 'AM', 
                                seattle_dat$Time@hour, seattle_dat$Time@hour + 12)


# These offense types I had to look up and assign manually. 
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '2316'] <- 'White Collar Crime'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '2502'] <- 'White Collar Crime'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '2599'] <- 'White Collar Crime'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '2610'] <- 'White Collar Crime'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '2802'] <- 'All Other Crimes'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '3899'] <- 'Other Crimes Against Persons'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '5208'] <- 'All Other Crimes'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '5403'] <- 'Drug & Alcohol'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '5404'] <- 'Drug & Alcohol'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == '999'] <- 'Murder'
seattle_dat$OFFENSE_CATEGORY_NAME[seattle_dat$Offense.Code == 'X'] <- 'Non-Criminal'



sf_dat <- sf_dat %>%
	transform(DayOfWeek = factor(DayOfWeek, labels=c('Sun','Mon','Tues','Wed','Thur','Fri', 'Sat'), ordered=T),
						Date = lubridate::mdy(Date),
						Time = hm(Time)) 

sf_dat$OFFENSE_CATEGORY_NAME <- NA
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'ARSON'] <- 'Arson'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'ASSAULT'] <- 'Aggravated Assault'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'BRIBERY'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'BURGLARY'] <- 'Burglary'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'DISORDERLY CONDUCT'] <- 'Public Disorder'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'DRIVING UNDER THE INFLUENCE'] <- 'Drug & Alcohol'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'DRUG/NARCOTIC'] <- 'Drug & Alcohol'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'DRUNKENNESS'] <- 'Drug & Alcohol'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'EMBEZZLEMENT'] <- 'White Collar Crime' 
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'EXTORTION'] <- 'White Collar Crime'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'FAMILY OFFENSES'] <- 'Aggravated Assault' # CHECK THIS ONE - Other Crimes?
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'FORGERY/COUNTERFEITING'] <- 'White Collar Crime'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'FRAUD'] <- 'White Collar Crime'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'GAMBLING'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'KIDNAPPING'] <- 'Other Crimes Against Persons'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'LARCENY/THEFT'] <- 'Larceny'
sf_dat$OFFENSE_CATEGORY_NAME <- ifelse(sf_dat$Category == 'LARCENY/THEFT',
																			 ifelse(grepl('AUTO', sf_dat$Descript, ignore.case=T),'Theft from Motor Vehicle','Larceny'),
																			 sf_dat$OFFENSE_CATEGORY_NAME)
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'LIQUOR LAWS'] <- 'Drug & Alcohol'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'LOITERING'] <- 'Public Disorder'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'MISSING PERSON'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'NON-CRIMINAL'] <- 'Non-Criminal'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'PORNOGRAPHY/OBSCENE MAT'] <- 'Other Crimes Against Persons'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'PROSTITUTION'] <- 'Public Disorder'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'ROBBERY'] <- 'Robbery'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'RUNAWAY'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'SECONDARY CODES'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'STOLEN PROPERTY'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'SUICIDE'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'SUSPICIOUS OCC'] <- 'All Other Crimes' # CHECK THIS PUBLIC DISORDER?
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'TRESPASS'] <- 'All Other Crimes'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'VANDALISM'] <- 'Public Disorder'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'VEHICLE THEFT'] <- 'Auto Theft'
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'WARRANTS'] <- 'All Other Crimes'
# Some Special Parsing here to deal with Possession of Weapon vs Brandishing, etc...
sf_dat$OFFENSE_CATEGORY_NAME <- ifelse(sf_dat$Category == 'WEAPON LAWS',
                                       ifelse(grepl('INTENT|EXHIB|ASSAULT', sf_dat$Descript, ignore.case=T),'Aggravated Assault','All Other Crimes'),
                                              sf_dat$OFFENSE_CATEGORY_NAME)
sf_dat$OFFENSE_CATEGORY_NAME[sf_dat$Category == 'OTHER OFFENSES'] <- 'All Other Crimes'

seattle_dat.tojoin <- seattle_dat[c("Date","Time","OFFENSE_CATEGORY_NAME")]
seattle_dat.tojoin$OFFENSE_CATEGORY_NAME <- as.character(seattle_dat.tojoin$OFFENSE_CATEGORY_NAME)
seattle_dat.tojoin$CITY <- "Seattle"
#seattle_dat.tojoin$Time <- as.POSIXct(seattle_dat.tojoin$Time)
sf_dat.tojoin <- sf_dat[c("Date","Time","OFFENSE_CATEGORY_NAME")]
sf_dat.tojoin$OFFENSE_CATEGORY_NAME <- as.character(sf_dat.tojoin$OFFENSE_CATEGORY_NAME)
sf_dat.tojoin$CITY <- "San Francisco"
joint_dat <- rbind(seattle_dat.tojoin, sf_dat.tojoin)

#------------------------
# Top Crime Summary
#------------------------

message('Top 10 Crime Categories: SF')
sf_dat %>%
	group_by(Category) %>%
	summarize(COUNT = n()) %>%
	arrange(desc(COUNT)) %>%
	head(10)
	

message('Top 10 Crime Categories: Seattle')
seattle_dat %>%
	group_by(Offense.Type) %>%
	summarize(COUNT = n()) %>%
	arrange(desc(COUNT)) %>%
	head(10)

message('Top 10 Crime Categories: Seattle')
seattle_dat %>%
	group_by(Summarized.Offense.Description) %>%
	summarize(COUNT = n()) %>%
	arrange(desc(COUNT)) %>%
	head(10)


# Total Crimes By City

top_crimes <- joint_dat %>%
	group_by(OFFENSE_CATEGORY_NAME, CITY) %>%
	summarize(Reported_Offenses = n())

top_crimes$OFFENSE_CATEGORY_NAME <- factor(top_crimes$OFFENSE_CATEGORY_NAME,
			levels=names(sort(table(joint_dat$OFFENSE_CATEGORY_NAME), decreasing=F)))

crime_bars <- ggplot(data=top_crimes, aes(OFFENSE_CATEGORY_NAME, Reported_Offenses, fill=CITY)) + 
	geom_bar(stat='identity', position="dodge") + coord_flip()
plot(crime_bars)

# Both Cities

# Census Comparison 2015
#http://www.census.gov/quickfacts/table/AGE115210/5363000,06075
seattle_pop <- 684451
sanfran_pop <- 805816


both.daily <- joint_dat %>%
	group_by(Date, CITY) %>%
	summarize(Total_Crimes = n())

both.daily$percapita <- ifelse(both.daily$CITY == "Seattle", both.daily$Total_Crimes/seattle_pop, both.daily$Total_Crimes/sanfran_pop)
	
raw_crimes <- ggplot(data=both.daily, aes(y=Total_Crimes, x=Date, color=CITY)) + geom_line() + geom_smooth()

plot(raw_crimes)

percap_crimes <- ggplot(data=both.daily, aes(y=percapita, x=Date, color=CITY)) + geom_line() + geom_smooth()

plot(percap_crimes)

# By Crime Type?


split_crimes.daily <- joint_dat %>%
	filter(OFFENSE_CATEGORY_NAME %in% c('Theft from Motor Vehicle', 'All Other Crimes', 'Larceny', 'Auto Theft', 'Public Disorder')) %>%
	group_by(Date, CITY, OFFENSE_CATEGORY_NAME) %>%
	summarize(Total_Crimes = n())

all_crimes <- ggplot(data=split_crimes.daily, aes(y=Total_Crimes, x=Date, color=OFFENSE_CATEGORY_NAME)) + geom_smooth() + facet_grid(. ~ CITY)

plot(all_crimes)


# Something a bout Time of Day or Day of Week 