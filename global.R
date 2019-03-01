############################
### Load data and format ###
############################

# libraries
require(shiny)
require(leaflet)
require(rvest)
require(tidyverse)
require(viridisLite)
require(purrrlyr)
require(viridis)
require(lubridate)

# Load data from SMRU server and format for plotting using leaflet
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

# convert to tibble
harps <- as_tibble(harps)
harps <- harps %>% mutate(datetime_utc = ymd_hms(datetime_utc))
#order by time
harps <- harps %>% arrange(id, datetime_utc)

# run foisGras?

# set up palette
pal <- colorFactor(viridis_pal(option = "D")(10),
                   domain = harps$id)


# define function to group tracks by animal id
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
