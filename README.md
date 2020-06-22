
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PROJ6INLA200618

<!-- badges: start -->

<!-- badges: end -->

The goal of PROJ6INLA200618 is to provide an easy workaround for a bug
affecting `INLA::inla.crs_set_lengthunit` in INLA version 20.06.18, by
overriding the relevant functions with corrected versions.

## Installation

You can install the package from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("finnlindgren/PROJ6INLA200618")
```

## Example

Use the package like this:

``` r
library(INLA)
#> Loading required package: Matrix
#> Loading required package: sp
#> Loading required package: parallel
#> Loading required package: foreach
#> This is INLA_20.06.18 built 2020-06-18 19:02:04 UTC.
#> See www.r-inla.org/contact-us for how to get help.
#> To enable PARDISO sparse library; see inla.pardiso()
library(PROJ6INLA200618)
#> 
#> Attaching package: 'PROJ6INLA200618'
#> The following objects are masked from 'package:INLA':
#> 
#>     inla.crs_get_lengthunit, inla.crs_get_wkt, inla.crs_set_lengthunit,
#>     inla.wkt_set_lengthunit
```

This will display a note about which functions are overridden.
