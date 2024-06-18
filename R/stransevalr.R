tmp_dir_helper = function(tmp_dir, call = rlang::caller_env()) {

    if (is.null(tmp_dir)) tmp_dir = fs::path_temp()

    if (!fs::dir_exists(tmp_dir)) fs::dir_create(tmp_dir)

    tmp_dir
}

run_sent_trans = function(scramble_dt, tmp_dir) {

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
        run_sent_trans(sent_trans_model) |>
        eval_cs()

    if (cleanup) fs::dir_delete(tmp_dir)

    res
}
