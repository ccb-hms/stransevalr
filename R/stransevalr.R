tmp_dir_helper = function(tmp_dir, call = rlang::caller_env()) {

    if (is.null(tmp_dir)) tmp_dir = fs::path_temp()

    if (!fs::dir_exists(tmp_dir)) fs::dir_create(tmp_dir)

    tmp_dir
}

run_sent_trans = function(scramble_dt, tmp_dir) {
    # devtools::load_all()
    # options(datatable.print.trunc.cols = TRUE)
    # tmp_dir = NULL
    #
    # cleanup = is.null(tmp_dir)
    #
    # tmp_dir = tmp_dir_helper(tmp_dir)
    #
    # scramble_dt = input |>
    #     read_input() |>
    #     multi_scramble(tmp_dir = tmp_dir)


    device = torch.device("cuda")

    torch.cuda.get_device_name(0)

    model = SentenceTransformer('multi-qa-MiniLM-L6-cos-v1')
    model2 = SentenceTransformer('pritamdeka/S-PubMedBert-MS-MARCO')

    q_df = pl.read_csv('~/ai_snt/qmd/sent_trans_eval/data/gpt4_with_scramble_demo.csv', separator = "\t")
    q_df2 = pl.read_csv('~/ai_snt/qmd/sent_trans_eval/data/llama_bioc_qa.csv')
    q_df.select(pl.col("Question", "Response"))

    comb_df = pl.concat([q_df, q_df2.select(pl.col("Response_llama2_Bioc_RAG", "Response_llama2_Temp0"))], how = "horizontal")

    questions = q_df['Question'].to_list()
    answers = q_df['Response'].to_list()

    grd_embed = model.encode(answers)
    grd_embed2 = model2.encode(answers)
    grd_embed.shape

    pl.from_numpy(grd_embed).write_csv("~/ai_snt/qmd/sent_trans_eval/output/ground_answer_embed_demo.csv")
    pl.from_numpy(grd_embed2).write_csv("~/ai_snt/qmd/sent_trans_eval/output/m2/ground_answer_embed_m2_demo.csv")

    df = pl.DataFrame(
        {
            "models": ["Response_Azure_GPT4_Temp0",
                       "Response_Azure_Bioc_RAG",
                       "Response_llama2_Bioc_RAG",
                       "Response_llama2_Temp0",
                       "scrambled_ground_truth",
                       "scrambled_mixed_ground_truth",
                       "scrabble_match_nword",
                       "scrabble_match_nchar",
                       "reembed_ground_truth"]
        }
    )

    print(df)

    df.write_csv("~/ai_snt/qmd/sent_trans_eval/output/model_df_demo.csv")

    for idx, query in enumerate(questions):

        ans_list = [comb_df.select(pl.col("Response_Azure_GPT4_Temp0")).item(idx,0),
                    comb_df.select(pl.col("Response_Azure_Bioc_RAG")).item(idx,0),
                    comb_df.select(pl.col("Response_llama2_Bioc_RAG")).item(idx,0),
                    comb_df.select(pl.col("Response_llama2_Temp0")).item(idx,0),
                    comb_df.select(pl.col("scrambled_ground_truth")).item(idx,0),
                    comb_df.select(pl.col("scrambled_mixed_ground_truth")).item(idx,0),
                    comb_df.select(pl.col("scrabble_match_nword")).item(idx,0),
                    comb_df.select(pl.col("scrabble_match_nchar")).item(idx,0),
                    comb_df.select(pl.col("reembed_ground_truth")).item(idx,0)]

    query_embedding = model.encode(ans_list, convert_to_tensor=True).cpu().numpy()
    m2_emb = model2.encode(ans_list, convert_to_tensor=True).cpu().numpy()

    pl.from_numpy(query_embedding).write_csv("~/ai_snt/qmd/sent_trans_eval/output/" + str(idx) + "_demo.csv")
    pl.from_numpy(m2_emb).write_csv("~/ai_snt/qmd/sent_trans_eval/output/m2/" + str(idx) + "_m2_demo.csv")


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
