tooltip <- function(date, n) {
  glue::glue("<h4>{date}</h4>{n} commits")
}

na.replace <- function(x, value = 0) {
  x[is.na(x)] <- value
  x
}
