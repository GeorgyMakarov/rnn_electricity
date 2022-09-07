library(conjurer)

# Make customers dictionary to be used across all years
nc        <- 250
id        <- buildCust(numOfCust = nc)
nm        <- buildNames(numOfNames = nc, minLength = 5, maxLength = 8)
rating    <- buildNum(n = 28, st = 20, en = 100, disp = 0.5, outliers = 1)
set.seed(123)
rating    <- sample(rating, nc, replace = T)
customers <- data.frame(id, nm, rating = rating)
rm(nc, id, nm, rating)

# Make list of products
products  <- buildProd(numOfProd = 10, minPrice = 5, maxPrice = 50)

# Make list of transactions during the years
all_nms <- seq(2011, 2021, by = 1)
all_txn <- lapply(
  X   = 1:length(all_nms),
  FUN = function(i){
    
    # Pick random Pareto terms for every year
    set.seed(123 + i)
    p1 <- round(runif(1, 70, 80), 0)
    p3 <- round(runif(1, 75, 85), 0)
    p2 <- 100 - p1
    p4 <- 100 - p3
    
    r <- sign(ifelse(i %% 2, 1, -1))
    r <- round((1 + 0.03 * r) ^ i, 2)
    r <- 2e3 * r
    
    # Generate transactions
    suppressWarnings(
      txn_current <- genTrans(
        cycles       = 'q',
        spike        = 12,
        outliers     = 0,
        trend        = ifelse(i %% 2, 1, -1),
        transactions = r
      )
    )
    
    # Spread transactions between customers and products
    cust_txn <- buildPareto(customers$id, txn_current$transactionID, pareto = c(p1, p2))
    prod_txn <- buildPareto(products$SKU, txn_current$transactionID, pareto = c(p3, p4))
    names(cust_txn) <- c('transactionID', 'id')
    names(prod_txn) <- c('transactionID', 'SKU')
    
    # Merge all data together
    df1 <- merge(x = cust_txn, y = prod_txn, by = 'transactionID')
    df2 <- merge(x = df1, y = txn_current, by = 'transactionID', all.x = T)
    
    # Merge customers and prices
    df3 <- merge(x = df2, y = customers, by = 'id', all.x = T)
    df3 <- merge(x = df3, y = products, by = 'SKU', all.x = T)
    
    colnames(df3) <- c('sku', 'cust_id', 'txn_id', 'day_n', 'mth_n', 'cust_n', 'rating', 'price')
    
    return(df3)
  }
)

names(all_txn) <- all_nms
mean_price     <- round(mean(products$Price), 2)
sd_price       <- round(sd(products$Price), 2)
rm(customers, products, all_nms)

# Allocate customers to transactions
all_txn_dt <- data.table::rbindlist(all_txn, fill = T, idcol = 'year')
rm(all_txn)

dt <- data.table::copy(all_txn_dt)
rm(all_txn_dt)

dt$mean_p <- mean_price
dt$sd_p   <- sd_price
rm(mean_price, sd_price)

write.csv(dt, 'historical_data.csv', row.names = F)