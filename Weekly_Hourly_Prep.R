require(tidyverse)
require(sf)

############################## Pull data from original source ##############################
Hourly_1_19 <- read.csv("data/cincinnati-censustracts-2019-1-All-HourlyAggregate.csv")
Weekday_Hourly_1_19 <- read.csv("data/cincinnati-censustracts-2019-1-OnlyWeekdays-HourlyAggregate.csv")
Weekends_Hourly_1_19 <- read.csv("data/cincinnati-censustracts-2019-1-OnlyWeekends-HourlyAggregate.csv")
CT <- readRDS("data/CT.rds")

############################## This groups Src time_period -> # destinations ###################################
# Hourly summarizations for the entire quarter or by day of week.
Weekly_Hourly_Frequency <- Hourly_1_19 %>% group_by(sourceid, hod) %>% summarise(weekly_hrly_count=n())
Weekday_Hourly_Frequency <- Weekday_Hourly_1_19 %>% group_by(sourceid, hod) %>% summarise(weekday_hrly_count=n())
Weekends_Hourly_Frequency <- Weekends_Hourly_1_19 %>% group_by(sourceid, hod) %>% summarise(weekends_hrly_count=n())

# Summarize by the next grouping of Time Period.
Weekly_Time_Period_Frequency <- mutate(Weekly_Hourly_Frequency,time_period = case_when(
  hod == 7 ~ "AM Peak",hod == 8 ~ "AM Peak",hod == 9 ~ "AM Peak",
  hod == 10 ~ "Midday",hod == 11 ~ "Midday",hod == 12 ~ "Midday",hod == 13 ~ "Midday",hod == 14 ~ "Midday",hod == 15 ~ "Midday",
  hod == 16 ~ "PM Peak",hod == 17 ~ "PM Peak",hod == 18 ~ "PM Peak",
  hod == 19 ~ "Evening",hod == 20 ~ "Evening",hod == 21 ~ "Evening",hod == 22 ~ "Evening",hod == 23 ~ "Evening",
  hod == 0 ~ "Early Morning",hod == 1 ~ "Early Morning",hod == 2 ~ "Early Morning",hod == 3 ~ "Early Morning",hod == 4 ~ "Early Morning",hod == 5 ~ "Early Morning",hod == 6 ~ "Early Morning",
)) %>% group_by(sourceid,time_period) %>% summarise(weekly_hrly_count= sum(weekly_hrly_count))
Weekday_Time_Period_Frequency <- mutate(Weekday_Hourly_Frequency ,time_period = case_when(
  hod == 7 ~ "AM Peak",hod == 8 ~ "AM Peak",hod == 9 ~ "AM Peak",
  hod == 10 ~ "Midday",hod == 11 ~ "Midday",hod == 12 ~ "Midday",hod == 13 ~ "Midday",hod == 14 ~ "Midday",hod == 15 ~ "Midday",
  hod == 16 ~ "PM Peak",hod == 17 ~ "PM Peak",hod == 18 ~ "PM Peak",
  hod == 19 ~ "Evening",hod == 20 ~ "Evening",hod == 21 ~ "Evening",hod == 22 ~ "Evening",hod == 23 ~ "Evening",
  hod == 0 ~ "Early Morning",hod == 1 ~ "Early Morning",hod == 2 ~ "Early Morning",hod == 3 ~ "Early Morning",hod == 4 ~ "Early Morning",hod == 5 ~ "Early Morning",hod == 6 ~ "Early Morning",
)) %>% group_by(sourceid,time_period) %>% summarise(weekday_hrly_count= sum(weekday_hrly_count))
Weekends_Time_Period_Frequency <- mutate(Weekends_Hourly_Frequency ,time_period = case_when(
  hod == 7 ~ "AM Peak",hod == 8 ~ "AM Peak",hod == 9 ~ "AM Peak",
  hod == 10 ~ "Midday",hod == 11 ~ "Midday",hod == 12 ~ "Midday",hod == 13 ~ "Midday",hod == 14 ~ "Midday",hod == 15 ~ "Midday",
  hod == 16 ~ "PM Peak",hod == 17 ~ "PM Peak",hod == 18 ~ "PM Peak",
  hod == 19 ~ "Evening",hod == 20 ~ "Evening",hod == 21 ~ "Evening",hod == 22 ~ "Evening",hod == 23 ~ "Evening",
  hod == 0 ~ "Early Morning",hod == 1 ~ "Early Morning",hod == 2 ~ "Early Morning",hod == 3 ~ "Early Morning",hod == 4 ~ "Early Morning",hod == 5 ~ "Early Morning",hod == 6 ~ "Early Morning",
)) %>% group_by(sourceid,time_period) %>% summarise(weekends_hrly_count=sum(weekends_hrly_count))

# Add the All Hours Summarization
Weekly_Time_Period_Frequency <- Weekly_Time_Period_Frequency %>%  group_by(sourceid,time_period="All Hours") %>% summarise(weekly_hrly_count=sum(weekly_hrly_count)) %>% rbind(Weekly_Time_Period_Frequency)
Weekday_Time_Period_Frequency <- Weekday_Time_Period_Frequency %>%  group_by(sourceid,time_period="All Hours") %>% summarise(weekday_hrly_count=sum(weekday_hrly_count)) %>%  rbind(Weekday_Time_Period_Frequency)
Weekends_Time_Period_Frequency <- Weekends_Time_Period_Frequency %>%  group_by(sourceid,time_period="All Hours") %>% summarise(weekends_hrly_count=sum(weekends_hrly_count)) %>% rbind(Weekends_Time_Period_Frequency)

# Convert hours to character and combine with existing Time periods.
Weekly_Hourly_Frequency <- mutate(Weekly_Hourly_Frequency,time_period = as.character(hod))
Weekly_Starting_Frequency <- rbind(Weekly_Hourly_Frequency[-2],Weekly_Time_Period_Frequency)

Weekday_Hourly_Frequency <- mutate(Weekday_Hourly_Frequency,time_period = as.character(hod))
Weekday_Starting_Frequency <- rbind(Weekday_Hourly_Frequency[-2],Weekday_Time_Period_Frequency)

Weekends_Hourly_Frequency <- mutate(Weekends_Hourly_Frequency,time_period = as.character(hod))
Weekends_Starting_Frequency <- rbind(Weekends_Hourly_Frequency[-2],Weekends_Time_Period_Frequency)



Uber_Starting_Frequency <- full_join(Weekly_Starting_Frequency, Weekday_Starting_Frequency,keep=TRUE) %>% full_join(Weekends_Starting_Frequency,keep=TRUE)



############################## This does DST time_period -> # destinations ###################################
# Hourly summarizations for the entire quarter or by day of week.
Weekly_Hourly_Frequency <- Hourly_1_19 %>% group_by(dstid, hod) %>% summarise(weekly_hrly_count=n())
Weekday_Hourly_Frequency <- Weekday_Hourly_1_19 %>% group_by(dstid, hod) %>% summarise(weekday_hrly_count=n())
Weekends_Hourly_Frequency <- Weekends_Hourly_1_19 %>% group_by(dstid, hod) %>% summarise(weekends_hrly_count=n())

# Summarize by the next grouping of Time Period. These are built from a count summation so we want to now sum.
Weekly_Time_Period_Frequency <- mutate(Weekly_Hourly_Frequency,time_period = case_when(
  hod == 7 ~ "AM Peak",hod == 8 ~ "AM Peak",hod == 9 ~ "AM Peak",
  hod == 10 ~ "Midday",hod == 11 ~ "Midday",hod == 12 ~ "Midday",hod == 13 ~ "Midday",hod == 14 ~ "Midday",hod == 15 ~ "Midday",
  hod == 16 ~ "PM Peak",hod == 17 ~ "PM Peak",hod == 18 ~ "PM Peak",
  hod == 19 ~ "Evening",hod == 20 ~ "Evening",hod == 21 ~ "Evening",hod == 22 ~ "Evening",hod == 23 ~ "Evening",
  hod == 0 ~ "Early Morning",hod == 1 ~ "Early Morning",hod == 2 ~ "Early Morning",hod == 3 ~ "Early Morning",hod == 4 ~ "Early Morning",hod == 5 ~ "Early Morning",hod == 6 ~ "Early Morning",
)) %>% group_by(dstid,time_period) %>% summarise(weekly_hrly_count=sum(weekly_hrly_count))
Weekday_Time_Period_Frequency <- mutate(Weekday_Hourly_Frequency ,time_period = case_when(
  hod == 7 ~ "AM Peak",hod == 8 ~ "AM Peak",hod == 9 ~ "AM Peak",
  hod == 10 ~ "Midday",hod == 11 ~ "Midday",hod == 12 ~ "Midday",hod == 13 ~ "Midday",hod == 14 ~ "Midday",hod == 15 ~ "Midday",
  hod == 16 ~ "PM Peak",hod == 17 ~ "PM Peak",hod == 18 ~ "PM Peak",
  hod == 19 ~ "Evening",hod == 20 ~ "Evening",hod == 21 ~ "Evening",hod == 22 ~ "Evening",hod == 23 ~ "Evening",
  hod == 0 ~ "Early Morning",hod == 1 ~ "Early Morning",hod == 2 ~ "Early Morning",hod == 3 ~ "Early Morning",hod == 4 ~ "Early Morning",hod == 5 ~ "Early Morning",hod == 6 ~ "Early Morning",
)) %>% group_by(dstid,time_period) %>% summarise(weekday_hrly_count=sum(weekday_hrly_count))
Weekends_Time_Period_Frequency <- mutate(Weekends_Hourly_Frequency ,time_period = case_when(
  hod == 7 ~ "AM Peak",hod == 8 ~ "AM Peak",hod == 9 ~ "AM Peak",
  hod == 10 ~ "Midday",hod == 11 ~ "Midday",hod == 12 ~ "Midday",hod == 13 ~ "Midday",hod == 14 ~ "Midday",hod == 15 ~ "Midday",
  hod == 16 ~ "PM Peak",hod == 17 ~ "PM Peak",hod == 18 ~ "PM Peak",
  hod == 19 ~ "Evening",hod == 20 ~ "Evening",hod == 21 ~ "Evening",hod == 22 ~ "Evening",hod == 23 ~ "Evening",
  hod == 0 ~ "Early Morning",hod == 1 ~ "Early Morning",hod == 2 ~ "Early Morning",hod == 3 ~ "Early Morning",hod == 4 ~ "Early Morning",hod == 5 ~ "Early Morning",hod == 6 ~ "Early Morning",
)) %>% group_by(dstid,time_period) %>% summarise(weekends_hrly_count=sum(weekends_hrly_count))

# Add the All Hours Summarization
Weekly_Time_Period_Frequency <- Weekly_Time_Period_Frequency %>%  group_by(dstid,time_period="All Hours") %>% summarise(weekly_hrly_count=sum(weekly_hrly_count)) %>% rbind(Weekly_Time_Period_Frequency)
Weekday_Time_Period_Frequency <- Weekday_Time_Period_Frequency %>%  group_by(dstid,time_period="All Hours") %>% summarise(weekday_hrly_count=sum(weekday_hrly_count)) %>%  rbind(Weekday_Time_Period_Frequency)
Weekends_Time_Period_Frequency <- Weekends_Time_Period_Frequency %>%  group_by(dstid,time_period="All Hours") %>% summarise(weekends_hrly_count=sum(weekends_hrly_count)) %>% rbind(Weekends_Time_Period_Frequency)

# Convert hours to character and combine with existing Time periods.
Weekly_Hourly_Frequency <- mutate(Weekly_Hourly_Frequency,time_period = as.character(hod))
Weekly_Ending_Frequency <- rbind(Weekly_Hourly_Frequency[-2],Weekly_Time_Period_Frequency)

Weekday_Hourly_Frequency <- mutate(Weekday_Hourly_Frequency,time_period = as.character(hod))
Weekday_Ending_Frequency <- rbind(Weekday_Hourly_Frequency[-2],Weekday_Time_Period_Frequency)

Weekends_Hourly_Frequency <- mutate(Weekends_Hourly_Frequency,time_period = as.character(hod))
Weekends_Ending_Frequency <- rbind(Weekends_Hourly_Frequency[-2],Weekends_Time_Period_Frequency)



Uber_Ending_Frequency <- full_join(Weekly_Ending_Frequency, Weekday_Ending_Frequency,keep=TRUE) %>% full_join(Weekends_Ending_Frequency,keep=TRUE)


# Calculate the Difference with Full Join
Uber_Starting_Ending_Frequency <- full_join(Uber_Starting_Frequency,Uber_Ending_Frequency,by=c("sourceid" = "dstid","time_period"="time_period"),keep=TRUE)

Uber_Starting_Ending_Frequency <- Uber_Starting_Ending_Frequency %>%  mutate(weekly_hrly_count = weekly_hrly_count.x - weekly_hrly_count.y,weekday_hrly_count = weekday_hrly_count.x - weekday_hrly_count.y, weekends_hrly_count = weekends_hrly_count.x - weekends_hrly_count.y)
Uber_Starting_Ending_Frequency <- select(Uber_Starting_Ending_Frequency,c("sourceid","time_period","weekly_hrly_count","weekday_hrly_count","weekends_hrly_count"))

Uber_Starting_Plus_Ending_Frequency <- full_join(Uber_Starting_Frequency,Uber_Ending_Frequency,by=c("sourceid" = "dstid","time_period"="time_period"),keep=TRUE)

Uber_Starting_Plus_Ending_Frequency <- Uber_Starting_Plus_Ending_Frequency %>%  mutate(weekly_hrly_count = weekly_hrly_count.x + weekly_hrly_count.y,weekday_hrly_count = weekday_hrly_count.x + weekday_hrly_count.y, weekends_hrly_count = weekends_hrly_count.x + weekends_hrly_count.y)
Uber_Starting_Plus_Ending_Frequency <- select(Uber_Starting_Plus_Ending_Frequency,c("sourceid","time_period","weekly_hrly_count","weekday_hrly_count","weekends_hrly_count"))


# # Add the Polygon definitions at the very end

Uber_Starting_Frequency <- st_as_sf(inner_join(Uber_Starting_Frequency,CT,by=c("sourceid" = "sourceid")))

Uber_Ending_Frequency <- st_as_sf(inner_join(Uber_Ending_Frequency,CT,by=c("dstid" = "sourceid")))

Uber_Starting_Ending_Frequency <- st_as_sf(inner_join(Uber_Starting_Ending_Frequency,CT,by=c("sourceid" = "sourceid")))

Uber_Starting_Plus_Ending_Frequency <- st_as_sf(inner_join(Uber_Starting_Plus_Ending_Frequency,CT,by=c("sourceid" = "sourceid")))

#
############################## Save all these files.  ###################################
# Commented out as the finished versions are included in the data directory.
# saveRDS(Uber_Starting_Frequency,"Uber_Movement/data/Uber_Starting_Frequency.rds")
# saveRDS(Uber_Ending_Frequency,"Uber_Movement/data/Uber_Ending_Frequency.rds")
# saveRDS(Uber_Starting_Ending_Frequency,"Uber_Movement/data/Uber_Starting_Ending_Frequency.rds")
# saveRDS(Uber_Starting_Plus_Ending_Frequency,"Uber_Movement/data/Uber_Starting_Plus_Ending_Frequency.rds")





