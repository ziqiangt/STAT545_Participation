STAT 547 Class Meeting 01: Writing your own Functions
================
ziqiangt
2018/10/23

-   [Syntax Demo](#syntax-demo)
-   [Motivating example: max minus min.](#motivating-example-max-minus-min.)
-   [Testing](#testing)
-   [Try and break your function](#try-and-break-your-function)
-   [Naming, and generalizing to quantile difference](#naming-and-generalizing-to-quantile-difference)
-   [Defaults](#defaults)
-   [NA handling](#na-handling)
-   [Ellipses](#ellipses)

``` r
library(gapminder)
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.2.1 ──

    ## ✔ ggplot2 3.0.0     ✔ purrr   0.2.5
    ## ✔ tibble  1.4.2     ✔ dplyr   0.7.6
    ## ✔ tidyr   0.8.1     ✔ stringr 1.3.1
    ## ✔ readr   1.1.1     ✔ forcats 0.3.0

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(testthat)
```

    ## 
    ## Attaching package: 'testthat'

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     matches

    ## The following object is masked from 'package:purrr':
    ## 
    ##     is_null

This worksheet is a condensed version of Jenny's stat545.com functions [part1](http://stat545.com/block011_write-your-own-function-01.html), [part2](http://stat545.com/block011_write-your-own-function-02.html), and [part3](http://stat545.com/block011_write-your-own-function-03.html).

Syntax Demo
-----------

Let's demo the syntax of function-making.

``` r
square <- function(x) {
  y <- x^2
  return(y)
}
square(10)
```

    ## [1] 100

Motivating example: max minus min.
----------------------------------

Find the max minus min of the gapminder life expectancy:

``` r
?min
?max
max(gapminder$lifeExp) - min(gapminder$lifeExp)
```

    ## [1] 59.004

Exercise: turn this into a function! i.e., write a function that returns the max minus min of a vector. Try it out on the gapminder variables.

``` r
max_minus_min <- function(x) {
  max(x) - min(x)
}
max_minus_min(c(1,2,3,4))
```

    ## [1] 3

We'll be building on this. Development philosophy [widely attributed to the Spotify development team](http://blog.fastmonkeys.com/?utm_content=bufferc2d6e&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer):

![](http://stat545.com/img/spotify-howtobuildmvp.gif)

Testing
-------

Check your function using your own eyeballs:

-   Apply to the vector 1:10. Do you get the intended result?
-   Apply to a random uniform vector. Do you get meaningful results?

``` r
max_minus_min(1:10)
```

    ## [1] 9

``` r
max_minus_min(runif(100))
```

    ## [1] 0.9814803

Let's formalize this testing with the `testthat` package. `expect_*()` functions:

``` r
expect_equal(0.1 + 0.2, 0.3)
#expect_identical(0.1 + 0.2, 0.3)
```

Add another check to the following unit test, based on the uniform random numbers:

``` r
test_that("Simple cases work", {
    expect_equal(max_minus_min(1:10), 9)
    expect_lt(max_minus_min(runif(100)),1)
})
```

Try and break your function
---------------------------

Because you will eventually forget the function specifics.

``` r
max_minus_min(numeric(0))
```

    ## Warning in max(x): no non-missing arguments to max; returning -Inf

    ## Warning in min(x): no non-missing arguments to min; returning Inf

    ## [1] -Inf

``` r
#max_minus_min(gapminder)  ##error
#max_minus_min(gapminder$country) ##error
```

These don't break!

``` r
max_minus_min(gapminder[c('lifeExp', 'gdpPercap', 'pop')])
```

    ## [1] 1318683072

``` r
max_minus_min(c(TRUE, TRUE, FALSE, TRUE, TRUE))
```

    ## [1] 1

We want:

1.  Prevent the latter cases from happening, and
2.  Make a more informative error message in the former.

Check out `stopifnot` and `stop`:

``` r
#stopifnot(FALSE)
#stop("Here's my little error message.")
```

Your turn: Use two methods:

1.  Using `stopifnot`, modify the max-min function to throw an error if an input is not numeric (the `is.numeric` function is useful).

``` r
mmm1 <- function(x) {
    stopifnot(!is.numeric(x))
    max(x) - min(x)
}
#mmm1("hellow")
```

1.  Using `stop` and an `if` statement, Modify the max-min function to:
    -   throw an error if an input is not numeric. In the error message, indicate what's expected as an argument, and what was recieved.
    -   return `NULL` if the input is length-0, with a warning using the `warning` function.

``` r
mmm2 <- function(x) {
    if (!is.numeric(x)) {
        stop(paste("Error input is not numeric"))
    }
    max(x) - min(x)
}
```

Try breaking the function now:

``` r
#mmm1((numeric(0)))
#mmm1(gapminder)
#mmm1(gapminder$country)
mmm1(gapminder[c('lifeExp', 'gdpPercap', 'pop')])
```

    ## [1] 1318683072

``` r
mmm1(c(TRUE, TRUE, FALSE, TRUE, TRUE))
```

    ## [1] 1

``` r
#mm2((numeric(0)))
#mmm2(gapminder)
#mmm2(gapminder$country)
#mmm2(gapminder[c('lifeExp', 'gdpPercap', 'pop')])
#mmm2(c(TRUE, TRUE, FALSE, TRUE, TRUE))
```

Naming, and generalizing to quantile difference
-----------------------------------------------

Let's generalize the function to take the difference in two quantiles:

``` r
qd <- function(x, probs, na.rm = TRUE) {
    stopifnot(is.numeric(x))
    if (length(x) == 0) {
        warning("You inputted a length-0 x. Expecting length >=1. Returning NULL.")
        return(NULL)
    } 
    qvec <- quantile(x, probs, na.rm = na.rm)
    max(qvec) - min(qvec)
}
```

Try it out:

``` r
x <- runif(100)
qd(x, c(0.25, 0.75))
```

    ## [1] 0.3885803

``` r
IQR(x)
```

    ## [1] 0.3885803

``` r
qd(x, c(0,1))
```

    ## [1] 0.9921322

``` r
mmm2(x)
```

    ## [1] 0.9921322

Why did I call the arguments `x` and `probs`? Check out `?quantile`.

If we input a vector stored in some variable, need that variable be named `x`?

Defaults
--------

Would be nice to have defaults for `probs`, right? Add them to the below code (which is copied and pasted from above):

``` r
qd2 <- function(x, probs = c(0,1), na.rm=TRUE) {
    stopifnot(is.numeric(x))
    if (length(x) == 0) {
        warning("You inputted a length-0 x. Expecting length >=1. Returning NULL.")
        return(NULL)
    } 
    qvec <- quantile(x, probs, na.rm=na.rm)
    max(qvec) - min(qvec)
}
qd2(rnorm(100), probs = c(0.25,0.75))
```

    ## [1] 1.189416

NA handling
-----------

Does this return what we were expecting?

``` r
v <- c(1:10, NA)
# qd(v)
```

Notice that `quantile()` has a `na.rm` option. Let's use it in our `qd` function. Modify the code below:

``` r
qd2 <- function(x, probs=c(0,1)) {
    stopifnot(is.numeric(x))
    if (length(x) == 0) {
        warning("You inputted a length-0 x. Expecting length >=1. Returning NULL.")
        return(NULL)
    } 
    qvec <- quantile(x, probs)
    max(qvec) - min(qvec)
}
```

Ellipses
--------

There are other arguments to `quantile`, like `type`, that are not used all that much. Put them in as ellipses:

``` r
qd2 <- function(x, probs=c(0,1), na.rm=FALSE,  ...) {
    stopifnot(is.numeric(x))
    if (length(x) == 0) {
        warning("You inputted a length-0 x. Expecting length >=1. Returning NULL.")
        return(NULL)
    } 
    qvec <- quantile(x, probs, na.rm = na.rm, ...)
    max(qvec) - min(qvec)
}

v <- rnorm(100)
qd2(v,probs = c(0,1), na.rm=TRUE, type = 1)
```

    ## [1] 5.253735
