# Global for 500 Hundred Cities App
# Sophie Geoghan
# July 17,2018

#### add changes to the master branch

#### change no2 master branch

### testing out kraken later.

library(shiny)
library(dplyr)
library(maps)
library(googleVis)
library(leaflet)
library(DT)
library(tidyr)
library(ggplot2)

#setwd("/Users/sophiegeoghan/Desktop/ShinyProject/FiveHundred_Shiny_StaticTest")

####### Loading data for first Two tabs #######

orig_five <- readr::read_csv("500_Cities__Local_Data_for_Better_Health.csv")

five_hundie <- orig_five %>%
  select(.,-Data_Value_Footnote_Symbol,-Data_Value_Footnote,
         -Year,-DataSource,-Data_Value_Unit) %>%
  rename(.,SQT=Short_Question_Text) %>%
  filter(.,is.na(Data_Value)==FALSE)
# separate out the general US rows
us_only <- five_hundie %>%
  filter(.,StateAbbr=="US") %>%
  select(.,Category,Measure,SQT,DataValueTypeID,Data_Value,Low_Confidence_Limit,High_Confidence_Limit)

five_hundie_only_cities <- five_hundie %>%
  filter(.,StateAbbr != "US" & nchar(UniqueID)==7)
# Create choices for UI inputs
display_measures <- unique(five_hundie$Measure)
choices_measures <- unique(five_hundie$SQT)
state_choices <- unique(five_hundie$StateAbbr)
# statewide in format best for tab 1
state_wide_1 <- five_hundie_only_cities %>%
  group_by(.,StateAbbr,SQT,DataValueTypeID) %>%
  # calculate a weighted average by population
  summarise(.,my_mean = sum(Data_Value*PopulationCount)/sum(PopulationCount)) %>%
  spread(.,SQT,my_mean)
# Statewide format for tab 2
state_wide_2 <- five_hundie_only_cities %>%
  group_by(.,StateAbbr,SQT,DataValueTypeID) %>%
  summarise(.,my_mean = sum(Data_Value*PopulationCount)/sum(PopulationCount),
            HCI = sum(High_Confidence_Limit*PopulationCount)/sum(PopulationCount),
            LCI=sum(Low_Confidence_Limit*PopulationCount)/sum(PopulationCount))# %>%
# function for the correlation plots
meas_filter <- function(data,data_type,measure){
  data %>%
    as.data.frame(.) %>%
    filter(.,DataValueTypeID==data_type) %>%
    select(.,measure)
}

##### Load in clean data for Tab 3 Interactive map #####

within_cities <- readr::read_csv("within_cities.csv")

within_cities <- within_cities %>% select(.,-X1) %>% rename(.,DV=Data_Value) %>% filter(.,PopulationCount>6572)

# Preparing the radius column to make the size of radii of markers relative to population
cutoff=quantile(range(within_cities$PopulationCount),probs=seq(0,1,0.25))
within_cities = within_cities %>%   mutate(.,radius=ifelse(PopulationCount <= cutoff[1],1,
                                                           ifelse(PopulationCount <= cutoff[2],3,
                                                                  ifelse(PopulationCount <= cutoff[3],7,
                                                                         ifelse(PopulationCount <= cutoff[4],10,NA)))))



# Cleaning data for Tab 3 - ONLY DONE ONCE and saved. ####
# Takes 3 minutes to run if you want to check it.
# I was taking GeoLocation from a string "(Latitude,Longitude)"
# to 2 numerical columns.

# within_cities <- five_hundie %>%
#   filter(.,StateAbbr != "US") %>%
#   filter(.,nchar(UniqueID)>7)
# # Could have made this more efficient with as.factor to make the size smaller
# fix_long_lat=function(geolocation) {
#   my_lat=c()
#   my_long=c()
#   tmp=strsplit(as.vector(geolocation),split=', ')
#   for (i in 1:length(tmp)) {
#     #print(test2[[i]][1])
#     my_lat[i]=stringr::str_replace_all(tmp[[i]][1],'[()]',"")#as.numeric()
#     my_long[i]=stringr::str_replace_all(tmp[[i]][2],'[()]',"")
#   }
#   return(cbind(as.numeric(my_lat),as.numeric(my_long)))
# }
# lat_long <- fix_long_lat(within_cities$GeoLocation)
#
# within_cities <- within_cities %>%
#   mutate(.,Latitude=lat_long[,1],
#          Longitude=lat_long[,2]) %>%
#   select(.,-GeoLocation)
# write.csv(within_cities,"within_cities.csv")
