###
### Everything...
###

library(shiny)
library(leaflet)
require(rvest)
require(tidyverse)
require(viridisLite)
library(purrrlyr)
require(viridis)

# define data url
harps <- read_html("http://www.smru.st-andrews.ac.uk/Instrumentation/php/location.php?gref=hp6&seq=82955EBB1425FAA9E053F909FB8AEE36") 

# find tag ids
ids <- harps %>% html_nodes('h3') %>% html_text()

# extract most recent locations
harps <- harps %>% html_nodes('table') %>% html_table()

# add id to each dataframe
harps <- mapply(cbind, harps, "id" = ids, SIMPLIFY = F)

# unlist
harps <- dplyr::bind_rows(harps)

# rearrange columns
harps <- harps %>% select("id", "Received (UTC)", "LQ", "Latitude", "Longitude", "No. mess", "Best level", "Vmask")
names(harps)[2] <- "datetime_utc"

# run foisGras?

#order by time
harps <- harps %>% arrange(id, `Received (UTC)`)

# set up palette
pal <- colorFactor(viridis_pal(option = "D")(10),
                   domain = harps$id)

#https://github.com/rstudio/leaflet/issues/389
grouped_coords <- function(coord, group, order) {
  data.frame(coord = coord,
             group = group) %>%
    group_by(group) %>%
    by_slice(~c(.$coord, NA), .to = "output") %>%
    left_join(
      data.frame(group = group,
                 order = order) %>% 
        distinct()) %>%
    arrange(order) %>%
    .$output %>%
    unlist()
}


leaflet() %>%
  addProviderTiles(providers$Esri.WorldImagery) %>%
  addPolylines(lng = ~grouped_coords(Longitude, id, id),
               lat = ~grouped_coords(Latitude, id, id),
               color = ~pal(unique(id)),
               data = harps) %>%
  addMarkers(lng = ~Longitude,
             lat = ~Latitude,
             popup = ~ as.character(id),
             label = ~as.character(id),
             data = harps %>%
               group_by(id) %>%
               arrange(desc(datetime_utc))
             %>% slice(1)) %>%
  addLegend(position = 'bottomright',
            colors = viridis_pal(option = "D")(10),
            labels = unique(harps$id))

# add way marker for most recent location
# need to convert datetime to actual datetime...
# add clickable sea ice layer..?

# split into correct files and convert to shiny


