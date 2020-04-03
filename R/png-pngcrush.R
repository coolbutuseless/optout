

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lossless compression/optimization of PNG files
#'
#' If no \code{outfile} is specified, then the input file is compressed in place.
#'
#' @inheritParams optipng
#' @param brute use brute-force: try 176 different methods. Default: FALSE
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pngcrush <- function(infile,
                     brute   = FALSE,
                     outfile = infile,
                     verbosity = 0) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity Check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  command <- 'pngcrush'
  check_exe(command)
  check_filename(infile)
  brute <- ifelse(isTRUE(brute), "-brute", "")

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
    '-new',            # Use new default settings (-reduce)
    '-reduce',         # (do lossless color-type or bit-depth reduction)
    brute,             # (use brute-force: try 176 different methods
    shQuote(infile),   # infile
    shQuote(temp_file) # outfile
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

