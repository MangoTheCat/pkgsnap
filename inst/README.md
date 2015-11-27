


# pkgsnap

> Backup and Restore Certain CRAN Package Versions

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
#> Installing packages into '/private/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T/RtmprA6J6b/filec6446f7bd8a8'
#> (as 'lib' is unspecified)
#> also installing the dependencies 'memoise', 'digest', 'crayon', 'praise'
```

```
#> 
#> The downloaded binary packages are in
#> 	/var/folders/ws/7rmdm_cn2pd8l1c3lqyycv0c0000gn/T//RtmprA6J6b/downloaded_packages
```

```r
installed.packages(lib_dir)[, c("Package", "Version")]
```

```
#>           Package     Version 
#> crayon    "crayon"    "1.3.1" 
#> digest    "digest"    "0.6.8" 
#> memoise   "memoise"   "0.2.1" 
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
#>     Package Version
#> 1    crayon   1.3.1
#> 2    digest   0.6.8
#> 3   memoise   0.2.1
#> 4 pkgconfig   2.0.0
#> 5    praise   1.0.0
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
#>   crayon_1.3.1.tgz...  done.
#>   digest_0.6.8.tgz...  done.
#>   memoise_0.2.1.tgz...  done.
#>   pkgconfig_2.0.0.tgz...  done.
#>   praise_1.0.0.tgz...  done.
#>   testthat_0.11.0.tgz...  done.
#> Installing
#>   digest_0.6.8.tgz ... done.
#>   memoise_0.2.1.tgz ... done.
#>   crayon_1.3.1.tgz ... done.
#>   pkgconfig_2.0.0.tgz ... done.
#>   praise_1.0.0.tgz ... done.
#>   testthat_0.11.0.tgz ... done.
```

```r
installed.packages(new_lib_dir)[, c("Package", "Version")]
```

```
#>           Package     Version 
#> crayon    "crayon"    "1.3.1" 
#> digest    "digest"    "0.6.8" 
#> memoise   "memoise"   "0.2.1" 
#> pkgconfig "pkgconfig" "2.0.0" 
#> praise    "praise"    "1.0.0" 
#> testthat  "testthat"  "0.11.0"
```


## License

MIT © [Mango Solutions](https://github.com/mangothecat).
