tmp_dir_helper = function(tmp_dir, call = rlang::caller_env()) {

    if (is.null(tmp_dir)) tmp_dir = fs::path_temp()

    if (!fs::dir_exists(tmp_dir)) fs::dir_create(tmp_dir)

    tmp_dir
}

run_sent_trans = function(scramble_dt, tmp_dir) {

}

#' @export
stransevalr = function(input, tmp_dir = NULL) {

    cleanup = is.null(tmp_dir)
    tmp_dir = tmp_dir_helper(tmp_dir)

    res = input |>
        read_input() |>
        multi_scramble(tmp_dir = tmp_dir) |>
        run_sent_trans()

    if (cleanup) fs::dir_delete(tmp_dir)

    res
}
