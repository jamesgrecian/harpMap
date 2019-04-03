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
library(raster)
require(RCurl)
require(httr)
require(rgdal)
#devtools::install_github('andrewsali/shinycssloaders')
require(shinycssloaders)
require(rdrop2)

# Load data from SMRU server and format for plotting using leaflet
# define data url
#harps <- read_html("http://www.smru.st-andrews.ac.uk/Instrumentation/php/location.php?gref=hp6&seq=82955EBB1425FAA9E053F909FB8AEE36") 

# find tag ids
#ids <- harps %>% html_nodes('h3') %>% html_text()
# extract most recent locations
#harps <- harps %>% html_nodes('table') %>% html_table()
# add id to each dataframe
#harps <- mapply(cbind, harps, "id" = ids, SIMPLIFY = F)
# unlist
#harps <- dplyr::bind_rows(harps)

# rearrange columns
#harps <- harps %>% dplyr::select("id", "Received (UTC)", "LQ", "Latitude", "Longitude", "No. mess", "Best level", "Vmask")
#names(harps)[2] <- "datetime_utc"
# convert to tibble
#harps <- as_tibble(harps)
#harps <- harps %>% mutate(datetime_utc = ymd_hms(datetime_utc))
#order by time
#harps <- harps %>% arrange(id, datetime_utc)
#filter out data prior to deployment
#harps <- harps %>% filter(datetime_utc > "2019-03-22 00:00:01")

# run foisGras?
# is it possible to load from dropbox...?
harps <- drop_read_csv("hp6_raw_locs.csv")
harps <- harps %>% rename("id" = id,
                      "datetime_utc" = date,
                      "LQ" = lc,
                      "Longitude" = lon,
                      "Latitude" = lat)

#fitted <- drop_read_csv("hp6_fitted_locs.csv") %>% as_tibble()
#fitted <- fitted %>% rename("datetime_utc" = date,
#                            "Longitude" = lon,
#                            "Latitude" = lat)
#harps <- fitted



# set up palette
pal <- colorFactor(viridis_pal(option = "D")(length(unique(harps$id))),
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


# Load in sea ice data from NSIDC
#Use RCurl library to query FTP server for most recent data
date <- as.Date(Sys.Date(), "%m/%d/%y")
mo <- paste0(strftime(date,"%m"), "_", strftime(date,"%b"))
yr <- year(date)
url = "ftp://anonymous:wjg5@sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/geotiff/"
fn <- RCurl::getURL(paste0(url, yr, "/", mo, "/"), ftp.use.epsv = FALSE, dirlistonly = TRUE, verbose = F)
fn <- paste(paste0(url, yr, "/", mo, "/"), strsplit(fn, "\r*\n")[[1]], sep = "") 
fn <- fn[grep("concentration", fn)]
fn <- fn[length(fn)]
res <- httr::GET(fn, write_disk(basename(fn), overwrite = T))
ice <- raster(res$request$output$path)
ice[ice>1000] <- NA
ice <- ice/10
projection(ice) = "+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +a=6378273 +b=6356889.449 +units=m +no_defs"

#Reproject ice data to EPSG:3857
prj <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
ice <- projectRaster(ice, crs = CRS(prj), method = 'ngb', res = 25000) #bilinear seems to give NAs?!
ice[ice == 0] <- NA

ice_pal <- colorNumeric(palette = "Blues",
                      domain = values(ice),
                      na.color = "transparent",
                      reverse = T)
