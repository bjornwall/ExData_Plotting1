library("dplyr")

txtfile <- "household_power_consumption.txt"

##' Calculate an estimate of the number of lines to read
##' The dataset holds data from Dec 2006 to Nov 2010, i.e. maximum 48 full months, in 2075259 rows.
##' We're interested in Feb 1st-2nd 2007, so reading approximately 3 months worth will be enough.
##' 3/48 ~ 6,25%, corresponding to 2075259 x 6,25% = 130 000 rows
##Read the data
df <- read.csv2(txtfile, header = TRUE, sep = ";", quote = "\"",
          dec = ".", fill = TRUE, comment.char = "",
          na.strings = c("?"), nrows = 130000,
          colClasses = c("character", "character", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"))
tibble <- tbl_df(df)

##' Verify we got the requested dates
head(tibble)
tail(tibble)

#Combine date and time into new variable
datetimechar <- paste(tibble$Date, tibble$Time, sep=" ")
#str(datetimechar)
datetimeposixct <- as.POSIXct(datetimechar, format = "%d/%m/%Y %H:%M:%S")
datetimeposixlt <- as.POSIXlt(datetimeposixct)
tibble <- cbind(tibble, datetimeposixct)
tibble <- cbind(tibble, datetimeposixlt)
tibble$Date <- as.Date(tibble$Date, format = "%d/%m/%Y")
tibble$Time <- strptime(tibble$Time, format = "%H:%M:%S")
#The date portion of Time is today's date, which is ok for our purposes

startDate <- as.Date("2007-02-01", format = "%Y-%m-%d")
endDate <- as.Date("2007-02-02", format = "%Y-%m-%d")
tibble <- tibble[(tibble$Date %in% c(startDate, endDate)),]

#tibble <- mutate(tibble, dateFactor = factor(weekdays(tibble$Date), levels = unique(weekdays(tibble$Date)), ordered = TRUE))
summary(tibble)

rm(datetimeposixct)
rm(datetimeposixlt)
rm(df)

plot(x = tibble$datetimeposixct, y=tibble$Global_active_power,  type = "n", main="",
     ylab = "Global Active Power (kilowatts)", xlab = "")
lines(x = tibble$datetimeposixct, tibble$Global_active_power)

#plot(y = tibble$Global_active_power, x = weekdays(d, TRUE) ,type = "n")

dev.copy(png, file = "plot2.png", width=480, height=480)
dev.off()
