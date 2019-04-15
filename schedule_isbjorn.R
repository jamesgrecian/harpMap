#####################################################################################
### Load in latest telemetry data from SMRU server and process for shiny plotting ###
#####################################################################################

# Set this script to run every 6 hours using crontab...
# crontab -e
# 0cd */6 * * * Rscript /schedule_isbjorn.R
# To remove try...
# crontab -l
# crontab -e

# Point to local libraries
#.libPaths("/home/james/R/x86_64-redhat-linux-gnu-library/3.5")

#"/usr/lib64/R/library"
#"/usr/share/R/library" 

# Load libraries
require(Hmisc)
require(dplyr)
require(rdrop2)
#require(foieGras)
require(xml2)
require(rvest)

# Download data from SMRU and unzip .mdb
download.file("http://gatty:SOI@www.smru.st-andrews.ac.uk/protected/hp6/db/hp6.zip", "~/hp6.zip")
unzip("~/hp6.zip", exdir = "~/", overwrite = T)

# Load in data from .mdb
dat <- Hmisc::mdb.get("~/hp6.mdb",  tables = "diag") %>% as_tibble()

# Select columns of interest for ct-crw
#dat <- dat %>% select("REF", "D.DATE", "LQ", "LON", "LAT", "SEMI.MAJOR.AXIS", "SEMI.MINOR.AXIS", "ELLIPSE.ORIENTATION")
dat <- dat %>% select("REF", "D.DATE", "LQ", "LON", "LAT")
dat <- dat %>% rename(id = REF,
                      date = D.DATE,
                      lc = LQ,
                      lon = LON,
                      lat = LAT) #,
#                      smaj = SEMI.MAJOR.AXIS,
#                      smin = SEMI.MINOR.AXIS,
#                      eor = ELLIPSE.ORIENTATION)

# Format date time
dat <- dat %>% mutate(date = as.POSIXct(dat$date, "%m/%d/%y %H:%M:%S", tz = "UTC"))
# Filter out data prior to deployment
dat <- dat %>% filter(date > "2019-03-22 00:00:01")
# Order by time
dat <- dat %>% arrange(id, date)

# Load data from SMRU server and format for plotting using leaflet
# define data url
harps <- xml2::read_html("http://www.smru.st-andrews.ac.uk/Instrumentation/php/location.php?gref=hp6&seq=82955EBB1425FAA9E053F909FB8AEE36") 

# find tag ids
ids <- harps %>% rvest::html_nodes('h3') %>% rvest::html_text()
# extract most recent locations
harps <- harps %>% rvest::html_nodes('table') %>% rvest::html_table()
# add id to each dataframe
harps <- mapply(cbind, harps, "id" = ids, SIMPLIFY = F)
# unlist
harps <- dplyr::bind_rows(harps)

# rearrange columns
harps <- harps %>% dplyr::select("id", "Received (UTC)", "LQ", "Longitude", "Latitude") #, "No. mess", "Best level", "Vmask")
names(harps)[2] <- "date"
names(harps)[3] <- "lc"
names(harps)[4] <- "lon"
names(harps)[5] <- "lat"

# convert to tibble
harps <- as_tibble(harps)
harps <- harps %>% dplyr::mutate(date = as.POSIXct(date, "%Y-%m-%d %H:%M:%S", tz = "UTC"))

#order by time
harps <- harps %>% arrange(id, date)
#filter out data prior to deployment
harps <- harps %>% filter(date > "2019-03-22 00:00:01")
#alter id to match .mdb file
harps <- harps %>% mutate(id = sapply(strsplit(id, " "), `[`, 1))
harps <- harps %>% mutate(id = paste0(id, "-19"))

new <- bind_rows(dat, harps)
new <- new %>% group_by(id) %>% arrange(id, date)


# Recode location class for prefilter algoritm
#dat <- new %>% mutate(lc = factor(lc))
#dat <- dat %>% mutate(lc = recode_factor(lc,
#                                  `0` = "0",
#                                  `-1` = "A",
#                                  `-2` = "B",
#                                  `-9` = "Z"))

# Fit continous time correlated random walk using least squares data
#fls <- foieGras::fit_ssm(dat, model = "crw", time.step = 6)

# Extract fitted values from model
#out <- foieGras::pluck(fls, "fitted")
#dat <- out %>% select("id", "date", "lon", "lat")

# Write formatted dataframe locally
write.csv(new, "~/hp6_raw_locs.csv")
# Upload to dropbox
drop_auth(rdstoken = "/home/james/harpMap/token.rds")
drop_upload("~/hp6_raw_locs.csv")
