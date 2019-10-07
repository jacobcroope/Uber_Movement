require(tidyverse)
require(sf)
# The Geometric Mean of a vector
gm_mean <- function(x, na.rm=TRUE){
  exp(sum(log(x[x > 0]), na.rm=na.rm) / length(x))
}

# Convert a list of points to a line: Utility function for a polyline decode where it drops a lat/lon vector set.
# Examples of use are in the various routing scripts but the basic form is something like
# st_as_sf(points_to_line(decoded_poly,"lon","lat"),crs=4326)
points_to_line <- function(data, long, lat, id_field = NULL, sort_field = NULL) {

  # Convert to SpatialPointsDataFrame
  coordinates(data) <- c(long, lat)

  # If there is a sort field...
  if (!is.null(sort_field)) {
    if (!is.null(id_field)) {
      data <- data[order(data[[id_field]], data[[sort_field]]), ]
    } else {
      data <- data[order(data[[sort_field]]), ]
    }
  }

  # If there is only one path...
  if (is.null(id_field)) {

    lines <- SpatialLines(list(Lines(list(Line(data)), "id")))

    return(lines)

    # Now, if we have multiple lines...
  } else if (!is.null(id_field)) {

    # Split into a list by ID field
    paths <- sp::split(data, data[[id_field]])

    sp_lines <- SpatialLines(list(Lines(list(Line(paths[[1]])), "line1")))

    # I like for loops, what can I say...
    for (p in 2:length(paths)) {
      id <- paste0("line", as.character(p))
      l <- SpatialLines(list(Lines(list(Line(paths[[p]])), id)))
      sp_lines <- spRbind(sp_lines, l)
    }

    return(sp_lines)
  }
}


polyline_to_sf <- function (polyline_to_decode) {
  # this does the work.
  require(googlePolylines)
  #
  if (~is.character(polyline_to_decode)) {
    decoded_poly <- googlePolylines::decode(polyline_to_decode)[[1]]
    sf_object <- st_as_sf(points_to_line(decoded_poly,"lon","lat"),crs=4326)
    # geodf <- gepaf::decodePolyline(res$routes$geometry)[, c(2, 1)]
    st_crs(sf_object) =4326
  }

  return (sf_object)
}
