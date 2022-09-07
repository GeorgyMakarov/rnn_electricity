pkgs <- c('dplyr', 'ggplot2', 'data.table')
dpnd <- lapply(pkgs, library, character.only = T)
rm(pkgs, dpnd)

source('aggregate_spx_fx.R')
source('aggregate_sales.R')


# Add missing dates with mean of the same day from other years to allow us to
# have full data
txn           <- txn[order(dates), ]
missing_dates <- dt$dates[which(!(dt$dates %in% txn$dates))]

tmp <- copy(txn)
tmp[, `:=` (mth = lubridate::month(dates), ddd = lubridate::day(dates))]
tmp <- tmp[mth == 12 & ddd == 31, ]
unique_days <- length(unique(tmp$dates))
tmp <- tmp[, .(rating = mean(rating),
               price  = mean(price),
               mean_p = mean(mean_p),
               sd_p   = mean(sd_p)), by = c('sku', 'cust_id')]
pick_cust <- floor(nrow(tmp) / unique_days) ## we need only part of tmp

add_dates <- lapply(
  X   = 1:length(missing_dates), 
  FUN = function(md){
    seed <- 123 + md
    print(seed)
    set.seed(seed)
    idx <- sample(1:nrow(tmp), pick_cust)
    res <- tmp[idx, ]
    return(res)
  }
)

names(add_dates) <- missing_dates
add_dates <- rbindlist(add_dates, fill = T, idcol = 'dates')
check_col_order <- identical(colnames(add_dates), colnames(txn))
add_dates$dates <- lubridate::as_date(add_dates$dates)

txn <- rbind(txn, add_dates)
txn <- txn[order(dates), ]
rm(missing_dates, tmp, add_dates, check_col_order, unique_days, pick_cust)


# Merge SPX and FX into transactions
sub_dt <- dt[, .SD, .SDcols = c('dates', 'spx', 'fx')]
all_dt <- merge(txn, sub_dt, by = 'dates', all.x = T)
all_dt[, qty := 1]
rm(dt, txn, sub_dt)

# Define constants to be used in sales formulae
mean_p <- mean(all_dt$mean_p)
sd_p   <- mean(all_dt$sd_p)

# Aggregate by dates
all_dt <- all_dt[, .(rating = mean(rating), 
                     spx    = mean(spx),
                     fx     = mean(fx),
                     sales  = sum(price),
                     qty    = sum(qty)), by = 'dates']

# Rescale all variables for easier formula
dh <- all_dt$spx
re <- all_dt$fx
fc <- all_dt$rating
ep <- all_dt$qty
dr <- -2 * log((ep / (3.7 * dh)) + (2.51 / re * sqrt(fc)) + 0.1)
dr <- 1 - 0.01*dr

all_dt[, sales := round(sales * dr, 3)]
rm(dh, re, fc, ep, dr)

setcolorder(all_dt, neworder = c('dates', 'sales', 'qty', 'rating', 'spx', 'fx'))
write.csv(all_dt, 'ts_data.csv', row.names = F, quote = F)
