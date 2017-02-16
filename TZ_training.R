# Script for loading Tanzania mobile survey and grids
# code written by ... February 2017

# install.packages("downloader","rgdal","raster", dependencies = T) ## install package to download data
require(downloader)
require(raster)
require(rgdal)

# Data setup --------------------------------------------------------------
# Create a data folder in your current working directory
dir.create("data", showWarnings=F)
setwd("./data")

# load TZ 1K grids
download("https://www.dropbox.com/s/nnoehn7wbwtqvk7/TZ_grids1k.zip?dl=0", "TZ_grids1k.zip",  mode="wb")
unzip("TZ_grids1k.zip", overwrite=T)
glist <- list.files(pattern="tif", full.names=T)
grids <- stack(glist)

# load GeoSurvey data ... not run
# download.file("https://www.dropbox.com/s/339k17oic3n3ju6/TZ_geos_012015.csv?dl=0", "TZ_geos_012015.csv", mode= "wb")
# geo <- read.table("TZ_geos_012015.csv", header=T, sep=",")
# geo.proj <- as.data.frame(project(cbind(geo$Lon, geo$Lat), "+proj=laea +ellps=WGS84 +lon_0=20 +lat_0=5 +units=m +no_defs"))
# colnames(geo.proj) <- c("x","y")
# geo <- cbind(geo, geo.proj)
# coordinates(geo) <- ~x+y
# projection(geo) <- projection(grids)
# geogrd <- extract(grids, geo)
# geogrd <- as.data.frame(geogrd)
# geo <- cbind.data.frame(geo, geogrd)
# geo <- unique(na.omit(geo))

# Load MobileSurvey data
download.file("https://www.dropbox.com/s/02g8dmzvr18nyx3/Crop_TZ_JAN_2017.csv.zip?dl=0","Crop_TZ_JAN_2017.csv.zip", mode="wb")
unzip("Crop_TZ_JAN_2017.csv.zip", overwrite=T)
mob <- read.table("Crop_TZ_JAN_2017.csv", header=T, sep=",")
mob <- mob[c(1:2,16,19)] ## select only the needed data variables
colnames(mob) <- c("Lat", "Lon", "CRP", "MZP") ## adjust long names, CRP = cropland present?, MZP = maize present?
table(mob$CRP, mob$MZP) ## cross-tabulate maize by cropland as a simple check on the data

# Georeference MobileSurvey data and extract gridded variables
mob.proj <- as.data.frame(project(cbind(geo$Lon, geo$Lat), "+proj=laea +ellps=WGS84 +lon_0=20 +lat_0=5 +units=m +no_defs"))
colnames(mob.proj) <- c("x","y") ## laea coordinates
mob <- cbind(mob, mob.proj) ##
coordinates(mob) <- ~x+y ## create spatial points object
projection(mob) <- projection(grids) ## set coordinate reference system
mobgrd <- extract(grids, mob) ## extract gridded variables
mobgrd <- as.data.frame(mobgrd) ## convert back to a dataframe
mob <- cbind.data.frame(mob, mobgrd) ## combine gridded variable with points in a dataframe
mob <- unique(na.omit(mob)) ## includes only unique & complete MobileSurvey records






