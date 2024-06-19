
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
question-answer-response file. This code block will create the virtual
environment for you if it doesn’t exist or set it to be used if it does:

``` r
library(reticulate)

# change the virtual environment directory as you like
env_dir = file.path(Sys.getenv("HOME"),
                    ".virtualenvs/sntenv") 

if (dir.exists(env_dir)) {
  
    use_virtualenv(env_dir)
  
} else {
  
    virtualenv_create(env_dir)
    
    virtualenv_install(env_dir, 
                       packages = c("cuda-python==12.1.0", "torch==2.2.2"),
                       pip_options = c("--upgrade", "--force-reinstall"))
    
    virtualenv_install(env_dir, 
                       packages = c("pathlib", "pandas", "transformers", "numpy", "sentence_transformers"))
}
```

The first column must be named `question`, the seconde must be `answer`,
and the remaining columns should have names indicating the model they
came from e.g. `llama_70b_rag`:

``` r
library(data.table)
library(stransevalr)

# show input file
system.file("extdata", "correct_fmt.tsv", package = "stransevalr") |> 
  fread() |>
  tibble::as_tibble()
```

    # A tibble: 10 × 4
       question                 answer Response_Azure_Bioc_…¹ Response_Azure_GPT4_…²
       <chr>                    <chr>  <chr>                  <chr>                 
     1 "I am a bit confused ab… "The … "The False Discovery … "FDR, FDR adjusted p-…
     2 "I am working on RNA-Se… "Just… "It seems like you're… "In DESeq2, adding th…
     3 "I am new in this kind … "Ther… "Yes, you're correct … "You're correct that …
     4 "I am testing salmon an… "To a… "The `tximport` funct… "1. ScaledTPM and len…
     5 "In all RNA-seq analysi… "The … "The dispersion param… "In RNA-seq analysis,…
     6 "I know findOverlaps() … "From… "Based on your questi… "It seems like you're…
     7 "I have just downloaded… "I wr… "To map the coordinat… "Mapping genomic coor…
     8 "How can I filter out t… "If y… "Yes, you are on the … "Yes, you are on the …
     9 "I am analysing my RNA-… "You … "The issue you're fac… "It seems like you ar…
    10 "How do I merge a list … "Merg… "You can merge a list… "To merge a list of G…
    # ℹ abbreviated names: ¹Response_Azure_Bioc_RAG, ²Response_Azure_GPT4_Temp0


    # show scrambling

    # show evalutating with strans

    # show computing cosine similarities

    # show plotting

    # run strans
    ## basic example code
