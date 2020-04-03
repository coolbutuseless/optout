

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lossless compression/optimization of PNG files
#'
#' If no \code{outfile} is specified, then the input file is compressed in place.
#'
#' @inheritParams optipng
#' @param more compress more? default: FALSE
#' @param lossy_alpha remove colors behind alpha channel 0. No visual difference, removes hidden information.
#' @param lossy_8bit convert 16-bit per channel image to 8-bit per channel.
#' @param insane insane compression options. default: FALSE
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
zopflipng <- function(infile,
                      lossy_alpha = FALSE,
                      lossy_8bit  = FALSE,
                      more        = FALSE,
                      insane      = FALSE,
                      outfile     = infile,
                      verbosity   = 0) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity Check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  command <- 'zopflipng'
  check_exe(command)
  check_filename(infile)
  insane <- if (isTRUE(insane)) {
    "--iterations=500 --filters=01234mepb --lossy_8bit --lossy_transparent"
  } else {
    c()
  }

  more <- ifelse(isTRUE(more), "-m", "")

  lossy_alpha <- ifelse(isTRUE(lossy_alpha), "--lossy_transparent", "")
  lossy_8bit  <- ifelse(isTRUE(lossy_8bit ), "--lossy_8bit"       , "")

  if (verbosity > 1) {
    stdout <- ""
    stderr <- ""
  } else {
    stdout <- NULL
    stderr <- NULL
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up a temp file. Copy the input file to the temp_file and then
  # optise this tempfile in place. easist way to work with zopflipng
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  temp_file <- tempfile(fileext = ".jpg")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up optimization command and args
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  args <- c(
    "--always_zopflify",  # always output, no matter how bad the compression
    lossy_alpha,          # remove colours under alpha=0 pixels
    lossy_8bit,           # convert from 16bit to 8bit per colour
    more,                 # do more optimisation
    insane,               # do an eye-wateringly insane amount of optimisation
    "-y",                 # overwrite the output file with abandon
    shQuote(infile)   ,   # input file
    shQuote(temp_file)    # output file
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

