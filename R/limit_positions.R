get_pos <- function(df) {
  dates                    <- df[["date"]]
  weeks                    <- df[["week"]]
  weekdays                 <- lubridate::wday(dates, week_start = 1L)
  first_day                <- min(df[["date"]])
  first_week               <- min(df[["week"]])
  last_week                <- max(df[["week"]])
  month                    <- lubridate::month(first_day)
  year                     <- lubridate::year(first_day)
  days_in_month            <- as.numeric(lubridate::days_in_month(month))
  last_date_month          <- lubridate::as_date(glue::glue("{year}-{month}-{days_in_month}"))
  first_date_month         <- lubridate::as_date(glue::glue("{year}-{month}-01"))
  last_date_year           <- lubridate::as_date(glue::glue("{year}-12-31"))
  first_date_year          <- lubridate::as_date(glue::glue("{year}-01-01"))
  last_week_year           <- custom_week(last_date_year)
  first_week_year          <- custom_week(first_date_year)
  weekday_first_date_month <- lubridate::wday(first_date_month, week_start = 1L)
  all_ids                  <- seq_len(nrow(df))

  if (weekday_first_date_month == 1L) {
    id_limit_right <- which(weeks == last_week & weeks != last_week_year)
    id_limit_left  <- which(weeks == first_week & weeks != first_week_year)
    id_limit_up    <- c()
  } else {
    id_limit_up    <- which(weeks == first_week & weekdays == weekday_first_date_month & weeks != first_week_year)
    id_limit_right <- which(weeks == last_week & weeks != last_week_year)
    id_limit_left  <- setdiff(which(weeks == first_week & weeks != first_week_year), id_limit_up)
  }
  id_rest <- setdiff(all_ids, c(id_limit_left, id_limit_up, id_limit_right))

  l <- list()
  if (length(id_limit_left) > 0)  l <- c(l, list(data.table::data.table(id = id_limit_left, pos = "limit_left")))
  if (length(id_limit_right) > 0) l <- c(l, list(data.table::data.table(id = id_limit_right, pos = "limit_right")))
  if (length(id_limit_up) > 0)    l <- c(l, list(data.table::data.table(id = id_limit_up, pos = "limit_up")))
  if (length(id_rest) > 0)        l <- c(l, list(data.table::data.table(id = id_rest, pos = NA_character_)))
  data.table::rbindlist(l, use.names = TRUE)[order(id)][["pos"]]
}

build_x <- function(x, pos) {
  if (pos == "limit_left") {
    x - 0.5
  } else if (pos == "limit_up") {
    c(x - 0.5, x - 0.5)
  } else if (pos == "limit_right") {
    x + 0.5
  }
}

build_xend <- function(x, pos) {
  if (pos == "limit_left") {
    x - 0.5
  } else if (pos == "limit_up") {
    c(x - 0.5, x + 0.5)
  } else if (pos == "limit_right") {
    x + 0.5
  }
}

build_y <- function(y, pos) {
  if (pos == "limit_left") {
    y - 0.5
  } else if (pos == "limit_up") {
    c(y - 0.5, y + 0.5)
  } else if (pos == "limit_right") {
    y - 0.5
  }
}

build_yend <- function(y, pos) {
  if (pos == "limit_left") {
    y + 0.5
  } else if (pos == "limit_up") {
    c(y + 0.5, y + 0.5)
  } else if (pos == "limit_right") {
    y + 0.5
  }
}
