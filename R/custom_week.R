custom_week <- function(x) {
  start_year <- lubridate::year(min(x))
  end_year   <- lubridate::year(max(x))
  start_date <- lubridate::as_date(glue::glue("{start_year}-01-01"))
  end_date   <- lubridate::as_date(glue::glue("{end_year}-12-31"))
  dates      <- seq.Date(start_date, end_date, by = "1 days")
  weekdays   <- lubridate::wday(dates, week_start = 1L)
  years      <- lubridate::year(dates)
  dt         <- data.table::data.table(date = dates, wd = weekdays, year = years)
  dt         <- dt[, .(week = get_week_custom(.SD), date = date, wd = wd), by = "year"]
  dt_origin  <- data.table::data.table(date = x)
  merge(dt_origin, dt, by = "date", all.x = TRUE)[["week"]]
}

get_week_custom <- function(dt) {
  first_wd <- dt[["wd"]][1]
  len_sd   <- nrow(dt)
  len_miss <- first_wd - 1
  new_dt   <- if (len_miss > 0) {
    data.table::data.table(wd = c(seq(1, len_miss), dt[["wd"]]), dummy = 0L)
  } else {
    data.table::data.table(wd = dt[["wd"]], dummy = 0L)
  }
  new_dt[, week := .(seq_len(nrow(.SD))), by = "wd"]
  new_dt[["week"]][(1 + len_miss):nrow(new_dt)]
}
