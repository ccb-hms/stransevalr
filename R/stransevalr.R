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
    #     read_input() |>
    #     multi_scramble()
  
    force(scramble_dt)
    
    if (verbose) cli::cli_alert("Checking for GPU availability...")
  
    dev_name = safely_check_for_gpu(0)
  
    if (verbose) cli::cli_alert_success("Found GPU: {dev_name} !")
    
    device = torch$device("cuda")
    
    if (verbose) cli::cli_alert_info("Loading sentence transformer model...")
    
    model = sentence_transformers$SentenceTransformer(model_name)
    
    if (verbose) cli::cli_alert_info("Embedding answers and model responses...")
    
    scramble_pd = r_to_py(scramble_dt)
    
    questions = scramble_pd$question$tolist()
    answers   = scramble_pd$answer$tolist()
    
    grd_embed = model$encode(answers) # This is an _R_ matrix, not a python result 
    
    to_embed = colnames(scramble_dt) |> tail(-2) 
    
    emb_dt = data.table(m = to_embed,
                        emb_mat = lapply(seq_along(to_embed),
                                     \(i) model$encode(scramble_pd[[to_embed[i]]]$tolist())))
    
    emb_dt
}

cosine_sim = function(model_embeds, ans_embeds) {
    rowSums(model_embeds * ans_embeds) / (sqrt(rowSums(ans_embeds^2)) * sqrt(rowSums(model_embeds^2)))
}

eval_cos_sim = function(emb_dt, verbose) {
    
    force(emb_dt)
  
    if (verbose) cli::cli_alert_info("Computing cosine similarities...")
  
    grd_ans = emb_dt[m == "reembed_ground_truth"]$emb_mat[[1]]
    
    emb_dt[, cosine_sims := lapply(emb_mat, cosine_sim, ans_embeds = grd_ans)]
    
    emb_dt[]
}

#' Evaluate model responses against a "ground-truth" answer
#' @description Starting with an input set of questions, answers, and model
#' responses, use sentence transformers to compare the embedded model responses
#' against the embedded "ground-truth" answer.
#'
#' @param input an input data frame or path to tsv
#' @param sent_trans_model hugging face sentence transformer model string
#' @param verbose logical indicating whether to print informative messages
#'
#' @details
#' If \code{sent_trans_model} has not been run before, it should download it from huggingface as needed.
#'
#' @export
stransevalr = function(input,
                       sent_trans_model = 'multi-qa-MiniLM-L6-cos-v1', 
                       verbose = TRUE) {

    res = input                                   |>
        read_input(verbose)                       |>
        multi_scramble(verbose)                   |>
        run_sent_trans(sent_trans_model, verbose) |>
        eval_cos_sim(verbose)
    
    if (verbose) cli::cli_alert_success("Done!")

    res
}
