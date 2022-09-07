raw_lines <- readLines('spx_historical_data.txt')
raw_lines <- gsub("\t", ' ', raw_lines)

raw_dt <- as.data.table(raw_lines)
raw_cl <- c('mm', 'dd', 'yy', 'p1', 'p2', 'p3', 'p4', 'p5', 'qty') 
raw_dt[,  (raw_cl) := tstrsplit(raw_lines, " ", fixed = T)][, raw_lines := NULL]

col_dt <- c('dd', 'mm', 'yy', 'p1')
raw_dt <- raw_dt[, .SD, .SDcols = col_dt]
raw_dt <- raw_dt[, 
                 (col_dt) := lapply(.SD, function(i){gsub(',', '', i)}), 
                 .SDcols = col_dt]
raw_dt <- raw_dt[, 
                 (col_dt) := lapply(.SD, function(i){gsub(' ', '', i)}), 
                 .SDcols = col_dt]

raw_dt$p1 <- as.numeric(raw_dt$p1)
spx_dates <- with(raw_dt, lubridate::ymd(paste(yy, mm, dd, sep = '-')))

raw_dt <- raw_dt[, dates := spx_dates][, c('dd', 'mm', 'yy') := NULL]

setcolorder(raw_dt, neworder = c('dates', 'p1'))
setnames(raw_dt, colnames(raw_dt), c('dates', 'spx'))

spx     <- copy(raw_dt)
spx$spx <- as.numeric(spx$spx)

rm(raw_dt, col_dt, raw_cl, raw_lines, spx_dates)
return(spx)