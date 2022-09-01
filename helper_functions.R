#' Find outliers using standard deviation
#' 
#' This function finds outliers using standard deviation method.
#'
#' @param x numeric vector
#'
#' @return numeric vector
#' @export
find_out_sd <- function(x){
  mn  <- mean(x)
  std <- sd(x)
  
  t_min <- mn - (3 * std)
  t_max <- mn + (3 * std)
  
  res <- which(x < t_min | x > t_max)
  return(res)
}




#' Find outliers using median
#' 
#' This function finds outliers using median deviation methods.
#'
#' @param x numeric vector
#'
#' @return numeric vector
#' @export
find_out_mad <- function(x){
  mad_x       <- mad(x)
  mad_no_mult <- mad(x, const = 1)
  sd_x        <- sd(x)
  b_ratio     <- sd_x / mad_no_mult
  median_x    <- median(x)
  abs_dev     <- abs(x - median_x)
  mad_x_comp  <- b_ratio * median(abs_dev)
  use_mad     <- max(c(mad_x, mad_x_comp))
  t_min       <- median_x - (3 * use_mad)
  t_max       <- median_x + (3 * use_mad)
  
  res <- which(x < t_min | x > t_max)
  return(res)
}



#' Find outliers using inter quantile range
#' 
#' This function finds outliers using inter quantile method 
#'
#' @param x numeric vector
#'
#' @return numeric vector
#' @export
find_out_iqr <- function(x){
  
  q1 <- quantile(x, 0.25)
  q3 <- quantile(x, 0.75)
  
  iqr_x <- IQR(x)
  t_min <- q1 - (1.5 * iqr_x)
  t_max <- q3 + (1.5 * iqr_x)
  
  res <- which(x < t_min | x > t_max)
  return(res)
}



#' Find outliers using three different methods
#' 
#' This function finds outliers using three different methods and decides if
#' a value is an outlier by applying major vote scheme.
#'
#' @param x numeric vector
#'
#' @return numeric vector
#' @export
find_outs <- function(x){
  ot1 <- find_out_sd(x)
  ot2 <- find_out_mad(x)
  ot3 <- find_out_iqr(x)
  
  df <- matrix(0, nrow = length(x), ncol = 3)
  df <- data.table::as.data.table(df)
  
  setnames(df, colnames(df), c('o1', 'o2', 'o3'))
  df$o1[ot1] <- 1
  df$o2[ot2] <- 1
  df$o3[ot3] <- 1
  
  df <- df[, res := o1 + o2 + o3]
  df$test              <- F
  df$test[df$res >= 2] <- T
  
  res <- which(df$test)
  return(res)
}



smooth_out <- function(df, test, raw_dt){
  i     <- names(which(apply(raw_dt, 2, function(i){all(i == df)})))
  test  <- test[[i]]
  # df_mn <- as.numeric(lapply(test, function(i){mean(c(df[i - 1], df[i + 1]))}))
  df_mn <- round(mean(df[-test]), 3)
  df[test] <- df_mn
  return(df)
}


