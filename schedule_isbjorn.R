#####################################################################################
### Load in latest telemetry data from SMRU server and process for shiny plotting ###
#####################################################################################

# Set this script to run every 6 hours using crontab...
# crontab -e
# 1 */6 * * * Rscript /schedule_isbjorn.R
# To remove try...
# crontab -l
# crontab -e

# Load libraries
require(Hmisc)
require(tidyverse)
require(lubridate)
require(rdrop2)

# Download data from SMRU and unzip .mdb
download.file("http://gatty:SOI@www.smru.st-andrews.ac.uk/protected/hp6/db/hp6.zip", "~/hp6.zip")
unzip("~/hp6.zip", exdir = "~/", overwrite = T)

# Load in data from .mdb
dat <- Hmisc::mdb.get("~/hp6.mdb",  tables = "diag") %>% as_tibble()

# Select columns of interest for ct-crw
dat <- dat %>% select("REF", "D.DATE", "LQ", "LON", "LAT", "SEMI.MAJOR.AXIS", "SEMI.MINOR.AXIS", "ELLIPSE.ORIENTATION")
dat <- dat %>% rename(id = REF,
                      date = D.DATE,
                      lc = LQ,
                      lon = LON,
                      lat = LAT,
                      smaj = SEMI.MAJOR.AXIS,
                      smin = SEMI.MINOR.AXIS,
                      eor = ELLIPSE.ORIENTATION)

# Format date time
dat <- dat %>% mutate(date = mdy_hms(date, tz = "UTC"))
# Filter out data prior to deployment
dat <- dat %>% filter(date > "2019-03-22 00:00:01")
# Order by time
dat <- dat %>% arrange(id, date)

# Write formatted dataframe locally
write_csv(dat, "~/hp6_raw_locs.csv")
# Upload to dropbox
drop_upload("~/hp6_raw_locs.csv")

