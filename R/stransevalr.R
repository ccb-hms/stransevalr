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
                          model_name) {
    
    # setwd("~/stransevalr")
    # library(reticulate)
    # use_virtualenv("~/pyenv/sntenv")
    # devtools::load_all()
    # options(datatable.print.trunc.cols = TRUE)
    # input = "~/bioc_ai/data/correct_fmt.tsv"
    # model_name = 'multi-qa-MiniLM-L6-cos-v1'
    # scramble_dt = input |>
    #     read_input() |>
    #     multi_scramble()

    dev_name = safely_check_for_gpu(0)
    
    device = torch$device("cuda")
    
    model = sentence_transformers$SentenceTransformer(model_name)
    
    scramble_pd = r_to_py(scramble_dt)
    
    questions = scramble_pd$question$tolist()
    answers   = scramble_pd$answer$tolist()
    
    grd_embed = model$encode(answers) # This is an _R_ matrix, not a python result 
    
    to_embed = colnames(scramble_dt) |> tail(-2) 
    
    emb_dt = data.table(m = to_embed,
                        res = lapply(seq_along(to_embed),
                                     \(i) model$encode(scramble_pd[[to_embed[i]]]$tolist())))
    
    emb_dt
}

cosine_sim = function(model_embeds, ans_embeds) {
    rowSums(model_embeds * ans_embeds) / (sqrt(rowSums(ans_embeds^2)) * sqrt(rowSums(model_embeds^2)))
}

eval_cos_sim = function(emb_dt) {
    
    grd_ans = emb_dt[m == "reembed_ground_truth"]$res[[1]]
    
    emb_dt[, cosine_sims := lapply(res, cosine_sim, ans_embeds = grd_ans)]
    
    emb_dt
}

#' Evaluate model responses against a "ground-truth" answer
#' @description Starting with an input set of questions, answers, and model
#' responses, use sentence transformers to compare the embedded model responses
#' against the embedded "ground-truth" answer.
#'
#' @param input an input data frame or path to tsv
#' @param sent_trans_model hugging face sentence transformer model string
#'
#' @details
#' If \code{sent_trans_model} has not been run before, it should download it from huggingface as needed.
#'
#' @export
stransevalr = function(input,
                       sent_trans_model = 'multi-qa-MiniLM-L6-cos-v1') {

    res = input                          |>
        read_input()                     |>
        multi_scramble()                 |>
        run_sent_trans(sent_trans_model) |>
        eval_cos_sim()

    res
}
