rm(list = ls())

########## Load data ##########
#load accidents data and calendar variables:
load("./dataderived/image_preprocessOther.RData")
#check we have 24 hours of data in each of those dates
tmp <- table(daHour$Year)
if(!all(is.element(tmp, c(365*24, 366*24)))) { #if the rule is violated
    tmp <- expand.grid(Dates, Hour = 0:23)
    names(tmp)[1] <- "Date"
    tmp$Year <- as.numeric(format(tmp$Date, "%Y"))
    tmp$Month <- as.numeric(format(tmp$Date, "%m"))
    tmp$Day <- as.numeric(format(tmp$Date, "%d"))
    daHour <- merge(daHour, tmp, all = TRUE)
    summary(daHour)
    daHour$NCars[is.na(daHour$NCars)] <- 0
    daHour$NAccid[is.na(daHour$NAccid)] <- 0
}

#load weather data:
WHour <- readRDS("./dataderived/WHour.RDS")


########## Merge at HOURLY level ##########
#add hourly weather to traffic
DataHour <- merge(daHour, WHour, all = TRUE)
#tapply(DataHour$Temperature, DataHour$Year, summary)

#Truncate to 2001-01-01 -- 2015-11-30
DataHour <- DataHour[DataHour$Year >= 2001 & DataHour$Year <= 2015,]
#check we have 24 hours of data in each of those dates
tmp <- table(DataHour$Year)
all(is.element(tmp, c(365*24, 366*24)))
DataHour <- DataHour[!(DataHour$Year == 2015 & DataHour$Month == 12),]

#add other vars
CR <- data.frame(Year = years, CarsReg) #annual data on the number of registered cars
Other <- data.frame(Year = Years, Month = Months, Day = Days, Weekday = Weekdays,
                    Weekend = Weekends, Holiday = Holidays, Date = Dates,
                    HNSSaturday)
#add number or cars in the city:
Other <- merge(Other, CR)
Other$Weekday <- factor(Other$Weekday)
DataHour <- merge(DataHour, Other, all.x = TRUE)
DataHour <- DataHour[order(DataHour$Year, DataHour$Month, DataHour$Day, DataHour$Hour),]
#Number of cars being in an accident and number of accidents per 100,000 cars in the city:
DataHour$NCarsPer100000 <- DataHour$NCars * 100000 / DataHour$CarsReg
DataHour$NAccidPer100000 <- DataHour$NAccid * 100000 / DataHour$CarsReg
summary(DataHour)
# plot.ts(DataHour$NCars)
# plot.ts(DataHour$NAccid)
# plot.ts(DataHour$NCarsPer100000)
# plot.ts(DataHour$NAccidPer100000)



########## Merge at DAILY level ##########
#Truncate to 2001-01-01 -- 2015-11-30
DataDay <- daDay[daDay$Year >= 2001 & daDay$Year <= 2015,]
DataDay <- DataDay[!(DataDay$Year == 2015 & DataDay$Month == 12),]

#add other vars
DataDay <- merge(DataDay, Other, all.x = TRUE)

#aggregate hourly weather data to daily and merge it too
tmp <- aggregate.data.frame(WHour$Temperature,
                            by = list(WHour$Year, WHour$Month, WHour$Day), mean, na.rm = TRUE)
names(tmp) <- c("Year", "Month", "Day", "Temperature")
DataDay <- merge(DataDay, tmp, all.x = TRUE)
tmp <- aggregate.data.frame(WHour$Rain,
                            by = list(WHour$Year, WHour$Month, WHour$Day), mean, na.rm = TRUE)
names(tmp) <- c("Year", "Month", "Day", "Rain")
tmp$Rain <- tmp$Rain * 24
DataDay <- merge(DataDay, tmp, all.x = TRUE)
tmp <- aggregate.data.frame(WHour$Wind,
                            by = list(WHour$Year, WHour$Month, WHour$Day), max, na.rm = TRUE)
names(tmp) <- c("Year", "Month", "Day", "Wind")
DataDay <- merge(DataDay, tmp, all.x = TRUE)
DataDay <- DataDay[order(DataDay$Year, DataDay$Month, DataDay$Day),]
#Number of cars being in an accident and number of accidents per 100,000 cars in the city:
DataDay$NCarsPer100000 <- DataDay$NCars * 100000 / DataDay$CarsReg
DataDay$NAccidPer100000 <- DataDay$NAccid * 100000 / DataDay$CarsReg
summary(DataDay)
# plot.ts(DataDay$NCars)
# plot.ts(DataDay$NAccid)
# plot.ts(DataDay$NCarsPer100000)
# plot.ts(DataDay$NAccidPer100000)


########## Check that totals are equal ##########
sum(DataDay$NAccid) == sum(DataHour$NAccid)
sum(DataDay$NCars) == sum(DataHour$NCars)

save(CR, DataDay, DataHour,
     file = "./dataderived/image_preprocessBoth.RData")
