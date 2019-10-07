
library(lattice)
library(dplyr)
#General Libraries we need for GEO Features and general functions.
require("tidyverse")
require("sf")

#
# Useful Display stuff
require("viridis")
require("maps")
require("leaflet")

function(input, output, session) {

  ## Interactive Map ###########################################

    # Create the map
  output$map <- renderLeaflet({
    leaflet() %>%
    addTiles() %>%
    setView(lng = -84.511, lat = 39.2, zoom = 10)
  })
  Census_Tract_Source <- "No Source"
  Census_Tract_Dest <- "No Dest"

  observeEvent(input$map_shape_click, {

    # This won't hold the items clicked so we need to just use it to show info graphics on call.
    p <- input$map_shape_click
    Show_Google_Routes <- input$google
    Show_ArcGIS_Routes <- input$arcgis
    Show_OSRM_Routes <- input$osrm
    print(p)

    if(!is.null(p$id)) {
    # This was meant to do some stuff on click of a CT but I couldn't get the values to remain consistent across the react environment.
    # probably need to transition the p.id to a hidden value embedded in the page so that I can do a control matrix for enabling/disabling CT routing.
    #   if(Census_Tract_Source == p$id) {
    #     Census_Tract_Source <- "No Source"
    #     Census_Tract_Dest <- "No Dest"
    #   }  # Turn off both of the Routes
    #   if(Census_Tract_Dest == p$id) {
    #     Census_Tract_Dest <- "No Dest"
    #   } # Turn off the Routes
    #
    #   if(Census_Tract_Dest == "No Dest" && Census_Tract_Source != "No Source") {
    #     # Display the selected Destination
    #     Census_Tract_Dest <- p$id
    #     leafletProxy("map") %>% clearShapes() %>% clearControls() %>% addPolygons(data=filter(CT,MOVEMENT_ID == Census_Tract_Source),fillColor = "red",layerId = ~MOVEMENT_ID) %>% addPolygons(data=filter(CT,MOVEMENT_ID == Census_Tract_Dest),fillColor="green",layerId = ~MOVEMENT_ID)
    #     # if (Show_OSRM_Routes == TRUE) {
    #     #   leafletProxy("map") %>% addPolygons(data=filter(CT,MOVEMENT_ID %in% filter(OSRM_Routes,src=153)$dst),fillColor="green")
    #     # }
    #   }
    #   if(Census_Tract_Source == "No Source") {
    #     # Display the selected Source.
    #     Census_Tract_Source <- p$id
    #     leafletProxy("map") %>% clearShapes() %>% clearControls() %>% addPolygons(data=filter(CT,MOVEMENT_ID == Census_Tract_Source),fillColor = "red",layerId = ~MOVEMENT_ID)
    #     leafletProxy("map") %>% addPolygons(data=filter(CT,MOVEMENT_ID %in% filter(OSRM_Routes,src == Census_Tract_Source)$dst),fillColor="green",layerId = ~MOVEMENT_ID)
    #
    #     # # if (Show_OSRM_Routes == TRUE) {
    #     #   leafletProxy("map") %>% addPolygons(data=filter(CT,MOVEMENT_ID %in% filter(OSRM_Routes,src=Census_Tract_Source)$dst),fillColor="green")
    #     # # }
    #   }
    #
    }
  })
  # # This observer is responsible for maintaining the Census Tracts and Legend,
  # # according to the variables the user has chosen to map to color and size
  # # on Frequency of occurence in Uber Movement Database and Routing between CT
  observe({

      Show_Google_Routes <- input$google
      Show_ArcGIS_Routes <- input$arcgis
      Show_OSRM_Routes <- input$osrm
      route_start <- input$route_start
      route_end <- input$route_end
      route_to_map <- OSRM_Routes[1,]

      # Routing disables frequency counts and changings the background tiles to more visually show the change.
      if (Show_Google_Routes == TRUE || Show_ArcGIS_Routes == TRUE || Show_OSRM_Routes == TRUE) {

      # # Show Starting Routes and put a pop up explaining how to interact.
      leafletProxy("map") %>% clearShapes() %>% clearControls() %>% addProviderTiles(providers$CartoDB.Positron)
      labels <- sprintf(
        "<strong>%s</strong>",
        CT$DISPLAY_NAME
      ) %>% lapply(htmltools::HTML)

      leafletProxy("map") %>% addPolygons(data = CT, fillColor = "gray",
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    dashArray = "3",
                    fillOpacity = .4,
                    layerId =~MOVEMENT_ID,
                    highlight = highlightOptions(
                      weight = 5,
                      color = "#666",
                      dashArray = "",
                      fillOpacity = .5,
                      bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "3px 8px"),
                      textsize = "15px",
                      direction = "auto"))

      leafletProxy("map") %>% addPolygons(data=filter(CT,MOVEMENT_ID==route_start),layerId =~MOVEMENT_ID,fillColor ="#fa9fb5",weight = 2,
                                                                                opacity = 1,
                                                                                color = "white",
                                                                                dashArray = "3",
                                                                                fillOpacity = 0.7,
                                                                                highlight = highlightOptions(
                                                                                  weight = 5,
                                                                                  color = "#666",
                                                                                  dashArray = "",
                                                                                  fillOpacity = 1))
      leafletProxy("map") %>%  addPolygons(data=filter(CT,MOVEMENT_ID==route_end),layerId =~MOVEMENT_ID,fillColor ="#feb24c",weight = 2,
                                           opacity = 1,
                                           color = "white",
                                           dashArray = "3",
                                           fillOpacity = 0.7,
                                           highlight = highlightOptions(
                                             weight = 5,
                                             color = "#666",
                                             dashArray = "",
                                             fillOpacity = 1))
      if  (Show_Google_Routes == TRUE) {
        leafletProxy("map")   %>% addPolylines(data=filter(Google_Routes,sourceid == route_start,dstid ==route_end),color="#1b9e77",opacity = 1)
      }
      if (Show_ArcGIS_Routes == TRUE) {
        leafletProxy("map")   %>% addPolylines(data=filter(ArcGis_Routes,sourceid == route_start,dstid ==route_end),color="#d95f02",opacity = 1)
      }
      if (Show_OSRM_Routes == TRUE) {
        leafletProxy("map")   %>% addPolylines(data=filter(OSRM_Routes,sourceid == route_start,dstid ==route_end),color="#7570b3",opacity = 1)
      }
      leafletProxy("map") %>% addLegend(colors = c("#1b9e77","#d95f02","#7570b3","#fa9fb5","#feb24c"),labels = c("Google","ArcGIS","OSRM","Starting Census Tract", "Ending Census Tract"), opacity = 0.7, title = "Routing Services",
                position = "bottomleft")


      }
      # We are going to show the frequency distribution by default but it is easier to check for the routes first.
    else {

    timePeriod <- input$time_period
    time_period_nice_text <- c(
      "All Hours"  =  "All Hours",
      "AM Peak"  =  "AM Peak (7-10AM)",
      "Midday"  =  "Midday (10-4PM)",
      "PM Peak"  =  "PM Peak (4-7PM",
      "Evening"  =  "Evening (7PM-12AM)",
      "Early Morning"  =  "Early Morning (12AM-7AM)",
      "0" =  "12-1AM",
      "1" =  "1-2AM",
      "2" =  "2-3AM",
      "3" =  "3-4AM",
      "4" =  "4-5AM",
      "5" =  "5-6AM",
      "6" =  "6-7AM",
      "7" =  "7-8AM",
      "8" =  "8-9AM",
      "9" =  "9-10AM",
      "10" =  "10-11AM",
      "11" =  "11AM-12PM",
      "12" =  "12-1PM",
      "13" =  "1-2PM",
      "14" =  "2-3PM",
      "15" =  "3-4PM",
      "16" =  "4-5PM",
      "17" =  "5-6PM",
      "18" =  "6-7PM",
      "19" =  "7-8PM",
      "20" =  "8-9PM",
      "21" =  "9-10PM",
      "22" =  "10-11PM",
      "23" =  "11PM-12PM"
    )
    timePeriodText = time_period_nice_text[timePeriod]

    # Possible choices from UI
    # data_set_choice <- c(
    #   "Trips Starting" = "starting",
    #   "Trips Ending" = "ending",
    #   "Trips Starting - Trips Ending (Difference)" = "starting-ending",
    #   "Trips Starting + Trips Ending (Sum)" = "starting+ending"
    #
    # )
    #
    # weekday_choice <- c(
    #   "Entire Week" = "weekly",
    #   "Weekend Only" = "weekend",
    #   "Weekdays Only" = "weekday"
    # )

    dataSetChoice <- input$data_set_choice

    weekdayChoice <- input$weekday_choice

    opacity <- .7

    ColorsToUse <- "YlGnBu"

    #Initialize our variable with a simple data structure from our default data set.
    data_to_map <- Uber_Starting_Frequency[1,]


    if (dataSetChoice == "starting") {
      data_to_map <- filter(Uber_Starting_Frequency,time_period == timePeriod)
      ColorsToUse <- "YlGnBu"
    }

    if (dataSetChoice == "ending") {
      data_to_map <- filter(Uber_Ending_Frequency,time_period == timePeriod)
      ColorsToUse <- "YlOrRd"
    }
    if (dataSetChoice == "starting-ending") {
      data_to_map <- filter(Uber_Starting_Ending_Frequency,time_period == timePeriod)
      ColorsToUse <- "RdYlBu"
    }
    if (dataSetChoice == "starting+ending") {
      data_to_map <- filter(Uber_Starting_Plus_Ending_Frequency,time_period == timePeriod)
      ColorsToUse <- "Purples"
      opacity <- .9
    }


    # Had to break these into different groupings because the data set to color from has changed and it was not obvious how to pass a second hand reference
    # To the underlying graphing functions.
    # Ideally the changes would be summarized in the above switches to summarize all the changes and then passed to one display funciton.
    if (weekdayChoice == "weekly") {

      # Adjust the color pallete.
      pal <- colorNumeric(palette = rev(ColorsToUse),domain=data_to_map$weekly_hrly_count)

      title_text <- paste("Weekly Occurences of trips during<br>",timePeriodText, dataSetChoice,"<br>In Hourly Uber Movement Database Q1 2019")

      # Calculate Labels
      labels <- sprintf(
        "<strong>%s</strong><br/>%s",
        data_to_map$DISPLAY_NAME , paste(data_to_map$weekly_hrly_count,"Trips", dataSetChoice, "in this census tract")
      ) %>% lapply(htmltools::HTML)

      leafletProxy("map", data = data_to_map) %>% clearShapes() %>% clearControls() %>%
        addPolygons(fillColor = ~pal(weekly_hrly_count),
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    dashArray = "3",
                    fillOpacity = 0.7,
                    highlight = highlightOptions(
                      weight = 5,
                      color = "#666",
                      dashArray = "",
                      fillOpacity = opacity,
                      bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "3px 8px"),
                      textsize = "15px",
                      direction = "auto")) %>%
        addLegend(pal = pal, values = ~weekly_hrly_count, opacity = 0.7, title = title_text,
                  position = "bottomleft") %>% addTiles()
    }

    if (weekdayChoice == "weekend") {
      # Adjust the color pallete.

      pal <- colorNumeric(palette = ColorsToUse,domain=data_to_map$weekends_hrly_count)

      title_text <- paste("Weekend Occurences of trips during<br>",timePeriodText, dataSetChoice,"<br>In Hourly Uber Movement Database Q1 2019")

      # Calculate Labels
      labels <- sprintf(
        "<strong>%s</strong><br/>%s",
        data_to_map$DISPLAY_NAME , paste(data_to_map$weekends_hrly_count, "Trips", dataSetChoice, "in this census tract")
      ) %>% lapply(htmltools::HTML)

      leafletProxy("map", data = data_to_map) %>% clearShapes() %>% clearControls() %>%
        addPolygons(fillColor = ~pal(weekends_hrly_count),
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    dashArray = "3",
                    fillOpacity = 0.7,
                    highlight = highlightOptions(
                      weight = 5,
                      color = "#666",
                      dashArray = "",
                      fillOpacity = opacity,
                      bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "3px 8px"),
                      textsize = "15px",
                      direction = "auto")) %>%
        addLegend(pal = pal, values = ~weekends_hrly_count, opacity = 0.7, title = title_text,
                  position = "bottomleft")  %>% addTiles()
    }
    if (weekdayChoice == "weekday") {
      # Adjust the color pallete.

      pal <- colorNumeric(palette = ColorsToUse,domain=data_to_map$weekday_hrly_count)

      title_text <- paste("Weekday Occurences of trips during<br>",timePeriodText, dataSetChoice,"<br>In Hourly Uber Movement Database Q1 2019")

      # Calculate Labels
      labels <- sprintf(
        "<strong>%s</strong><br/>%s",
        data_to_map$DISPLAY_NAME , paste(data_to_map$weekends_hrly_count,"Trips", dataSetChoice, "in this census tract")
      ) %>% lapply(htmltools::HTML)

      leafletProxy("map", data = data_to_map) %>% clearShapes() %>% clearControls() %>%
        addPolygons(fillColor = ~pal(weekends_hrly_count),
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    dashArray = "3",
                    fillOpacity = 0.7,
                    highlight = highlightOptions(
                      weight = 5,
                      color = "#666",
                      dashArray = "",
                      fillOpacity = opacity,
                      bringToFront = TRUE),
                    label = labels,
                    labelOptions = labelOptions(
                      style = list("font-weight" = "normal", padding = "3px 8px"),
                      textsize = "15px",
                      direction = "auto")) %>%
        addLegend(pal = pal, values = ~weekends_hrly_count, opacity = 0.7, title = title_text,
                  position = "bottomleft")  %>% addTiles()
    }
  } # End of Frequency Summarizations
  })
}
