# R Scripts for a comparative analysis of Uber Movement Cincinnatti against Publicly Available Data Sets. 

Uber Movement has published a data set of mean travel time between geographic units in select cities around the world. Cincinnatti was one of the selected cities and so there was interest in benchmarking Google Routing, ArcGIS (ESRI), and OSRM (Open Source Routing Machine) against the real world data set that Uber provided. Of particular interest was comparing predicted travel time, distance, and route choice between these services. As Uber does not provide low level enough data to compare route choice and distance an average travel distance between the three services is used as the comparative value for each Uber Route. Route choice is assessed graphically as the polyline algorithm returned by the various services does not easily intersect and allow comparitive analysis in the limited time available to prepare. 

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
