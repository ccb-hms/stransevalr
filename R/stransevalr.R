tmp_dir_helper = function(tmp_dir, call = rlang::caller_env()) {

    if (is.null(tmp_dir)) tmp_dir = fs::path_temp()

    if (!fs::dir_exists(tmp_dir)) fs::dir_create(tmp_dir)

    tmp_dir
}

safely_check_for_gpu = function(x, call = rlang::caller_env()) {
  check_res = tryCatch({
    torch$cuda$get_device_name(0)
  }, error = function(e) {
    -1L
  })
  
  if (check_res == -1) cli::cli_abort("Couldn't find a GPU, aborting. Python error: {py_last_error()}", call = call)
  
  check_res
}

run_sent_trans = function(scramble_dt, model_name, tmp_dir) {
    # use_virtualenv("~/pyenv/sntenv")
    # devtools::load_all()
    # options(datatable.print.trunc.cols = TRUE)
    # tmp_dir = NULL
    # 
    # cleanup = is.null(tmp_dir)
    # 
    # tmp_dir = tmp_dir_helper(tmp_dir)
    # input = "~/bioc_ai/data/correct_fmt.tsv"
    # model_name = 'multi-qa-MiniLM-L6-cos-v1'
    # scramble_dt = input |>
    #     read_input() |>
    #     multi_scramble(tmp_dir = tmp_dir)

    dev_name = safely_check_for_gpu(0)
    
    device = torch$device("cuda")
    
    model = sentence_transformers$SentenceTransformer(model_name)
    
    scramble_pd = r_to_py(scramble_dt)
    
    questions = scramble_pd$question$tolist()
    answers   = scramble_pd$answer$tolist()
    
    grd_embed = model$encode(answers) # This is an _R_ matrix, not a python result 
    # TODO: write this out
    
    to_embed = colnames(scramble_dt) |> tail(-2) # TODO: write this out
    
    emb_dt = data.table(i = seq_along(to_embed),
                        m = to_embed,
                        res = lapply(seq_along(to_embed),
                                     \(i) data.table(model$encode(scramble_pd[[to_embed[i]]]$tolist()))))
    
    emb_dt[,rbindlist(res), by = .(i,m)]


}

#' Evaluate model responses against a "ground-truth" answer
#' @description Starting with an input set of questions, answers, and model
#' responses, use sentence transformers to compare the embedded model responses
#' against the embedded "ground-truth" answer.
#'
#' @param input an input data frame or path to tsv
#' @param sent_trans_model hugging face sentence transformer model string
#' @param tmp_dir path to directory for intermediate results
#'
#' @details
#' If \code{tmp_dir} is not NULL, the intermediate files will be retained at the specified directory.
#'
#' @export
stransevalr = function(input,
                       sent_trans_model = 'multi-qa-MiniLM-L6-cos-v1',
                       tmp_dir = NULL) {

    cleanup = is.null(tmp_dir)
    tmp_dir = tmp_dir_helper(tmp_dir)

    res = input |>
        read_input() |>
        multi_scramble(tmp_dir = tmp_dir) |>
        run_sent_trans(sent_trans_model, tmp_dir) |>
        eval_cs()

    if (cleanup) fs::dir_delete(tmp_dir)

    res
}
