#!/usr/bin/env Rscript
#altered_k_analysis_results.R
library(ggplot2)

args = commandArgs(TRUE)

arg_input_dataframe_file = args[1]
plot_id = args[2]
color = args[3]

k_sil <- read.table(file=arg_input_dataframe_file, header=FALSE)
colnames(k_sil) <- c("k_value", "silhouette_value")

#The X-axis might not be pretty, but it was a pain to write this to be right for every n size

# Plot bar graph
ggbar <- ggplot(k_sil, aes(k_value, silhouette_value)) + geom_bar(stat = "identity", fill=color) + ggtitle(plot_id) + scale_y_continuous(name="silhouette_value", c(0.1,0.2,0.3,0.4,0.5,0.6,0.7) , c(0.1,0.2,0.3,0.4,0.5,0.6,0.7), limits = c(0,0.7)) + scale_x_continuous(name="k_value")

plot_fileName = paste(plot_id, "pdf", sep = ".")
print(plot_fileName)

ggsave(filename=plot_fileName, plot=ggbar)

kmax_min_file_prep = paste("kmax_min",plot_id, sep = "-")
kmax_min_fileName = paste(kmax_min_file_prep, "txt", sep = ".")
print(kmax_min_fileName)

# output the max and min silhouette values to a file for review later
kmax <- k_sil[which.max(k_sil$silhouette_value),]
kmin <- k_sil[which.min(k_sil$silhouette_value),]
kmax_min <- rbind(kmax,kmin)
#rownames(kmax_min) <- c("max","min")
kmax_min
write.table(kmax_min, file=kmax_min_fileName, sep="\t", row.names=TRUE, quote=FALSE)
