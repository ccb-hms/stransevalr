
<!-- README.md is generated from README.Rmd. Please edit that file -->

# stransevalr

<!-- badges: start -->
<!-- badges: end -->

The goal of stransevalr is to use `reticulate` to evaluate
question-answer pairs with sentence transformers in R.

## Installation

You can install the development version of stransevalr from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("ccb-hms/stransevalr")
```

## Example

This is a basic example which shows you how to create the virtual
environment with reticulate if needed, then analyze an input
question-answer-response file. The first column must be named
`question`, the seconde must be `answer`, and the remaining columns
should have names indicating the model they came from
e.g. `llama_70b_rag`:

``` r
library(reticulate)
library(stransevalr)

# change the virtual environment directory as you like
env_dir = file.path(Sys.getenv("HOME"),
                    ".virtualenvs/sntenv") 

if (dir.exists(env_dir)) {
    use_virtualenv(env_dir)
} else {
    
    # create a new environment 
    virtualenv_create(env_dir)
    
    virtualenv_install(env_dir, 
                       packages = c("cuda-python==12.1.0", "torch==2.2.2"),
                       pip_options = c("--upgrade", "--force-reinstall"))
    
    virtualenv_install(env_dir, 
                       packages = c("pathlib", "polars", "transformers", "numpy", "sentence_transformers"))
}

# show input file

# show scrambling

# show evalutating with strans

# show computing cosine similarities

# show plotting

# run strans
## basic example code
```
