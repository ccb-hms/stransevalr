scramble = function(sent) {
    words = strsplit(sent, " ")[[1]]

    n = length(words)

    sample(words, size = n, replace = FALSE) |> paste(collapse = " ")
}

sample_n_words = function(baseline) {
    # Sample to the same number of words

    n_word = strsplit(baseline, " ")[[1]] |>
        length()

    words |>
        slice_sample(n = n_word) |>
        pull(word) |>
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
