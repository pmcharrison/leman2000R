
# leman2000R

*Author: Peter Harrison*

<!-- badges: start -->
<!-- badges: end -->

This package allows you to run the tonal contextuality model of Leman (2000) on arbitrary audio files. 
The original model was published in a 2000 Music Perception paper, and was shown
to provide a psychoacoustic account of the Krumhansl-Kessler probe-tone data.
Leman and colleagues released this model a while back as part of the 
IPEM Toolbox, but this now only works on old versions of MATLAB.
The present package wraps this old implementation in Docker to ensure
easy cross-platform use into the forseeable future.


## Installation

You can install the development version of leman2000R from [GitHub](https://github.com/) with:

``` r
install.packages("remotes")
remotes::install_github("pmcharrison/leman2000R")
```

You must also install [Docker](https://docker.io/) and launch it on your computer
before using the package.

Run `?leman2000R::leman2000` in your R console to get documentation for the main function,
`leman2000`.
See `inst/example-analysis.R` for an example analysis using this model.
