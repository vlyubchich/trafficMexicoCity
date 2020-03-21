rm(list = ls())

# Get weather data from the following stations
# (data files for each station are in a separate subfolder)
# into one data frame, then average across stations and save as RDS file.
STATIONS <- c("cchn", "cchs", "enp1", "enp6", "enp8")

for(s in 1:length(STATIONS)){
    TMP <- data.frame(Date = numeric(), Time = numeric(), Temp = numeric(),
                      Wind = numeric(), Rain = numeric())
    nms <- names(TMP)
    Station <- STATIONS[s]
    path <- paste0("./dataraw/weather/", Station, "/")
    FILES <- list.files(path)
    FILES <- grep(".txt", FILES, ignore.case = TRUE, value = TRUE)
    for(f in 1:length(FILES)){
        ##### Select columns corresponding to Date, Time, Temperature, WindSpeed, and Rain.
        # Collect column names:
        tmp <- read.delim(paste(path, FILES[f], sep = ""), header = FALSE, nrows = 2)
        # Merge multi-row column names:
        tmp <- sapply(1:ncol(tmp), function(x) paste(tmp[1,x], tmp[2,x]))
        # Find the index of columns we need:
        indDate <- grep("date", tmp, ignore.case = TRUE)
        indTime <- grep("time", tmp, ignore.case = TRUE)
        indTemp <- intersect(grep("temp", tmp, ignore.case = TRUE),
                             grep("out", tmp, ignore.case = TRUE))
        indWind <- intersect(grep("wind", tmp, ignore.case = TRUE),
                             grep("speed", tmp, ignore.case = TRUE))
        indRain <- grep("rain", tmp, ignore.case = TRUE)[1]
        IND <- c(indDate, indTime, indTemp, indWind, indRain)
        # Few files have problems, including missing or double headers. Manually process those:
        if(FILES[f] == "2007_ENP6.txt"){
            IND <- c(1, 2, 3, 8, 18)
            tmp <- read.delim(paste(path, FILES[f], sep = ""), sep = "", header = FALSE,
                              na.strings = c("---"), nrows = 639)
            tmp1 <- tmp[IND]
            names(tmp1) <- nms
            tmp <- read.delim(paste(path, FILES[f], sep = ""), sep = "", header = FALSE,
                              skip = 639, na.strings = c("---"))
            tmp2 <- tmp[IND]
            names(tmp2) <- nms
            tmp <- rbind(tmp1, tmp2)
            IND <- c(1:ncol(tmp))
        }else if(FILES[f] == "2008_ENP6.txt"){
            IND <- c(1, 2, 3, 8, 18)
            tmp <- read.delim(paste(path, FILES[f], sep = ""), sep = "", header = FALSE,
                              na.strings = c("---"))
            tmprow <- which(is.element(tmp[,indDate], c("1/05/08389:39p", "1/05/08128:26p")))
            tmp <- tmp[-tmprow,]
        }else if(FILES[f] == "2004_CCHN.TXT"){
            tmp <- read.delim(paste(path, FILES[f], sep = ""), header = FALSE, skip = 2,
                              na.strings = c("---"), nrows = 2049)
            tmp1 <- tmp[IND]
            names(tmp1) <- nms
            tmp <- read.delim(paste(path, FILES[f], sep = ""), header = FALSE, skip = 2054,
                              na.strings = c("---"))
            IND <- c(1, 2, 3, 8, 18)
            tmp2 <- tmp[IND]
            names(tmp2) <- nms
            tmp <- rbind(tmp1, tmp2)
            IND <- c(1:ncol(tmp))
        }else if(FILES[f] == "2007_ENP8.txt" | FILES[f] == "2008_ENP8.txt"){
            tmp <- read.delim(paste(path, FILES[f], sep = ""), header = FALSE, skip = 3,
                              na.strings = c("---"))
            IND <- c(1, 2, 3, 8, 18)
        }else{ #if no specific problems (most common case)
            tmp <- read.delim(paste(path, FILES[f], sep = ""), header = FALSE, skip = 2,
                              na.strings = c("---"))
        }
        tmp <- tmp[IND]
        names(tmp) <- nms
        TMP <- rbind(TMP, tmp)
    }

    #Data quality control:
    TMP$Temp[TMP$Temp > 55 | TMP$Temp < -55] <- NA
    TMP$Rain[TMP$Rain > 1000] <- NA

    #Get the date information
    Date <- t(sapply(as.character(TMP$Date), function(x) as.numeric(strsplit(x, "/")[[1]])))
    Date[,3][Date[,3] < 50] <- Date[,3][Date[,3] < 50] + 2000
    Date[,3][Date[,3] < 100] <- Date[,3][Date[,3] < 100] + 1900
    TMP$Year <- Date[,3]
    TMP$Month <- Date[,2]
    TMP$Day <- Date[,1]

    #Get the hour information
    AMPM <- sapply(as.character(TMP$Time), function(x) substring(x, nchar(x)))
    Hour <- as.numeric(sapply(as.character(TMP$Time), function(x) strsplit(x, ":")[[1]][1]))
    Hour[AMPM == "p" & Hour < 12] <- Hour[AMPM == "p" & Hour < 12] + 12
    Hour[AMPM == "a" & Hour == 12] <- 0
    if(Station == "cchs"){
        Hour[TMP$Date == "05/10/00" & Hour > 23] <- 22
        Hour[TMP$Date == "28/07/01" & Hour > 23] <- c(21, 22)
        Hour[TMP$Date == "05/02/02" & Hour > 23] <- 0
    }
    TMP$Hour <- Hour

    TMP <- TMP[-c(1,2)]
    TMP <- aggregate(TMP, by = list(TMP$Year, TMP$Month, TMP$Day, TMP$Hour), mean, na.rm = TRUE)
    TMP <- TMP[-c(1:4)]
    names(TMP)[1:3] <- paste(names(TMP)[1:3], Station, sep = "_")
    assign(paste("Data", Station, sep = "_"), TMP)
}
# Merge data collected from different stations
dw <- merge(Data_cchn, Data_cchs, by = c("Year", "Month", "Day", "Hour"), all = TRUE)
dw <- merge(dw, Data_enp1, by = c("Year", "Month", "Day", "Hour"), all = TRUE)
dw <- merge(dw, Data_enp6, by = c("Year", "Month", "Day", "Hour"), all = TRUE)
dw <- merge(dw, Data_enp8, by = c("Year", "Month", "Day", "Hour"), all = TRUE)
# Aggregate data across stations
dw$Temperature <- rowMeans(dw[,grep("Temp", names(dw))], na.rm = TRUE)
dw$Wind <- rowMeans(dw[,grep("Wind", names(dw))], na.rm = TRUE)
dw$Rain <- rowMeans(dw[,grep("Rain", names(dw))], na.rm = TRUE)
WHour <- dw[-c(5:19)] #hourly weather
# Save file
saveRDS(WHour, file = "./dataderived/WHour.RDS")

