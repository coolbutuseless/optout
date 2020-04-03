

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' The equivalent of running 'which prog_name' at the shell
#'
#' @param prog_name name of program to search for
#'
#' @return path to file, or NULL if not found
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
shwhich <- function(prog_name) {
  prog_name <- as.character(prog_name[1])
  prog_name <- sub("\\;", "_", prog_name)
  prog_name <- sub("\\&", "_", prog_name)
  prog_name <- sub("\\|", "_", prog_name)


  suppressWarnings({
    path <- system2("which", prog_name, stdout = TRUE, stderr = NULL)
  })

  if (length(path) == 0) {
    NULL
  } else {
    path
  }
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Check the Executable exists
#'
#' @param prog_name name of program to search for
#' @param verbosity verbosity level. default 0
#'
#' @return path
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
check_exe <- function(prog_name, verbosity = 0) {
  path <- shwhich(prog_name)

  if (is.null(path)) {
    stop("Could not find executable for: ", shQuote(prog_name), call. = FALSE)
  }

  if (verbosity > 1) {
    message("Path to ", shQuote(prog_name), ": ", path)
  }

  invisible(path)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Check that a filename is really a filename
#'
#' Lots of sanity checks to avoid mischief by the user: Must be single
#' character string with nchars > 0.  File must exist.
#'
#' This is still open to race conditions.
#'
#' @param filename single filename to check
#'
#' @return TRUE if all checks pass, otherwise throws an ERROR
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
check_filename <- function(filename) {
  stopifnot(is.character(filename), length(filename) == 1L, nchar(filename) > 0)
  stopifnot(file.exists(filename))
  invisible(TRUE)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Calculate ompression states
#'
#' @param init_size,final_size file sizes
#' @param prefix message prefix
#' @param verbosity verbosity level. integer
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
calc_compression_stats <- function(init_size, final_size, prefix, verbosity) {

  comp <- (init_size - final_size)/init_size

  if (verbosity > 0) {
    message(prefix, ": ", init_size, " -> ",
            final_size, "  Space Saving: ",
            round(comp * 100, 1), "%")
  }

  return(list(
    prefix            = prefix,
    original_size     = init_size,
    compressed_size   = final_size,
    compression       = comp,
    compression_ratio = init_size/final_size,
    space_saving      = 1 - final_size/init_size
  ))
}


