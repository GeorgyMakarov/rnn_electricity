source('transform_spx_data.R')
source('transform_fx_data.R')

# Generate sequence of dates to allow us to fill them with spx and fx
dd <- seq.Date(from = as.Date('2011-01-01'), 
               to   = as.Date('2021-12-31'), 
               by   = 'day')
dd <- lubridate::as_date(dd)
dd <- data.frame('dates' = dd)
dt <- as.data.table(dd)
rm(dd)

# Merge all available data points
dt <- merge(x = dt, y = spx, by = 'dates', all.x = T)
dt <- merge(x = dt, y = fx,  by = 'dates', all.x = T)
rm(spx, fx)

# Fill NA values with next or previous value
dt <- dt %>% tidyr::fill(spx, fx, .direction = 'updown')

# Replace outstanding observation with mean of its neighbors
fx_out <- which.min(dt$fx)
dt$fx[fx_out] <- mean(c(dt$fx[fx_out - 1], dt$fx[fx_out + 1]))

# Visual check that everything is fine
# plot(dt$spx, type = 'l')
# plot(dt$fx,  type = 'l')

# Compute relative difference of spx and fx
dt$spd <- c(0, diff(dt$spx)) / dt$spx
dt$fxd <- c(0, diff(dt$fx))  / dt$fx

# Normalize differences so that they match required polynomials
dt$spd_s <- scales::rescale(dt$spd, to = c(-52, 335))
dt$fxd_s <- scales::rescale(dt$fxd, to = c(-1.5, 5.4))


# Compute sales parts depending on regressors
# y = 370 + 0.32x1 + 3.88x2
x1 <- dt$spd_s
x2 <- dt$fxd_s
y  <- 370 + 0.32*x1 + 3.88*exp(x2)*sign(x2)
dt$sales <- y
rm(x1, x2, y, fx_out)

# Visual check that everything is fine
# plot(dt$spd, dt$sales)
# plot(dt$fxd, dt$sales)

# Drop not needed columns
dt <- dt[, .SD, .SDcols = c('dates', 'spx', 'fx', 'spd', 'fxd')]
return(dt)