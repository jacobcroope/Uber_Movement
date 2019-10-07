library(leaflet)

# Choices for drop-downs
# Now we do groupings by Periods
# AM Peak (7-9)  3 hours
# Midday (10-15) 6 hours
# PM Peak (16-18) 3 hours
# Evening (19-23) 5 hours
# Early Morning (0-6) 7 hours

time_period <- c(
  "All Hours" = "All Hours",
  "AM Peak (7-10AM)" = "AM Peak",
  "Midday (10-4PM)" = "Midday",
  "PM Peak (4-7PM" = "PM Peak",
  "Evening (7PM-12AM)" = "Evening",
  "Early Morning (12AM-7AM)" = "Early Morning",
  "12-1AM" = "0",
  "1-2AM" = "1",
  "2-3AM" = "2",
  "3-4AM" = "3",
  "4-5AM" = "4",
  "5-6AM" = "5",
  "6-7AM" = "6",
  "7-8AM" = "7",
  "8-9AM" = "8",
  "9-10AM" = "9",
  "10-11AM" = "10",
  "11AM-12PM" = "11",
  "12-1PM" = "12",
  "1-2PM" = "13",
  "2-3PM" = "14",
  "3-4PM" = "15",
  "4-5PM" = "16",
  "5-6PM" = "17",
  "6-7PM" = "18",
  "7-8PM" = "19",
  "8-9PM" = "20",
  "9-10PM" = "21",
  "10-11PM" = "22",
  "11PM-12PM" = "23"
)

data_set_choice <- c(
  "Trips Starting" = "starting",
  "Trips Ending" = "ending",
  "Trips Starting - Trips Ending (Difference)" = "starting-ending",
  "Trips Starting + Trips Ending (Sum)" = "starting+ending"

)

weekday_choice <- c(
  "Entire Week" = "weekly",
  "Weekend Only" = "weekend",
  "Weekdays Only" = "weekday"
)

route_start <-  c(Uber_Route_Starts$MOVEMENT_ID)
names(route_start) <- c(Uber_Route_Starts$DISPLAY_NAME)

route_end <- c(filter(CT,MOVEMENT_ID %in% Google_Routes$dstid)$MOVEMENT_ID)
names(route_end) <- c(filter(CT,MOVEMENT_ID %in% Google_Routes$dstid)$DISPLAY_NAME)



# "Monday" = "0"
# "Tuesday" = "1"

navbarPage("Uber Movement Cincinnati Hourly Data Q1 2019", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="100%"),

      # Shiny versions prior to 0.11 should use class = "modal" instead.
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
        width = 330, height = "auto",
        # conditionalPanel(input.google == FALSE)
        h2("Time Of Day and Dataset Selecters for Frequency of Uber Movement Trips"),

        selectInput("time_period", "Time Period", time_period),
        selectInput("data_set_choice", "Starting Trip vs Ending Trip Count", data_set_choice, selected = "starting"),
        selectInput("weekday_choice", "Weekly / Weekend / Weekday",weekday_choice , selected = "weekly"),

        h2("Routing Data Set Selector"),
        h3("Disables Frequency When Selected"),

        checkboxInput("google", "Google Directions API",FALSE),
        checkboxInput("arcgis", "ArcGIS Simple Route API",FALSE),
        checkboxInput("osrm", "Open Source Routing Machine (OSRM)",FALSE),

        selectInput("route_start","Routing Start", route_start),
        selectInput("route_end","Routing End", route_end),
        # conditionalPanel("input.google == TRUE", numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
        # #   # Only prompt for threshold when coloring or sizing by superzip
        # #   numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
        # ),

        # selectInput("sourceid","Starting Census Tract")
        # conditionalPanel("input.time_period == 'time_period' || input.hod == 'superzip'",
        #   # Only prompt for threshold when coloring or sizing by superzip
        #   numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
        # ),

        # plotOutput("histCentile", height = 200),
        plotOutput("scatterDistanceTime", height = 250)
      ),
      # , tags$em('Coming Apart: The State of White America, 1960–2010'),

      tags$div(id="cite",
        'Data compiled for 2019 OHIO GIS Conference by Jacob Roope (2019). Data retrieved from Uber Movement, (c) 2019 Uber Technologies, Inc., https://movement.uber.com.'
        )
    )
  ),
  # # tabPanel("Route Explorer",
  #          div(class="outer",
  #
  #              tags$head(
  #                # Include our custom CSS
  #                includeCSS("styles.css"),
  #                includeScript("gomap.js")
  #              ),
  #
  #              # If not using custom CSS, set height of leafletOutput to a number instead of percent
  #              leafletOutput("route_map", width="100%", height="100%"),
  #
  #              # Shiny versions prior to 0.11 should use class = "modal" instead.
  #              absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
  #                            draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
  #                            width = 330, height = "auto",
  #
  #
  #                            # routing_data_set_choice <- c(
  #                            #   "Google Directions API" = "google",
  #                            #   "ArcGIS" = "ending",
  #                            #   "Open Source Routing Machine (OSRM) - Trips Ending (Difference)" = "starting-ending",
  #                            #   "Trips Starting + Trips Ending (Sum)" = "starting+ending"
  #                            #
  #                            # )
  #                            # conditionalPanel("input.time_period == 'time_period' || input.hod == 'superzip'",
  #                            #   # Only prompt for threshold when coloring or sizing by superzip
  #                            #   numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
  #                            # ),
  #
  #                            # plotOutput("histCentile", height = 200),
  #                            # plotOutput("scatterCollegeIncome", height = 250)
  #              ),
  #              # , tags$em('Coming Apart: The State of White America, 1960–2010'),
  #
  #              tags$div(id="cite",
  #                       'Data compiled for 2019 OHIO GIS Conference by Jacob Roope (2019). Data retrieved from Uber Movement, (c) 2019 Uber Technologies, Inc., https://movement.uber.com.'
  #              )
  #          )
  # ),
  # tabPanel("Route Explorer",
  #   fluidRow(
  #     column(3,
  #       selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
  #     ),
  #     column(3,
  #       conditionalPanel("input.states",
  #         selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
  #       )
  #     ),
  #     column(3,
  #       conditionalPanel("input.states",
  #         selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
  #       )
  #     )
  #   ),
  #   fluidRow(
  #     column(1,
  #       numericInput("minScore", "Min score", min=0, max=100, value=0)
  #     ),
  #     column(1,
  #       numericInput("maxScore", "Max score", min=0, max=100, value=100)
  #     )
  #   ),
  #   hr(),
  #   DT::dataTableOutput("ziptable")
  # ),

  conditionalPanel("false", icon("crosshair"))
)
