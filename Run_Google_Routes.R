#General Libraries we need for GEO Features and general functions.
require("tidyverse")
require("sf")

# Google Mapping and api
require("googleway")
set_key(key="your_key_here")

Route_Sources <- filter(CT,MOVEMENT_ID %in% arrange(Uber_Starting_Plus_Ending_Frequency,desc(weekly_hrly_count))[1:10,]$sourceid)
# simple_google_return <- google_directions(origin = c(rev(st_coordinates(Route_Source))), dest=c(rev(st_coordinates(Route_Dest))),mode="driving",simplify=TRUE)

# Used to test an initial route and create the form of the ending data set.
#
# Routing <- subset(data.frame(Route_Source), select = c(MOVEMENT_ID)) %>% mutate(dstid = MOVEMENT_ID, sourceid = MOVEMENT_ID)
# Routing <- Routing[,c("dstid","sourceid")] %>% mutate(meters_google = simple_google_return$routes$legs[[1]]$distance$value,seconds_google = simple_google_return$routes$legs[[1]]$duration$value, polyline_google = simple_google_return$routes$overview_polyline$points)
# Routing$sourceid <- as.character(Routing$sourceid)
# Routing$dstid <- as.character(Routing$dstid)
# Routing$meters_google <- as.numeric(Routing$meters_google)
# Routing$seconds_google <- as.numeric(Routing$seconds_google)
# Routing_Return <- Routing
# SF_Routing <- sf_object
# SF_Routing <- SF_Routing[0,]
# Routing <- Routing[0,]

# Step through the Route Sources and filter so that we have all the destinations that exist in the Hourly Data set as destinations.

for (i in (1:nrow(Route_Sources))) {
  Route_Source <- Route_Sources[i,]
  Routes_to_Run <- unique(filter(Hourly_1_19,sourceid == Route_Source$MOVEMENT_ID)$dstid)
  Routes_to_Run <- filter(Cincinnati_Centroids, MOVEMENT_ID %in% Routes_to_Run)


  Route_Returned <- Routing  # This lets you pick up where we left off.
  count <- 0
  for (j in (1:nrow(Routes_to_Run))) {
    Route_Dest <- Routes_to_Run[j,]
    count <- count + 1
    print(paste("Routing from ", Route_Source$MOVEMENT_ID , Route_Source$DISPLAY_NAME, " to ", Route_Dest$MOVEMENT_ID , Route_Dest$DISPLAY_NAME))
    google_return <- google_directions(origin = c(rev(st_coordinates(Route_Source))), dest=c(rev(st_coordinates(Route_Dest))),mode="driving",simplify=TRUE)
    if (google_return$status == "OK") {
      print("Got a good route")
      Routing_Return[1,]$sourceid <- as.character(Route_Source$MOVEMENT_ID)
      Routing_Return[1,]$dstid <- as.character(Route_Dest$MOVEMENT_ID)
      Routing_Return[1,]$meters_google <- as.numeric(google_return$routes$legs[[1]]$distance$value)
      Routing_Return[1,]$seconds_google <- as.numeric(google_return$routes$legs[[1]]$duration$value)
      Routing_Return[1,]$polyline_google <- as.character(google_return$routes$overview_polyline$points)
      decoded_poly <- googlePolylines::decode(Routing_Return[1,]$polyline_google)[[1]]
      sf_object <- st_as_sf(points_to_line(decoded_poly,"lon","lat"),crs=4326) %>% mutate(sourceid = Routing_Return[1,]$sourceid, dstid = Routing_Return[1,]$dstid )
      # The projection failed to stick
      st_crs(sf_object) =4326
      SF_Routing <- rbind(SF_Routing,sf_object)
      Routing <-  rbind(Routing,  Routing_Return)

    }

  }
}
Google_Routes <- inner_join(SF_Routing,Routing)
# Google_Routes_Backup <- Google_Routes


