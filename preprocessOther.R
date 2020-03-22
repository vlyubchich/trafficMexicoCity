rm(list = ls())

##### Dates of analysis #####
# Need to start with all dates in the period because weather or traffic data for some
# days may be missing, so we need to catch that.
# Date range: 1997--2015, but will truncate later
Dates <- seq(from = as.Date("1997-01-01"), to = as.Date("2015-12-31"), by = 1)
Years <- as.numeric(format(Dates, "%Y"))
years <- unique(Years)
Months <- as.numeric(format(Dates, "%m"))
Days <- as.numeric(format(Dates, "%d"))
Weekdays <- as.numeric(format(Dates, "%u")) #see ?strptime


##### Weekends #####
Weekends <- rep(0, length(Dates))
Weekends[Weekdays == 6 | Weekdays == 7] <- 1
Weekends <- as.factor(Weekends)


##### Holidays #####
#https://www.officeholidays.com/countries/mexico/2015
Holidays <- rep(0, length(Dates))
#New Year's Day (Jan 1):
Holidays[Months == 1 & Days == 1] <- 1
#Constitution Day (first Monday in February):
tmp <- which(Months == 2 & Weekdays == 1) #all Mondays in Feb
tmp <- tapply(tmp, Years[tmp], function(x) x[1]) #1st of those per year
Holidays[tmp] <- 1
#Benito Juarez's Birthday (3rd Monday in March):
tmp <- which(Months == 3 & Weekdays == 1) #all Mondays in Mar
tmp <- tapply(tmp, Years[tmp], function(x) x[3]) #3rd of those per year
Holidays[tmp] <- 1
#Easter
#http://jesus-is-lord.albertarose.org/easter/easter_dates.html
#https://en.wikipedia.org/wiki/List_of_dates_for_Easter
Easters <- as.Date(c("1997 March 30", "1998 April 12", "1999 April 4", "2000 April 23",
                     "2001 April 15", "2002 March 31", "2003 April 20", "2004 April 11",
                     "2005 March 27", "2006 April 16", "2007 April 8", "2008 March 23",
                     "2009 April 12", "2010 April 4", "2011 April 24", "2012 April 8",
                     "2013 March 31", "2014 April 20", "2015 April 5"),
                   format = "%Y %B %d")
#check that all those days were Sundays:
all(Weekdays[is.element(Dates, Easters)] == 7) #TRUE
tmp <- which(is.element(Dates, Easters)) #positions of Easters
Holidays[tmp] <- 1
#Maundy Thursday (Thursday before Easter Sunday):
Holidays[tmp - 3] <- 1
#Good Friday (Friday before Easter Sunday)
Holidays[tmp - 2] <- 1
#Labor Day (May 1):
Holidays[Months == 5 & Days == 1] <- 1
#Independence Day (Sept 16):
Holidays[Months == 9 & Days == 16] <- 1
#Mexico Day of the Races (Oct 12):
Holidays[Months == 10 & Days == 12] <- 1
#Day of the Dead (Nov 2):
Holidays[Months == 11 & Days == 2] <- 1
#Revolution Day (3rd Monday of November):
tmp <- which(Months == 11 & Weekdays == 1) #all Mondays in Nov
tmp <- tapply(tmp, Years[tmp], function(x) x[3]) #3rd of those per year
Holidays[tmp] <- 1
#Day of the Virgin of Guadalupe (Dec 12):
Holidays[Months == 12 & Days == 12] <- 1
#Xmas Day (Dec 25):
Holidays[Months == 12 & Days == 25] <- 1
Holidays <- as.factor(Holidays)


##### Hoy No Circula #####
#https://en.wikipedia.org/wiki/Hoy_No_Circula
# Started in late 1989, Monday-Friday restrictions;
#permanent since 1990 winter, active all-year-round.
# Saturday restrictions are from 2008-07-05:
HNSSaturday <- rep(0, length(Dates))
HNSSaturday[Dates >= as.Date("2008-07-05") & Weekdays == 6] <- 1
HNSSaturday <- as.factor(HNSSaturday)


##### Cars registered #####
CarsReg <- numeric()
for (y in years) { # y=1997
    tmp <- read.csv(paste0("./dataraw/cars_registered/vmrc_", y, ".csv"))
    #9 is for "Ciudad de Mexico"
    tmp <- tmp[tmp$ID_ENTIDAD == 9, ]
    #sum over all municipalities within the city and over the three types of vehicles:
    CarsReg <- c(CarsReg, sum(tmp[, c("AUTO_OFICIAL", "AUTO_PUBLICO", "AUTO_PARTICULAR")]))
}


##### Accidents #####
DA <- read.csv("./dataraw/accidents.csv", nrows = 155466)
#One of the records is September 31, assign to be 30th:
DA$DIA[DA$MES == 9 & DA$DIA == 31] <- 30
DA$Count <- 1 #use this column later (aggregated) to tell how many accidents reported

######### Aggregate by day:
DAaDay <- aggregate.data.frame(DA, by = list(DA$ANIO, DA$MES, DA$DIA), sum)
#names(DAaDay)
daDay <- DAaDay[, grep("Group.|AUTOMOVIL|Count", names(DAaDay))]
names(daDay) <- c("Year", "Month", "Day", "NCars", "NAccid")
daDay <- daDay[order(daDay$Year, daDay$Month, daDay$Day),]

######### Aggregate by hour:
DAaHour <- aggregate.data.frame(DA, by = list(DA$ANIO, DA$MES, DA$DIA, DA$HORA), sum)
#names(DAaHour)
daHour <- DAaHour[, grep("Group.|AUTOMOVIL|Count", names(DAaHour))]
names(daHour) <- c("Year", "Month", "Day", "Hour", "NCars", "NAccid")
daHour <- daHour[order(daHour$Year, daHour$Month, daHour$Day, daHour$Hour),]

rm(tmp, DA, DAaDay, DAaHour, Easters, y)
save.image("./dataderived/image_preprocessOther.RData")
