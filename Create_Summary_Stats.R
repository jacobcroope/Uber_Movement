# Creating Summary Routing information from Routing

Google_Routes_Summary <- data.frame(Google_Routes)[1:4]
ArcGIS_Routes_Summary <- data.frame(ArcGis_Routes)[1:5]
OSRM_Routes_Summary <- data.frame(OSRM_Routes)[1:4]

Google_Routes_Summary$mtrs_gg <- Google_Routes_Summary$mtrs_gg  / 1609.344
Google_Routes_Summary$scnds_g <- Google_Routes_Summary$scnds_g /60

# OSRM_Routes_Summary$duration Already in Minutes.
OSRM_Routes_Summary$distance <- OSRM_Routes_Summary$distance / 1.609344

# Join on the limited data sets first
Route_Summary <- full_join(ArcGIS_Routes_Summary,Google_Routes_Summary)
# Join the OSRM data so we match the limited data sets.
Route_Summary <- inner_join(Route_Summary,OSRM_Routes_Summary)



colnames(Route_Summary) <- c("sourceid","dstid","mi_arcgis","min_arcgis","dt_arcgis","mi_google","min_google","min_osrm","mi_osrm" )
Route_Summary <- Route_Summary[c(1:4,6:9)]

Weekly_Hourly_Summary <- filter(Hourly_1_19,sourceid %in% Route_Summary$sourceid)
Weekly_Hourly_Summary$sourceid <- as.character(Weekly_Hourly_Summary$sourceid)
Weekly_Hourly_Summary$dstid <- as.character(Weekly_Hourly_Summary$dstid)
Weekly_Hourly_Summary <- inner_join(Weekly_Hourly_Summary,Route_Summary)

Weekly_Hourly_Summary$mean_travel_time = Weekly_Hourly_Summary$mean_travel_time /60
Weekly_Hourly_Summary$geometric_mean_travel_time = Weekly_Hourly_Summary$geometric_mean_travel_time /60
# gather(Weekly_Hourly_Summary,"Source","Travel_Time",4)
colnames(Weekly_Hourly_Summary)[4] <- "Uber"
colnames(Weekly_Hourly_Summary)[6] <- "Geo_Uber"
colnames(Weekly_Hourly_Summary)[9] <- "ArcGIS"
colnames(Weekly_Hourly_Summary)[11] <- "Google"
colnames(Weekly_Hourly_Summary)[12] <- "OSRM"

Weekly_Hourly_Summary <- mutate(Weekly_Hourly_Summary, avg_distance = (Weekly_Hourly_Summary$mi_arcgis + Weekly_Hourly_Summary$mi_google + Weekly_Hourly_Summary$mi_osrm)/3)
Weekly_Hourly_Summary <- gather(Weekly_Hourly_Summary,"Source","travel_time",c(4,6,9,11,12))

Weekly_Hourly_Summary <- mutate(Weekly_Hourly_Summary,distance = case_when(
  Source == "Uber" ~ Weekly_Hourly_Summary$avg_distance,Source == "Geo_Uber" ~ Weekly_Hourly_Summary$avg_distance,
  Source == "ArcGIS" ~ Weekly_Hourly_Summary$mi_arcgis,
  Source == "Google" ~ Weekly_Hourly_Summary$mi_google,
  Source == "OSRM" ~ Weekly_Hourly_Summary$mi_osrm,
))
# "All Hours" = "All Hours",
# "AM Peak (7-10AM)" = "AM Peak",
# "Midday (10-4PM)" = "Midday",
# "PM Peak (4-7PM)" = "PM Peak",
# "Evening (7PM-12AM)" = "Evening",
# "Early Morning (12AM-7AM)" = "Early Morning",
Weekly_Time_Period_Summary <- mutate(Weekly_Hourly_Summary,time_period = case_when(
  hod == 7 ~ "AM Peak  (7-10AM)",hod == 8 ~ "AM Peak  (7-10AM)",hod == 9 ~ "AM Peak  (7-10AM)",
  hod == 10 ~ "Midday (10-4PM)",hod == 11 ~ "Midday (10-4PM)",hod == 12 ~ "Midday (10-4PM)",hod == 13 ~ "Midday (10-4PM)",hod == 14 ~ "Midday (10-4PM)",hod == 15 ~ "Midday (10-4PM)",
  hod == 16 ~ "PM Peak (4-7PM)",hod == 17 ~ "PM Peak (4-7PM)",hod == 18 ~ "PM Peak (4-7PM)",
  hod == 19 ~ "Evening (7PM-12AM)",hod == 20 ~ "Evening (7PM-12AM)",hod == 21 ~ "Evening (7PM-12AM)",hod == 22 ~ "Evening (7PM-12AM)",hod == 23 ~ "Evening (7PM-12AM)",
  hod == 0 ~ "Early Morning (12AM-7AM)",hod == 1 ~ "Early Morning (12AM-7AM)",hod == 2 ~ "Early Morning (12AM-7AM)",hod == 3 ~ "Early Morning (12AM-7AM)",hod == 4 ~ "Early Morning (12AM-7AM)",hod == 5 ~ "Early Morning (12AM-7AM)",hod == 6 ~ "Early Morning (12AM-7AM)",
)) %>% group_by(sourceid,dstid,time_period,Source) %>% summarise(travel_time=mean(travel_time),distance=mean(distance))
Weekly_Time_Period_Summary <- data.frame(Weekly_Time_Period_Summary) %>% group_by(sourceid,dstid,Source,time_period = "All Hours") %>% summarise(travel_time=mean(travel_time),distance=mean(distance)) %>% rbind(Weekly_Time_Period_Summary)
#
# Am_Peak <- ggplot(data=filter(Weekly_Time_Period_Summary), mapping=(aes(x=distance,y=travel_time))) +geom_point(mapping = aes(color=Source),position="jitter") + facet_wrap(~time_period) + geom_smooth(mapping = aes(x=distance,y=travel_time,color=Source),size=2)
#
# # savePlot(filename = "../../AM_Peak.png",type = "png")
a <- ggplot(data=filter(Weekly_Time_Period_Summary,time_period == "PM Peak (4-7PM)",travel_time<40,distance<40), mapping=(aes(x=distance,y=travel_time))) +geom_point(mapping = aes(color=Source),position="jitter",alpha=1/2) + facet_wrap(~time_period) + geom_smooth(mapping = aes(x=distance,y=travel_time,color=Source),size=2) +
  labs(title = "Comparative Routing Travel Time and Distance", x = "Distance (Miles)", y = "Travel Time (Minutes)", colour = "Data Source") + theme_minimal(base_size=22)
