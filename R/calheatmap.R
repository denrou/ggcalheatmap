#' Calendar Heatmap
#'
#' Plot a calendar heatmap from a data frame.
#'
#' @param df A data frame.
#' @param date,n Unquoted column names.
#' @param tooltip Either a character string or a tooltip function. If NULL, a `ggplot2` object object is returned,
#'                otherwise, a `ggiraph` object is returned.
#'
#' @importFrom data.table :=
#' @importFrom magrittr %>%
#'
#' @export
#'
ggcalheatmap <- function(df, date, n, tooltip = FALSE) {
  dt       <- data.table::data.table(date = df[[date]], n = df[[n]])
  dt_date  <- data.table::data.table(date = seq.Date(min(dt[["date"]]), max(dt[["date"]]), by = "1 days"))
  dt_merge <- merge(dt, dt_date, by = "date", all.y = TRUE)
  dt_sum   <- dt_merge[, .(n = sum(n)), by = "date"][
    ,
    .(
      date    = date,
      weekday = forcats::fct_rev(lubridate::wday(date, label = TRUE, abbr = FALSE, week_start = 1)),
      week    = custom_week(date),
      month   = lubridate::month(date, label = TRUE, abbr = FALSE),
      year    = lubridate::year(date),
      tooltip = tooltip(date, n),
      n       = n
    )
  ]
  dt_sum[, "pos" := get_pos(.SD), by = c("year", "month")]

  dt_limit <- rbind(dt_sum[!is.na(pos)], dt_sum[pos == "limit_up"])[order(date), .(
    x    = build_x(week, pos),
    xend = build_xend(week, pos),
    y    = build_y(as.numeric(weekday), pos),
    yend = build_yend(as.numeric(weekday), pos),
    year = year
  ), by = c("date", "pos")]

  p <- dt_sum %>%
    ggplot2::ggplot(ggplot2::aes(week, weekday))

  if (tooltip == TRUE && requireNamespace("ggiraph", quietly = TRUE)) {
    p <- p +
      ggiraph::geom_tile_interactive(ggplot2::aes(fill = n, tooltip = tooltip), color = "white")
  } else {
    if (tooltip == TRUE) warning("`ggiraph not installed, can't use tooltip.`")
    p <- p +
      ggplot2::geom_tile(ggplot2::aes(fill = n), color = "white")
  }
  p <- p +
    ggplot2::geom_segment(data = dt_limit, ggplot2::aes(x = x, y = y, xend = xend, yend = yend), color = "white", size = 1.5) +
    ggplot2::facet_grid(year ~ .) +
    ggplot2::theme(axis.title.x = ggplot2::element_blank(), axis.text.x = ggplot2::element_blank(), axis.ticks.x = ggplot2::element_blank(), panel.background = ggplot2::element_blank()) +
    ggplot2::scale_fill_viridis_c(guide = FALSE) +
    ggplot2::labs(x = NULL, y = NULL)

  if (requireNamespace("ggiraph", quietly = TRUE) && tooltip == TRUE) {
    ggiraph::girafe(print(p))
  } else {
    p
  }

}

