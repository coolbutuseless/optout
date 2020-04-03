

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lossless and Lossy compression of JPEG files
#'
#' If no \code{outfile} is specified, then the input file is compressed in place.
#'
#' If both \code{quality} and \code{size} options are left at their default of
#' \code{NULL}, then lossless optimization is performed.
#'
#' @inheritParams optipng
#' @param quality set maximum image quality factor. Valid quality values: 0 - 100.
#'        Default: NULL (not enabled)
#' @param size Try to optimize file to given size. Target size is specified
#'        either in kilo bytes (1 - n) or as percentage (1\% - 99\%)
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
jpegoptim <- function(infile,
                      quality = NULL,
                      size    = NULL,
                      outfile = infile,
                      verbosity = 0) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity check. And sanitize the 'size' argument
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  command <- 'jpegoptim'
  check_exe(command)
  check_filename(infile)

  if (is.numeric(size)) {
    size <- as.integer(size[1])
  } else if (is.character(size)) {
    size <- size[1]
    stopifnot(endsWith(size, "%"))
    value <- substr(size, 1, nchar(size) - 1)
    value <- as.integer(value)
    size  <- paste0(value, "%")
    cat("New size: ", size, "\n")
  }




  args <- c('')
  if (!is.null(quality)) {
    quality <- as.integer(quality[1])
    stopifnot(!is.na(quality))
    args <- c(args, c("-m", quality))
  } else if (!is.null(size)) {
    args <- c(args, c("-S", size))
  }

  if (verbosity > 1) {
    stdout <- ""
    stderr <- ""
  } else {
    stdout <- NULL
    stderr <- NULL
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up a temp file.
  # Because 'jpegoptim' heavily assumes that it is working "in-place", it is
  # easiest if we copy the 'infile' to the tempfile and then optimise the tempfile.
  # This is especially important when jpegoptim cannot optimise a file - if
  # this is the case then it will not write any output when using the "-d"
  # option to try and put files in another directory
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  temp_file <- tempfile(fileext = ".jpg")
  file.copy(infile, temp_file)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up optimization command and args
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  args <- c(
    args,
    "-f",              # Always attempt optimisation
    shQuote(temp_file) # Input file. Overwritten in place
  )

  args <- args[args != '']
  if (verbosity > 1) {
    cat("cp", shQuote(infile), shQuote(temp_file), "\n")
    cat(command, paste(args, collapse = " "), "\n")
    cat("mv", shQuote(temp_file), shQuote(outfile), "\n")
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Run the command and move the output appropriately
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  init_size <- file.size(infile)
  system2(command, args, stdout = stdout, stderr = stderr)
  file.rename(temp_file, outfile)

  comp <- calc_compression_stats(init_size, file.size(outfile), command, verbosity = verbosity)

  if (verbosity > 1) {
    comp
  } else {
    invisible(comp)
  }
}

