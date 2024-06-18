pathlib <- NULL
polars <- NULL
torch <- NULL
transformers <- NULL
cudapython <- NULL
numpy <- NULL
random <- NULL
sentence_transformers <- NULL

.onLoad = function(libname, pkgname) {
    pathlib <<- reticulate::import("pathlib", delay_load = TRUE)
    polars <<- reticulate::import("polars", delay_load = TRUE)
    torch <<- reticulate::import("torch", delay_load = TRUE)
    transformers <<- reticulate::import("transformers", delay_load = TRUE)
    cudapython <<- reticulate::import('cuda-python', delay_load = TRUE)
    numpy <<- reticulate::import("numpy", delay_load = TRUE)
    random <<- reticulate::import("random", delay_load = TRUE)
    sentence_transformers <<- reticulate::import("sentence_transformers", delay_load = TRUE)
}

.onAttach = function(libname, pkgname) {
    cli::cli_alert_success('stransevalr')
}
