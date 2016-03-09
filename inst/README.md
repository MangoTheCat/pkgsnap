


# pkgsnap

> Backup and Restore Certain CRAN Package Versions

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Linux Build Status](https://travis-ci.org/MangoTheCat/pkgsnap.svg?branch=master)](https://travis-ci.org/MangoTheCat/pkgsnap)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/MangoTheCat/pkgsnap?svg=true)](https://ci.appveyor.com/project/gaborcsardi/pkgsnap)
[![Coverage Status](https://img.shields.io/codecov/c/github/mangothecat/pkgsnap/master.svg)](https://codecov.io/github/mangothecat/pkgsnap?branch=master)
[![](http://www.r-pkg.org/badges/version/pkgsnap)](http://www.r-pkg.org/pkg/pkgsnap)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/pkgsnap)](http://www.r-pkg.org/pkg/pkgsnap)


Create a snapshot of your installed CRAN packages with 'snap', and then
use 'restore' on another system to recreate exactly the same environment.

## Installation


```r
devtools::install_github("mangothecat/pkgsnap")
```

## Usage


```r
library(pkgsnap)
```

For this experiment we create a new library directory, and install
some packages there. We will then remove this directory entirely,
and recreate it using `pkgsnap`.


```r
lib_dir <- tempfile()
dir.create(lib_dir)
```

We make this new library directory the default:


```r
.libPaths(lib_dir)
```

The new library directory is currently empty:


```r
installed.packages(lib_dir)[, c("Package", "Version")]
```

```
#>      Package Version
```

Let's install some packages here. Note that the dependencies of these
packages will be also installed.


```r
install.packages(c("testthat", "pkgconfig"))
```

```
#> Installing packages into '/private/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T/RtmpOssfTB/file1003d2f2dd0b1'
#> (as 'lib' is unspecified)
#> also installing the dependency 'praise'
#> 
#> Package which is only available in source form, and may need
#>   compilation of C/C++/Fortran: 'testthat'
```

```
#> 
#> The downloaded binary packages are in
#> 	/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T//RtmpOssfTB/downloaded_packages
```

```
#> installing the source packages 'praise', 'testthat'
```

```r
installed.packages(lib_dir)[, c("Package", "Version")]
```

```
#>           Package     Version 
#> pkgconfig "pkgconfig" "2.0.0" 
#> praise    "praise"    "1.0.0" 
#> testthat  "testthat"  "0.11.0"
```

We will now create a snapshot, and then scrap the temporary package
library.


```r
snapshot <- tempfile()
snap(to = snapshot)
read.csv(snapshot)[1:5,]
```

```
#>         Package Version Source Link
#> 1             R   3.3.0      R   NA
#> 2     pkgconfig   2.0.0   cran   NA
#> 3        praise   1.0.0   cran   NA
#> 4      testthat  0.11.0   cran   NA
#> 5 BiocInstaller  1.21.3   bioc   NA
```

```r
unlink(lib_dir, recursive = TRUE)
```

Create a new package library.


```r
new_lib_dir <- tempfile()
dir.create(new_lib_dir)
.libPaths(new_lib_dir)
```

Finally, recreate the same set of package versions, in a new package
library.


```r
restore(snapshot)
```

```
#> Downloading
#>   pkgconfig_2.0.0.tgz...  done.
#>   praise_1.0.0.tgz...   praise_1.0.0.tgz...   praise_1.0.0.tar.gz...  done.
#>   testthat_0.11.0.tgz...   testthat_0.11.0.tgz...   testthat_0.11.0.tar.gz...  done.
#>   BiocInstaller_1.21.3.tgz...  done.
#>   covr_1.2.0.tgz...   covr_1.2.0.tgz...   covr_1.2.0.tar.gz...  done.
#>   crayon_1.3.1.tgz...  done.
#>   curl_0.9.5.tgz...   curl_0.9.5.tgz...   curl_0.9.5.tar.gz...   curl_0.9.5.tar.gz...  done.
#>   devtools_1.10.0.tgz...   devtools_1.10.0.tgz...   devtools_1.10.0.tar.gz...  done.
#>   digest_0.6.9.tgz...   digest_0.6.9.tgz...   digest_0.6.9.tar.gz...  done.
#>   git2r_0.13.1.tgz...  done.
#>   htmltools_0.3.tgz...   htmltools_0.3.tgz...   htmltools_0.3.tar.gz...  done.
#>   httr_1.1.0.tgz...   httr_1.1.0.tgz...   httr_1.1.0.tar.gz...  done.
#>   jsonlite_0.9.19.tgz...   jsonlite_0.9.19.tgz...   jsonlite_0.9.19.tar.gz...  done.
#>   lazyeval_0.1.10.tgz...   lazyeval_0.1.10.tgz...   lazyeval_0.1.10.tar.gz...  done.
#>   magrittr_1.5.tgz...   magrittr_1.5.tgz...   magrittr_1.5.tar.gz...  done.
#>   memoise_1.0.0.tgz...   memoise_1.0.0.tgz...   memoise_1.0.0.tar.gz...  done.
#>   mime_0.4.tgz...  done.
#>   openssl_0.9.1.tgz...   openssl_0.9.1.tgz...   openssl_0.9.1.tar.gz...   openssl_0.9.1.tar.gz...  done.
#>   R6_2.1.2.tgz...   R6_2.1.2.tgz...   R6_2.1.2.tar.gz...  done.
#>   rex_1.0.1.tgz...   rex_1.0.1.tgz...   rex_1.0.1.tar.gz...  done.
#>   rstudioapi_0.5.tgz...  done.
#>   simplegraph_1.0.0.tgz...   simplegraph_1.0.0.tgz...   simplegraph_1.0.0.tar.gz...  done.
#>   whisker_0.3-2.tgz...  done.
#>   withr_1.0.1.tgz...   withr_1.0.1.tgz...   withr_1.0.1.tar.gz...  done.
#> Installing
#>   pkgconfig_2.0.0.tgz ... done.
#>   praise_1.0.0.tar.gz ... done.
#>   testthat_0.11.0.tar.gz ... done.
#>   BiocInstaller_1.21.3.tgz ... done.
#>   covr_1.2.0.tar.gz ... done.
#>   crayon_1.3.1.tgz ... done.
#>   curl_0.9.5.tar.gz ... done.
#>   devtools_1.10.0.tar.gz ... done.
#>   digest_0.6.9.tar.gz ... done.
#>   git2r_0.13.1.tgz ... done.
#>   htmltools_0.3.tar.gz ... done.
#>   httr_1.1.0.tar.gz ... done.
#>   jsonlite_0.9.19.tar.gz ... done.
#>   lazyeval_0.1.10.tar.gz ... done.
#>   magrittr_1.5.tar.gz ... done.
#>   memoise_1.0.0.tar.gz ... done.
#>   mime_0.4.tgz ... done.
#>   openssl_0.9.1.tar.gz ... done.
#>   R6_2.1.2.tar.gz ... done.
#>   rex_1.0.1.tar.gz ... done.
#>   rstudioapi_0.5.tgz ... done.
#>   simplegraph_1.0.0.tar.gz ... done.
#>   whisker_0.3-2.tgz ... done.
#>   withr_1.0.1.tar.gz ... done.
```

```r
installed.packages(new_lib_dir)[, c("Package", "Version")]
```

```
#>               Package         Version 
#> BiocInstaller "BiocInstaller" "1.21.3"
#> covr          "covr"          "1.2.0" 
#> crayon        "crayon"        "1.3.1" 
#> curl          "curl"          "0.9.5" 
#> devtools      "devtools"      "1.10.0"
#> digest        "digest"        "0.6.9" 
#> git2r         "git2r"         "0.13.1"
#> htmltools     "htmltools"     "0.3"   
#> httr          "httr"          "1.1.0" 
#> jsonlite      "jsonlite"      "0.9.19"
#> lazyeval      "lazyeval"      "0.1.10"
#> magrittr      "magrittr"      "1.5"   
#> memoise       "memoise"       "1.0.0" 
#> mime          "mime"          "0.4"   
#> openssl       "openssl"       "0.9.1" 
#> pkgconfig     "pkgconfig"     "2.0.0" 
#> praise        "praise"        "1.0.0" 
#> R6            "R6"            "2.1.2" 
#> rex           "rex"           "1.0.1" 
#> rstudioapi    "rstudioapi"    "0.5"   
#> simplegraph   "simplegraph"   "1.0.0" 
#> testthat      "testthat"      "0.11.0"
#> whisker       "whisker"       "0.3-2" 
#> withr         "withr"         "1.0.1"
```


## License

MIT © [Mango Solutions](https://github.com/mangothecat).
