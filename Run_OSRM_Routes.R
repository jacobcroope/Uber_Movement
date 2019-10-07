#General Libraries we need for GEO Features and general functions.
require("tidyverse")
require("sf")

# # OSRM
require("osrm")
options(osrm.server = "http://a.b.c.d:5000/")


Route_Sources <- filter(Cincinnati_Centroids,MOVEMENT_ID %in% arrange(Uber_Starting_Plus_Ending_Frequency,desc(weekly_hrly_count))[1:10,]$sourceid)
OSRM_Routing <- OSRM_Routing[0,]
OSRM_Polyline_Routing <- OSRM_Polyline_Routing[0,]
for (i in (1:nrow(Route_Sources))) {
  Route_Source <- Route_Sources[i,]
  Routes_to_Run <- unique(filter(Hourly_1_19,sourceid == Route_Source$MOVEMENT_ID)$dstid)
  Routes_to_Run <- filter(Cincinnati_Centroids, MOVEMENT_ID %in% Routes_to_Run)

  count <- 0
  for (j in (1:nrow(Routes_to_Run))) {
    Route_Dest <- Routes_to_Run[j,]
    count <- count + 1
    ## Forward ##

    print(paste("Routing from ", Route_Source$MOVEMENT_ID , Route_Source$DISPLAY_NAME, " to ", Route_Dest$MOVEMENT_ID , Route_Dest$DISPLAY_NAME))
    osrm_return <- osrmRoute(src=Route_Source,dst=Route_Dest,overview="full",returnclass="sf")
    decoded_poly <- googlePolylines::decode(osrm_return$polyline)[[1]]
    sf_object <- st_as_sf(points_to_line(decoded_poly,"lon","lat"),crs=4326) %>% mutate(src = Route_Source$MOVEMENT_ID, polyline_osrm = osrm_return$polyline, dst = Route_Dest$MOVEMENT_ID,duration = osrm_return$duration,distance=osrm_return$distance)
    # Routing_Return <- st_as_sf(inner_join(Routing_Return[1,],sf_object),crs=4326)
    st_crs(sf_object) =4326
    osrm_return$src <- Route_Source$MOVEMENT_ID
    osrm_return$dst <- Route_Dest$MOVEMENT_ID
    OSRM_Routing <- rbind(OSRM_Routing,osrm_return)
    OSRM_Polyline_Routing <- rbind(OSRM_Polyline_Routing, sf_object)

    ## Reverse
    print(paste("Routing from ", Route_Dest$MOVEMENT_ID , Route_Dest$DISPLAY_NAME, " to ", Route_Source$MOVEMENT_ID , Route_Source$DISPLAY_NAME))
    osrm_return <- osrmRoute(src=Route_Dest,dst=Route_Source,overview="full",returnclass="sf")
    decoded_poly <- googlePolylines::decode(osrm_return$polyline)[[1]]
    sf_object <- st_as_sf(points_to_line(decoded_poly,"lon","lat"),crs=4326) %>% mutate(src = Route_Dest$MOVEMENT_ID, polyline_osrm = osrm_return$polyline, dst = Route_Source$MOVEMENT_ID,duration = osrm_return$duration,distance=osrm_return$distance)
    # Routing_Return <- st_as_sf(inner_join(Routing_Return[1,],sf_object),crs=4326)
    st_crs(sf_object) =4326
    osrm_return$src <- Route_Dest$MOVEMENT_ID
    osrm_return$dst <- Route_Source$MOVEMENT_ID
    OSRM_Routing <- rbind(OSRM_Routing,osrm_return)
    OSRM_Polyline_Routing <- rbind(OSRM_Polyline_Routing, sf_object)

  }
}

