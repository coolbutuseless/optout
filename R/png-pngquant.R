

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lossless compression/optimization of PNG files
#'
#' If no \code{outfile} is specified, then the input file is compressed in place.
#'
#' @inheritParams optipng
#' @param speed speed/quality trade-off. 1=slow, 4=default, 11=fast & rough. Default: 4
#' @param dither logical. Use dithering? Default: FALSE
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pngquant <- function(infile,
                     speed     = 4,
                     dither    = FALSE,
                     outfile   = infile,
                     verbosity = 0) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity Check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  command <- 'pngquant'
  check_exe(command)
  check_filename(infile)
  nofs  <- ifelse(isTRUE(dither), "", "--nofs")
  speed <- as.integer(speed[1])

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
    '--speed', speed,               # Optimisation setting. 1 = slow.
    "-f",                           # Overwrite existing output files
    "--strip",                      # Remove optional metadata
    nofs,                           # Use dithering?
    '--output', shQuote(temp_file), # Output file
    shQuote(infile)                 # Input file
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

