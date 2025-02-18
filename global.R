library(dplyr)
library(sf)

print("Loading files")
CT <- readRDS("data/CT.rds")
Uber_Starting_Frequency <- readRDS("data/Uber_Starting_Frequency.rds")
Uber_Ending_Frequency <- readRDS("data/Uber_Ending_Frequency.rds")
Uber_Starting_Ending_Frequency <- readRDS("data/Uber_Starting_Ending_Frequency.rds")
Uber_Starting_Plus_Ending_Frequency <- readRDS("data/Uber_Starting_Plus_Ending_Frequency.rds")
print ("loading routing")
Uber_Route_Starts <- readRDS("data/Uber_Route_Starts.rds")
Google_Routes <- readRDS("data/Google_Routes.rds")
OSRM_Routes <- readRDS("data/OSRM_Routes.rds")
ArcGis_Routes <- readRDS("data/ArcGIS_Routes.rds")
print("Done Loading Files.")
