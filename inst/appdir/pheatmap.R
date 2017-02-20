draw_colnames_45 <- function (coln, gaps, ...) {
    coord = pheatmap:::find_coordinates(length(coln), gaps)
    x = coord$coord - 0.5 * coord$size
    res = grid::textGrob(coln, x = x, y = grid::unit(1, "npc") - grid::unit(3, "bigpts"), vjust = 0.5, hjust = 1, rot = 45, gp = grid::gpar(...))
    return(res)
}

## 'Overwrite' default draw_colnames with your own version 
assignInNamespace(x = "draw_colnames", value = "draw_colnames_45", ns = asNamespace("pheatmap"))
