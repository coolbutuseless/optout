

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lossless compression/optimization of PNG files
#'
#' If no \code{outfile} is specified, then the input file is compressed in place.
#'
#' @param infile PNG file to optimise
#' @param outfile output PNG location. If not specified, input file will be
#'        overwritten
#' @param level Compression level. Valid values 0-7. Default 1.
#' @param verbosity verbosity level. Possible values: 0, 1, 2. Default: 0
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
optipng <- function(infile,
                    level = 1,
                    outfile = infile,
                    verbosity = 0) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity Check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  command <- 'optipng'
  check_exe(command)
  check_filename(infile)
  level <- as.integer(level[1])

  if (verbosity > 1) {
    stdout <- ""
    stderr <- ""
  } else {
    stdout <- NULL
    stderr <- NULL
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up a temp file
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  temp_file <- tempfile(fileext = ".png")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up optimization command and args
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  args <- c(
    '-out', shQuote(temp_file),   # Write to a file
    "-force",                     # Always write, even if it's larger
    '-o', level,                  # Optimisation level [0-7] => [fast - slow]
    "-clobber",                   # Overwrite output
    shQuote(infile)               # input file
  )

  args <- args[args != '']
  if (verbosity > 1) {
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

