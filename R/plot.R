#' Plot cosine similarity bars
#' @param res_dt a result from \code{\link{stransevalr()}}
#' @export
plot_cos_sim_bars = function(res_dt) {
    
    rlang::check_installed("ggplot2")
    rlang::check_installed("pals")
    
    res_dt[, cs_dt := lapply(cosine_sims,
                             \(x) data.table(QID = factor(paste0("q", seq_along(x)),
                                                          levels = paste0("q", seq_along(x))),
                                             cos_sim = x))]
    
    plot_input = res_dt[,rbindlist(cs_dt), by = m]
    
    added_names = c("scrambled_answer", "scrambled_combined_answers", 
                    "scrabble_match_nword", "scrabble_match_nchar", 
                    "reembed_ground_truth")
    
    model_names = unique(res_dt$m)[!(unique(res_dt$m) %in% added_names)]
    
    m_levels = c(sort(model_names), added_names)
    
    plot_input$m = factor(plot_input$m,
                          levels = m_levels)
    
    plot_input |>
        ggplot2::ggplot(ggplot2::aes(QID, cos_sim)) +
        ggplot2::geom_col(ggplot2::aes(group = m,
                                       fill = m),
                          position = ggplot2::position_dodge()) +
        ggplot2::scale_fill_manual(values = pals::brewer.paired(nrow(res_dt))) +
        ggplot2::theme_bw() + 
        ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                       text = ggplot2::element_text(size = 14)) +
        ggplot2::scale_y_continuous(limits = c(-.05, 1.05), 
                                    breaks = seq(0, 1, by = .2)) +
        ggplot2::labs(x = NULL, fill = "model")
}