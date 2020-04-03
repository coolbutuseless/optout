

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Lossy compression of PDF files
#'
#' If no \code{outfile} is specified, then the input file is compressed in place.
#'
#' \code{gs} options taken from \url{http://www.alfredklomp.com/programming/shrinkpdf/}
#'
#'
#' @inheritParams optipng
#' @param quality character. One of \code{c('screen', 'ebook', 'prepress', 'printer', 'default')}
#'        default: 'screen'
#' @param dpi Embedded image resolution. Default: 72
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pdfopt <- function(infile,
                   quality   = c('screen', 'ebook', 'prepress', 'printer', 'default'),
                   dpi       = 72,
                   outfile   = infile,
                   verbosity = 0) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Sanity Check
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  command <- 'gs'
  check_exe(command)
  check_filename(infile)
  quality <- match.arg(quality)
  dpi     <- as.integer(dpi[1])

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
  temp_file <- tempfile(fileext = ".pdf")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Set up optimization command and args
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  args <- c(
    "-q",
    "-sDEVICE=pdfwrite",
    "-dCompatibilityLevel=1.4",
    paste0("-dPDFSETTINGS=/", quality),
    "-dNOPAUSE",
    "-dQUIET",
    "-dBATCH",
    "-dEmbedAllFonts=true",
    "-dSubsetFonts=true",
    "-dAutoRotatePages=/None",
    "-dColorImageDownsampleType=/Bicubic",
    "-dGrayImageDownsampleType=/Bicubic",
    "-dMonoImageDownsampleType=/Subsample",
    paste0("-dGrayImageResolution=" , dpi),
    paste0("-dColorImageResolution=", dpi),
    paste0("-dMonoImageResolution=" , dpi),
    "-dSAFER",
    paste0("-sOutputFile=", shQuote(temp_file)),
    shQuote(infile)
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

  comp <- calc_compression_stats(init_size, file.size(outfile), "pdfopt", verbosity = verbosity)

  if (verbosity > 1) {
    comp
  } else {
    invisible(comp)
  }
}

