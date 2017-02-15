# TZ training script for loading mobile survey and Tanzania grids
# code written by ... February 2017

install.packages("downloader","rgdal","raster", dependencies = T) ## install package to download data
require(downloader)
require(raster)
require(rgdal)

dir.create("data", showWarnings=F)
setwd("./data")

download("https://www.dropbox.com/s/nnoehn7wbwtqvk7/TZ_grids1k.zip?dl=0", "TZ_grids1k.zip",  mode="wb")
unzip("TZ_grids1k.zip", overwrite=T)
glist <- list.files(pattern="tif", full.names=T)
grids <- stack(glist)

download.file("https://www.dropbox.com/s/skdinhb5iing6mg/TZ_geos_012015.csv?dl=0", "./TZ_geos_012015.csv", mode= "wb")
geo <- read.table("TZ_geos_012015.csv", header=T, sep=",")

download.file("https://www.dropbox.com/s/02g8dmzvr18nyx3/Crop_TZ_JAN_2017.csv.zip?dl=0","./data/Crop_TZ_JAN_2017.csv.zip", mode="wb")
unzip("Crop_TZ_JAN_2017.csv.zip", overwrite=T)
mob <- read.table("Crop_TZ_JAN_2017.csv.zip", header=T, sep=",")
plot(geos$Lon,geos$Lat, cex=0.01)

geo.proj <- as.data.frame(project(cbind(geo$Lon, geo$Lat), "+proj=laea +ellps=WGS84 +lon_0=20 +lat_0=5 +units=m +no_defs"))
colnames(geo.proj) <- c("x","y") ## laea coordinates
geo <- cbind(geo, geo.proj)
coordinates(geo) <- ~x+y
projection(geo) <- projection(grids)
geogrd <- extract(grids, geo)
geogrd <- as.data.frame(geogrd)
geo <- cbind.data.frame(geo, geogrd)
geo <- unique(na.omit(geo)) ## includes only unique & complete records


