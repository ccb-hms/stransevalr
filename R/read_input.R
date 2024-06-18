read_type_helper = function(input, call = rlang::caller_env()) {
    is_df_or_tsv = is(input, "data.frame") ||
        (is(input, "character") && fs::file_exists(input) && tools::file_ext(input) == "tsv")

    if (!is_df_or_tsv) cli::cli_abort("{.var input} must be a data.frame or path to a tsv, you supplied a {.cls {class(input)}}",
                                      call = call)

}

read_cols_helper = function(input, call = rlang::caller_env()) {

    test_read = if (is(input, "character") && fs::file_exists(input) && tools::file_ext(input) == "tsv") {
        fread(input, sep = "\t", nrows = 1)
    } else {
        input[1,]
    }

    col_names = colnames(test_read)

    if (!all(col_names[1:2] == c("question", "answer"))) {
        cli::cli_abort("The first two column names of `input` must be \"question\" and \"answer\".")
    }

    if (dim(test_read)[2] < 3) {
        cli::cli_abort("There must be one or more response columns to evaluate.")
    }

    col_classes = sapply(test_read, class)

    if (any(col_classes != "character")) {
        cli::cli_abort("Non-character columns detected: {.val {names(col_classes)[col_classes != \"character\"]}} {?is/are} type{?s} {.cls {col_classes[col_classes != \"character\"]}}")
    }

    cli::cli_alert("Detected response columns: {.val {tail(col_names, -2)}}")
}

read_input = function(input) {

    read_type_helper(input)

    read_cols_helper(input)

    if (is.data.table(input)) return(input)

    if (is.data.frame(input)) return(as.data.table(input))

    fread(input, sep = "\t", colClasses = "character")

}