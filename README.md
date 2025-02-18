# R Scripts for a comparative analysis of Uber Movement Cincinnati against Publicly Available Data Sets. 

Uber Movement has published a data set of mean travel time between geographic units in select cities around the world. Cincinnati was one of the selected cities and so there was interest in benchmarking Google Routing, ArcGIS (ESRI), and OSRM (Open Source Routing Machine) against the real world data set that Uber provided. The main interest was comparing predicted travel time, distance, and route choice between these services. As Uber only provides aggregated data it is not possible to compare route choice and distance in the Uber data set. Thus, an average travel distance between the three services is used as the comparative value for each Uber Route. Route choice is assessed graphically as the polyline algorithm returned by the various services does not easily intersect and allow comparative  analysis in the limited time available to prepare. 

Prepared for the 2019 OHIO GIS conference (Sep 2019)

## Getting Started

Clone the repository and Open Uber_Movement.Rproj in R studio. 

Run the following in the console should start everything and pull the finished data set from the data directory.  
``` 
shiny::runApp("./")
```

### Prerequisites


You will need the following libraries

General Libraries we need for GEO Features and general functions.
```
require("tidyverse")
require("sf")
```
OSRM
```
require("osrm")
```
Google Mapping and api
```
require("googleway")
```
ArcGIS querying through JSON/Rest
```
require("jsonlite")
```
General Libraries we need for Shiny Features.
```
library("lattice")
library("dplyr")
```

Useful Display stuff in Shiny/Testing
```
require("viridis")
require("maps")
require("leaflet")

```

### Replicating the Build


The Weekly_Hourly_Prep.R script should prepare the basic frequency count tables and can serve as a template for other variations. 
The Create_Summary_Stats.R script relies on the OSRM, Google, and ArcGIS Routing Scripts generating their respective base data sets. 
The three service routing scripts rely on the Routing_Utility_Functions.R script. 

There is an finished dataset which you can access in the data folder. 


Run the Hourly Scripts and Load the information in the data directory. 
```
> source('Uber_Movement/Weekly_Hourly_Prep.R', echo=TRUE)

> ############################## Pull data from original source ##############################
> Hourly_1_19 <- read.csv("data/cincinnati-censustracts ..." ... [TRUNCATED] 

```
Routing requires more setup but should be able to be run pretty easily. 
Be careful about how many credits routing will cost as the full routing matrix is about $1,000 to run on google. 
Make sure you run the Routing_Utility_Functions.R at least once to enable functions the routing scripts need. 

```
> # If you have shiny library loaded. 
> runApp()

> source("Routing_Utility_Functions.R")

> source("Run_OSRM_Routes.R")

# > ETC. 
```

## Deployment

Used Shiny to deploy to shinyapps.io
[Live Example of Analysis](https://jacobcroope.shinyapps.io/Uber_Movement_Cincinnati/)

## Built With

* [Rstudio](https://rstudio.com/) Version 1.2.1335
* [R](https://www.r-project.org/about.html) (3.6.1)
* [OSRM Docker backend](http://project-osrm.org/) on Amazon EC2 Large Instance
* [Google Routing](https://cloud.google.com/maps-platform/routes/) 
* [ArcGIS Routing](https://developers.arcgis.com/documentation/core-concepts/rest-api/) 09/20/2019

## Authors

* **Jacob Roope** - *Initial work* - [https://github.com/jacobcroope](https://github.com/jacobcroope)

## Acknowledgments

* Thank you to the people behind [GoogleWays](https://github.com/SymbolixAU/googleway) plugin which made many of the polyline conversion much easier. 

## Future to Do: 
Would be useful to do a regression test against services randomly polled from around the country and try to determine a correction factor to be applied based upon region of country, urban, rural, and other factors that might be needed. Can probably be automated to run and compare all the datasets across multiple quarters of Uber Movement Data. 

Write an algorithm to compare polylines or find a polyline comparitor already made and adjust for creating combined routes to highlight differences/sameness. 

Adjust the routing query scripts to record turn by turn so as to breakdown a route in further detail and compare against other services which should probably be combined with a polyline comparator.  
