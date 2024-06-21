pathlib <- NULL
polars <- NULL
torch <- NULL
transformers <- NULL
cudapython <- NULL
numpy <- NULL
random <- NULL
sentence_transformers <- NULL

.onLoad = function(libname, pkgname) {
  pandas                <<- reticulate::import(               "pandas", delay_load = TRUE)
  torch                 <<- reticulate::import(                "torch", delay_load = TRUE)
  sentence_transformers <<- reticulate::import("sentence_transformers", delay_load = TRUE)
}

.onAttach = function(libname, pkgname) {
  cli::cli_alert_success('{.pkg stransevalr} loaded.')
  cli::cli_alert_info('Set your venv with {.code reticulate::use_virtualenv("~/.virtualenvs/your_venv")}')
}
