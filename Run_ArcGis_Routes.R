# Run Arcgis Routes
require("jsonlite")
require("tidyverse")
# Base URL Slug https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World/solve?<PARAMETERS>
url_base <- "https://route.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World/solve?"
source_lat <- st_coordinates(Route_Source)[1]
source_lon <- st_coordinates(Route_Source)[2]
dest_lat <-  st_coordinates(Route_Dest)[1]
dest_lon <-  st_coordinates(Route_Dest)[2]
token <- "your_key_here"
stops = paste0("stops=",source_lon,",",source_lat,";",dest_lon,",",dest_lat)
# arcgis_response <- fromJSON(paste0(url_base,stops,"&f=json&token=",token))
# #
# route_vector_transposed <- data.frame(t(data.frame(arcgis_response$routes$features$geometry$paths[[1]])))
# route_geometry <- filter(route_vector_transposed,route_vector_transposed>0)
# route_geometry <- cbind(route_geometry,(data.frame(t(data.frame(arcgis_response$routes$features$geometry$paths[[1]]))) %>% filter(route_vector_transposed<0)))
# colnames(route_geometry) <- c("latitude","longitude")
# sf_object <- st_as_sf(points_to_line(route_geometry,"longitude","latitude"),crs=4326)
# st_crs(sf_object) =4326
#
# sf_object <- mutate(sf_object,sourceid = Route_Source$MOVEMENT_ID, dstid = Route_Dest$MOVEMENT_ID,miles_arcgis = arcgis_response$directions$summary$totalLength,min_arcgis = arcgis_response$directions$summary$totalTime,drive_time_arcgis = arcgis_response$directions$summary$totalDriveTime )
#
# ArcGIS_Routing <- sf_object
# ArcGIS_Routing <- ArcGIS_Routing[0,]

Route_Sources <- filter(Cincinnati_Centroids,MOVEMENT_ID %in% arrange(Uber_Starting_Plus_Ending_Frequency,desc(weekly_hrly_count))[1:10,]$sourceid)

for (i in (4:nrow(Route_Sources))) {
  Route_Source <- Route_Sources[i,]
  Routes_to_Run <- unique(filter(Hourly_1_19,sourceid == Route_Source$MOVEMENT_ID)$dstid)
  Routes_to_Run <- filter(Cincinnati_Centroids, MOVEMENT_ID %in% Routes_to_Run)

  count <- 0
  for (j in (1:nrow(Routes_to_Run))) {
    Route_Dest <- Routes_to_Run[j,]
#     count <- count + 1
#     ## Forward ##
#
    if (Route_Dest$MOVEMENT_ID == Route_Source$MOVEMENT_ID) {
      next
    }
    print(paste("Routing from ", Route_Source$MOVEMENT_ID , Route_Source$DISPLAY_NAME, " to ", Route_Dest$MOVEMENT_ID , Route_Dest$DISPLAY_NAME))
    source_lat <- st_coordinates(Route_Source)[1]
    source_lon <- st_coordinates(Route_Source)[2]
    dest_lat <-  st_coordinates(Route_Dest)[1]
    dest_lon <-  st_coordinates(Route_Dest)[2]
    stops = paste0("stops=",source_lon,",",source_lat,";",dest_lon,",",dest_lat)
    print (paste0(url_base,stops,"&f=json&token=",token))
    arcgis_response <- fromJSON(paste0(url_base,stops,"&f=json&token=",token))
    # if(arcgis_response$error$code != "400") {
    route_vector_transposed <- data.frame(t(data.frame(arcgis_response$routes$features$geometry$paths[[1]])))
    route_geometry <- filter(route_vector_transposed,route_vector_transposed>0)
    route_geometry <- cbind(route_geometry,(data.frame(t(data.frame(arcgis_response$routes$features$geometry$paths[[1]]))) %>% filter(route_vector_transposed<0)))
    colnames(route_geometry) <- c("latitude","longitude")
    sf_object <- st_as_sf(points_to_line(route_geometry,"longitude","latitude"),crs=4326)
    st_crs(sf_object) =4326

    sf_object <- mutate(sf_object,sourceid = Route_Source$MOVEMENT_ID, dstid = Route_Dest$MOVEMENT_ID,miles_arcgis = arcgis_response$directions$summary$totalLength,min_arcgis = arcgis_response$directions$summary$totalTime,drive_time_arcgis = arcgis_response$directions$summary$totalDriveTime )

    ArcGIS_Routing <- rbind(ArcGIS_Routing,sf_object)
    # }
    # else {print("Error_Code")}

  }
}


