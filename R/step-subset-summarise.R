
#' Summarise each group to one row
#'
#' This is a method for the dplyr [summarise()] generic. It is translated to
#' the `j` argument of `[.data.table`.
#'
#' @param .data A [lazy_dt()].
#' @inheritParams dplyr::summarise
#' @importFrom dplyr summarise
#' @export
#' @examples
#' library(dplyr, warn.conflicts = FALSE)
#'
#' dt <- lazy_dt(mtcars)
#'
#' dt %>%
#'   group_by(cyl) %>%
#'   summarise(vs = mean(vs))
#'
#' dt %>%
#'   group_by(cyl) %>%
#'   summarise(across(disp:wt, mean))
summarise.dtplyr_step <- function(.data, ...) {
  dots <- capture_dots(.data, ...)
  check_summarise_vars(dots)

  if (length(dots) == 0) {
    if (length(.data$groups) == 0) {
      out <- step_subset_j(.data, vars = character(), j = 0L)
    } else {
      # Acts like distinct on grouping vars
      out <- distinct(.data, !!!syms(.data$groups))
    }
  } else {
    out <- step_subset_j(
      .data,
      vars = union(.data$groups, names(dots)),
      j = call2(".", !!!dots)
    )
  }

  step_group(out, groups = head(.data$groups, -1))
}

#' @export
summarise.data.table <- function(.data, ...) {
  .data <- lazy_dt(.data)
  summarise(.data, ...)
}


# For each expression, check if it uses any newly created variables
check_summarise_vars <- function(dots) {
  for (i in seq_along(dots)) {
    used_vars <- all_names(get_expr(dots[[i]]))
    cur_vars <- names(dots)[seq_len(i - 1)]

    if (any(used_vars %in% cur_vars)) {
      abort(paste0(
        "`", names(dots)[[i]], "` ",
        "refers to a variable created earlier in this summarise().\n",
        "Do you need an extra mutate() step?"
      ))
    }
  }
}
