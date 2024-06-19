pathlib <- NULL
polars <- NULL
torch <- NULL
transformers <- NULL
cudapython <- NULL
numpy <- NULL
random <- NULL
sentence_transformers <- NULL

.onLoad = function(libname, pkgname) {
  pandas <<- reticulate::import("pandas")
  torch <<- reticulate::import("torch", delay_load = TRUE)
  sentence_transformers <<- reticulate::import("sentence_transformers", delay_load = TRUE)
}

.onAttach = function(libname, pkgname) {
  cli::cli_alert_success('stransevalr')
  cli::cli_alert_info('Set your venv with {.code reticulate::use_virtualenv(".virtualenvs/your_venv")}')
}
