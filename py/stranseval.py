from pathlib import Path
import polars as pl
import torch
import transformers
import numpy as np
import random as rd
from sentence_transformers import SentenceTransformer

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
