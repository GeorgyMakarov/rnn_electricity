get_year <- function(d){
  count_years <- as.POSIXlt(d)$year + 1900
  count_days  <- table(count_years)
  count_days  <- as.numeric(count_days)
  names(count_days) <- unique(count_years)
  return(count_days)
}

get_b_coef <- function(rng, nd, freq_req){
  b_sequence <- seq(rng[1], rng[2], by = 0.1)
  b_vars <- lapply(b_sequence, function(b){find_pgram(b, sum(nd))})
  b_vars <- data.table::rbindlist(b_vars, fill = T)
  b_best <- b_vars[freq <= as.numeric(freq_req), ]
  b_best <- b_best$b[1]
  return(b_best)
}

find_pgram <- function(b, len_days){
  t_seq  <- seq(0, 4 * pi, length.out = len_days)
  y      <- sin(as.numeric(b) * t_seq)
  p_gram <- TSA::periodogram(y, plot = F)
  p_gram <- data.frame(freq = p_gram$freq, spec = p_gram$spec)
  p_gram <- p_gram %>% arrange(desc(spec)) %>% head(1)
  p_gram <- round(1 / p_gram$freq, 0)
  res <- data.table::as.data.table(data.frame(b = b, freq = p_gram))
  return(res)
}
