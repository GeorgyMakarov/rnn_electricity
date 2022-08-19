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
  
  
}


