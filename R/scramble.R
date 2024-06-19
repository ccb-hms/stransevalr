scramble = function(sent) {
    words = strsplit(sent, " ")[[1]]

    n = length(words)

    sample(words, size = n, replace = FALSE) |> paste(collapse = " ")
}

sample_n_words = function(baseline) {
    # Sample to the same number of words

    n_word = strsplit(baseline, " ")[[1]] |>
        length()

    words::words[sample(nrow(words::words),
                        n_word),]$word |>
        paste(collapse = " ")
}

sample_n_char = function(baseline, word_df) {
    # Sample to the same number of characters (roughly)
    n_char = nchar(baseline)

    samp_nchar = 0
    i = 0
    word_vec = vector("character", length = 1000)

    while(samp_nchar < n_char) {
        i = i+1

        next_word = sample(word_df$word, size = 1)

        word_vec[i] = next_word

        samp_nchar = samp_nchar + nchar(next_word) + 1
    }

    paste0(word_vec[1:i], collapse = " ")
}

multi_scramble = function(qa_dt, verbose) {
    
    force(qa_dt)
    
    if (verbose) cli::cli_alert_info("Scrambling input.")
    
    resp_word_df = qa_dt$answer |>
        paste0(collapse = " ") |>
        strsplit(split = " ") |>
        getElement(1) |>
        data.table(word = _)
    
    if (verbose) cli::cli_alert("Detected {unique(nrow(resp_word_df))} unique words across all provided answers.")

    qa_dt[,`:=`(scrambled_answer = vapply(answer,
                                          scramble,
                                          FUN.VALUE = "blah"),
                scrambled_combined_answers = vapply(answer,
                                                    sample_n_char,
                                                    word_df = resp_word_df,
                                                    FUN.VALUE = "blah"),
                scrabble_match_nword = vapply(answer,
                                              sample_n_words,
                                              FUN.VALUE = "blah"),
                scrabble_match_nchar = vapply(answer,
                                              sample_n_char,
                                              word_df = words::words,
                                              FUN.VALUE = "blah"),
                reembed_ground_truth = answer)][]

    qa_dt
}
