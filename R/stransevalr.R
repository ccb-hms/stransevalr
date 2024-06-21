safely_check_for_gpu = function(x, call = rlang::caller_env()) {
  check_res = tryCatch({
    torch$cuda$get_device_name(0)
  }, error = function(e) {
    -1L
  })
  
  if (check_res == -1) cli::cli_abort("Couldn't find a GPU, aborting. Python error: {py_last_error()}", call = call)
  
  check_res
}

# gsub_V_d = function(x) {
#     setnames(x,
#              new = gsub("V", "d", colnames(x)))
# }

run_sent_trans = function(scramble_dt, 
                          model_name, 
                          verbose) {
    
    # setwd("~/stransevalr")
    # library(reticulate)
    # use_virtualenv("~/pyenv/sntenv/")
    # devtools::load_all()
    # options(datatable.print.trunc.cols = TRUE)
    # input = "~/bioc_ai/data/correct_fmt.tsv"
    # model_name = 'multi-qa-MiniLM-L6-cos-v1'
    # scramble_dt = input |>
    #     read_input(verbose = TRUE) |>
    #     multi_scramble(verbose = TRUE)
    # sent_trans_model = 'multi-qa-MiniLM-L6-cos-v1'
    #  emb_dt = scramble_dt |> run_sent_trans(sent_trans_model, verbose = TRUE)
    # sim_fun = NULL

  
    force(scramble_dt)
    
    if (verbose) cli::cli_alert_info("Checking for GPU availability...")
  
    dev_name = safely_check_for_gpu(0)
  
    if (verbose) cli::cli_alert_success("Found GPU: {dev_name} !")
    
    device = torch$device("cuda")
    
    if (verbose) cli::cli_alert_info("Loading sentence transformer model...")
    
    model = sentence_transformers$SentenceTransformer(model_name)
    
    if (verbose) cli::cli_alert_info("Embedding answers and model responses...")
    
    scramble_pd = r_to_py(scramble_dt)
    
    questions = scramble_pd$question$tolist()
    answers   = scramble_pd$answer$tolist()
    
    #grd_embed = model$encode(answers) # This is an _R_ matrix, not a python result 
    
    to_embed = colnames(scramble_dt) |> tail(-2) 
    
    emb_dt = data.table(m = to_embed,
                        emb_mat = lapply(seq_along(to_embed),
                                     \(i) model$encode(scramble_pd[[to_embed[i]]]$tolist())))
    
    emb_dt
}

cosine_sim = function(model_embeds, ans_embeds) {
    rowSums(model_embeds * ans_embeds) / (sqrt(rowSums(ans_embeds^2)) * sqrt(rowSums(model_embeds^2)))
}

apply_user_sim = function(model_embeds, ans_embeds, sim_fun) {
  model_t = t(model_embeds)
  ans_t = t(ans_embeds)
  
  res = vector(mode = "numeric", length = nrow(model_embeds))
  
  for (i in seq_along(res)){
    res[i] = sim_fun(model_t[,i], ans_t[,i])
  }
  
  res
}

eval_sim = function(emb_dt, sim_fun, verbose) {
    
    force(emb_dt)
  
    if (verbose) cli::cli_alert_info("Computing similarities...")
  
    grd_ans = emb_dt[m == "reembed_ground_truth"]$emb_mat[[1]]
    
    if (is.null(sim_fun)) {
      cli::cli_alert("No user-specified similarity function provided, defaulting to cosine similarity.")
      emb_dt[, sims := lapply(emb_mat, cosine_sim, ans_embeds = grd_ans)]
    } else {
      cli::cli_alert("Applying user-specified similarity function to sentence transformer embeddings.")
      emb_dt[, sims := lapply(emb_mat, apply_user_sim, ans_embeds = grd_ans, sim_fun = sim_fun)]
    }
    
    emb_dt[]
}

#' Evaluate model responses against a "ground-truth" answer
#' @description Starting with an input set of questions, answers, and model
#'   responses, use sentence transformers to compare the embedded model
#'   responses against the embedded "ground-truth" answer.
#'
#' @param input an input data frame or path to tsv
#' @param sent_trans_model hugging face sentence transformer model string
#' @param sim_fun an R function used to compute embedding similarity. If left at
#'   NULL, defaults to cosine similarity.
#' @param verbose logical indicating whether to print informative messages
#'
#' @details If \code{sent_trans_model} has not been run before, it will download
#' it from huggingface as needed.
#'
#' @returns a data.table with the following columns:
#' * m: the source model of the response (i.e. columns 3 and on in the input)
#' * emb_mat: a nested list of the matrix embeddings of questions for the model
#' * sims: a nested list of vectors of similarities using the designated similarity function.
#' @export
stransevalr = function(input,
                       sent_trans_model = 'multi-qa-MiniLM-L6-cos-v1', 
                       sim_fun = NULL,
                       verbose = TRUE) {

    res = input                                   |>
        read_input(verbose)                       |>
        multi_scramble(verbose)                   |>
        run_sent_trans(sent_trans_model, verbose) |>
        eval_sim(sim_fun, verbose)
    
    if (verbose) cli::cli_alert_success("Done!")

    res
}
