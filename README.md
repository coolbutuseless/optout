
<!-- README.md is generated from README.Rmd. Please edit that file -->

# optout - Optimized Graphics Output

<!-- badges: start -->

![](http://img.shields.io/badge/cool-useless-green.svg)
<!-- badges: end -->

This package enables access to some common command-line image
optimization and compression tools from within R, with a mostly
consistent call interface.

Tools are included for interfacing command line tools for compressing
JPG, PNG and PDF files.

**My use case** - the vignettes for
[ggpattern](https:/github.com/coolbutuseless/ggpattern) are huge because
of the image example, and I wanted to be able to optimize and compress
images from within the vignette *Rmd* files.

## Security Warning

This package does a lot of `system2()` calls with user input. I’ve
sanitised all user input, but nothing is ever perfect, so in general
this library should not accept input from the internet e.g. as part of a
shiny app.

## Installation

You can install the development version from
[GitHub](https://github.com/coolbutuseless/optout) with:

``` r
# install.packages("remotes")
remotes::install_github("coolbutuseless/optout")
```

This package relies on your system having installed the following
command line programs. If a particular utility is not installed, the
package will still load fine, but you will not be able to use that
particular compression type.

  - PNG compression
      - [pngquant](https://pngquant.org/)
      - [optpng](http://optipng.sourceforge.net/)
      - [pngcrush](https://pmt.sourceforge.io/pngcrush/)
      - [zopfli + zopflipng](https://github.com/google/zopfli)
  - JPEG compression
      - [jpegoptim](https://github.com/tjko/jpegoptim)
  - PDF compression
      - [ghostscript](https://www.ghostscript.com/)

## Overview of available compressors

| filetype | compressor | lossless | default options                                                         |
| -------- | ---------- | -------- | ----------------------------------------------------------------------- |
| png      | pngquant   | no       | speed = 4, dither = FALSE                                               |
| png      | pngcrush   | yes      | brute = FALSE                                                           |
| png      | optipng    | yes      | level = 1                                                               |
| png      | zopflipng  | yes      | lossy\_alpha = FALSE, lossy\_8bit = FALSE, more = FALSE, insane = FALSE |
| jpeg     | jpegoptim  | optional | quality = NULL, size = NULL (i.e. lossless)                             |
| pdf      | pdfopt     | no       | quality = ‘screen’                                                      |

## Sample Plot

``` r
ggplot(mtcars) + 
  geom_density(aes(mpg, fill = as.factor(cyl))) + 
  theme_gray(15)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

``` r
dpi <- 72
ggsave("man/figures/png-orig.png", p, width = 6, height = 4)
ggsave("man/figures/jpg-orig.jpg", p, width = 6, height = 4)
ggsave("man/figures/pdf-orig.pdf", p, width = 6, height = 4)
```

## Example: Optimizing PNG output

``` r
r1 <- pngquant (infile = "man/figures/png-orig.png", outfile = "man/figures/png-pngquant.png" , verbosity = 1)
#> pngquant: 146162 -> 50128  Space Saving: 65.7%
r2 <- pngcrush (infile = "man/figures/png-orig.png", outfile = "man/figures/png-pngcrush.png" , verbosity = 1)
#> pngcrush: 146162 -> 100636  Space Saving: 31.1%
r3 <- optipng  (infile = "man/figures/png-orig.png", outfile = "man/figures/png-optipng.png"  , verbosity = 1)
#> optipng: 146162 -> 98556  Space Saving: 32.6%
r4 <- zopflipng(infile = "man/figures/png-orig.png", outfile = "man/figures/png-zopflipng.png", verbosity = 1)
#> zopflipng: 146162 -> 82725  Space Saving: 43.4%
```

<div>

<div style="width:45%; float:left;">

<h4>

Orig PNG

</h4>

<img  width="100%" src="man/figures/png-orig.png"      />

</div>

</div>

<div style="clear:both;">

<div style="width:45%; float:left;">

<h4>

pngquant - space saving 66%

</h4>

<img  width="100%" src="man/figures/png-pngquant.png"  />

</div>

<div style="width:45%; float:left;">

<h4>

pngcrush - space saving 31%

</h4>

<img  width="100%" src="man/figures/png-pngcrush.png"  />

</div>

<div style="width:45%; float:left;">

<h4>

optipng - space saving 33%

</h4>

<img  width="100%" src="man/figures/png-optipng.png"   />

</div>

<div style="width:45%; float:left;">

<h4>

zopflipng - space saving 43%

</h4>

<img  width="100%" src="man/figures/png-zopflipng.png" />

</div>

</div>

<div style="clear:both;" />



## Example: Optimizing JPEG output

``` r
r5 <- jpegoptim(
  infile    = "man/figures/jpg-orig.jpg", 
  outfile   = "man/figures/jpg-jpegoptim-lossless.jpg" , 
  verbosity = 1
)
#> jpegoptim: 154167 -> 126307  Space Saving: 18.1%


r6 <- jpegoptim(
  infile    = "man/figures/jpg-orig.jpg", 
  outfile   = "man/figures/jpg-jpegoptim-lossy-size.jpg",
  size      = 50,  
  verbosity = 1
)
#> jpegoptim: 154167 -> 52125  Space Saving: 66.2%


r7 <- jpegoptim(
  infile    = "man/figures/jpg-orig.jpg", 
  outfile   = "man/figures/jpg-jpegoptim-lossy-quality.jpg", 
  quality   = 10,
  verbosity = 1
)
#> jpegoptim: 154167 -> 35333  Space Saving: 77.1%
```

<div>

<div style="width:45%; float:left;">

<h4>

Orig JPG

</h4>

<span>.</span> <img  width="100%" src="man/figures/jpg-orig.jpg"      />

</div>

<div style="width:45%; float:left;">

<h4>

jpegoptim - lossless

</h4>

Space saving 18%
<img  width="100%" src="man/figures/jpg-jpegoptim-lossless.jpg"      />

</div>

<div style="width:45%; float:left;">

<h4>

jpegoptim - target size 50kB

</h4>

Space saving 66%
<img  width="100%" src="man/figures/jpg-jpegoptim-lossy-size.jpg"      />

</div>

<div style="width:45%; float:left;">

<h4>

jpegoptim - target quality 10

</h4>

Space saving 77%
<img  width="100%" src="man/figures/jpg-jpegoptim-lossy-quality.jpg"      />

</div>

</div>

<div style="clear:both;" />


## Example: Optimizing PDF output

``` r
r8 <- pdfopt(infile = "man/figures/pdf-orig.pdf", outfile = "man/figures/pdf-pdfopt.pdf", verbosity = 1)
#> pdfopt: 13896 -> 9243  Space Saving: 33.5%
```

<div>

<div style="width:45%; float:left;">

<h4>

Orig PDF

</h4>

<span>.</span> <img  width="100%" src="man/figures/pdf-orig.png"      />

</div>

<div style="width:45%; float:left;">

<h4>

pdfopt

</h4>

Space saving 33% <img  width="100%" src="man/figures/pdf-pdfopt.png"  />

</div>

</div>

<div style="clear:both;" />


## Speed

Most optimizers run in reasonable time i.e. \~1 second for a single
file.

`zopflipng` is the exception and with higher compression options you
will see the heat death of the universe before you will see it finish.
Even at its lowest settings (the default) it will take tens-of-seconds
up to several minutes to compress a file. **Use with caution\!**
