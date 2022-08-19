#' Collect temperature from sensors
#' 
#' This functions collects CPU temperature using `Linux` command `sensors`
#'
#' @param fn string, name of `bash` executable
#' @param val logical, record output value into `R` variable
#'
#' @return data.frame
#' @export
collect_temperature <- function(fn, val){
  com <- paste0('bash ', fn)
  res <- system(command = com, intern = val)
  
  # Extract temperature from each sensor
  t_data <- lapply(
    X   = 1:length(res),
    FUN = function(i){
      sensor <- res[i]
      sensor <- unlist(strsplit(sensor, " "))
      if ("Package" %in% sensor){
        out <- sensor[5]
      } else {
        out <- sensor[10]
      }
      
      out <- sub(pattern = "\\+",  replacement = "", out)
      out <- sub(pattern = "°C", replacement = "", out)
      out <- as.numeric(out)
      return(out)
    }
  )
  
  out_df <- data.frame(matrix(unlist(t_data), ncol = length(t_data)))
  colnames(out_df) <- c('t_main', 't1', 't2', 't3', 't4')
  
  return(out_df)
}
