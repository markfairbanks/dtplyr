#' Count observations by group
#'
#' This is a method for the dplyr [count()] generic. It is translated using
#' `.N` in the `j` argument, and supplying groups to `keyby` as appropriate.
#'
#' @param .data A [lazy_dt()]
#' @inheritParams dplyr::count
#' @importFrom dplyr count
#' @export
#' @examples
#' library(dplyr, warn.conflicts = FALSE)
#'
#' dt <- lazy_dt(dplyr::starwars)
#' dt %>% count(species)
#' dt %>% count(species, sort = TRUE)
#' dt %>% count(species, wt = mass, sort = TRUE)
count.dtplyr_step <- function(.data, ..., wt = NULL, sort = FALSE, name = NULL) {
  if (!missing(...)) {
    out <- group_by(.data, ..., .add = TRUE)
  } else {
    out <- .data
  }

  tally(out, wt = !!enquo(wt), sort = sort, name = name)
}

#' @export
count.data.table <- function(.data, ...) {
  .data <- lazy_dt(.data)
  count(.data, ...)
}

#' @importFrom dplyr tally
#' @export
tally.dtplyr_step <- function(.data, wt = NULL, sort = FALSE, name = NULL) {
  wt <- enquo(wt)
  if (quo_is_null(wt)) {
    n <- expr(n())
  } else {
    n <- expr(sum(!!wt, na.rm = TRUE))
  }

  if (is.null(name)) {
    name <- "n"
  } else if (!is_string(name)) {
    abort("`name` must be a string")
  }

  out <- summarise(.data, !!name := !!n)

  if (sort) {
    out <- arrange(out, desc(!!sym(name)))
  }

  out
}

#' @export
tally.data.table <- function(.data, ...) {
  .data <- lazy_dt(.data)
  tally(.data, ...)
}
