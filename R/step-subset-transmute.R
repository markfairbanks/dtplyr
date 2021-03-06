#' Create new columns, dropping old
#'
#' This is a method for the dplyr [transmute()] generic. It is translated to
#' the `j` argument of `[.data.table`.
#'
#' @param .data A [lazy_dt()].
#' @inheritParams mutate.dtplyr_step
#' @importFrom dplyr transmute
#' @export
#' @examples
#' library(dplyr, warn.conflicts = FALSE)
#'
#' dt <- lazy_dt(dplyr::starwars)
#' dt %>% transmute(name, sh = paste0(species, "/", homeworld))
transmute.dtplyr_step <- function(.data, ...) {
  dots <- capture_dots(.data, ...)
  nested <- nested_vars(.data, dots, .data$vars)

  if (!nested) {
    j <- call2(".", !!!dots)
  } else {
    assign <- Map(function(x, y) call2("<-", x, y), syms(names(dots)), dots)
    output <- call2(".", !!!syms(set_names(names(dots))))
    j <- call2("{", !!!assign, output)
  }
  step_subset_j(.data, vars = names(dots), j = j)
}

#' @export
transmute.data.table <- function(.data, ...) {
  .data <- lazy_dt(.data)
  transmute(.data, ...)
}
