#This script generates pairwise t-tests and wilcoxon tests for all sorted results files you have in a directory after running SNF. NOTE: This script outputs to the directory you run it in

#should make this arguement step fancier later so that you can point to an input and an output directory
#args = commandArgs(TRUE)

#pathToFiles = args[1]

clusterResultFiles <- dir("./", pattern="sorted.txt")

for(filepos in 1:length(clusterResultFiles)){
filename=clusterResultFiles[filepos]
file_df <- read.table(file=filename, sep="\t", header=FALSE)

colnames(file_df) <- c("Level", "Index", "Silhouette")

#find the levels
levels <- unique(file_df[,1])

#list of the silhouette scores for each level
sil_list <-list()
# cluster_qual is the ratio of reps that were less than 0.45
cluster_qual <- list()

#for each level (nested for loop BABY!)
for(levelpos in 1:length(levels)){
  print(levels[levelpos])
  sils <- subset(file_df$Silhouette, file_df$Level==levels[levelpos])
  #find how many sils were 0.45 or greater
  goodClusterCount <- sum(sils >= 0.45)
  goodClusterPercent <- goodClusterCount / 100
  sil_list[[levelpos]] <- sils
  cluster_qual[[levelpos]] <- goodClusterPercent
}

#make a df of the sils
sil_df <- as.data.frame(sil_list)
colnames(sil_df) <- levels
#make a df of the prop sils higher than 0.45
cluster_qual_df <- as.data.frame(cluster_qual)
colnames(cluster_qual_df) <- levels
#write cluster quality to file
write(filename, file="prop_good_clusters_output.txt",append=TRUE, sep = " ")
write.table(cluster_qual_df, file="prop_good_clusters_output.txt",append=TRUE, sep = " ")
#run pairwise t-tests on all sils
ttests <- pairwise.t.test(sil_df, levels, p.adjust.method="bonferroni", pool.sd=FALSE, paired=FALSE,alternative="two.sided")
#run pairwise wilcoxon rank sum test
#note Have to transpose the matrix version of sil_df to get this to run correctly
wilcoxtest <- pairwise.wilcox.test(t(as.matrix(sil_df)), levels, p.adjust.method="bonferroni",alternative="two.sided")
#write results of stat tests to file
write(filename, file="statTest_output.txt",append=TRUE, sep = " ")
write("ttests", file="statTest_output.txt",append=TRUE, sep = " ")
write.table(ttests$p.value, file="statTest_output.txt",append=TRUE, sep = " ")
write("wilcoxons", file="statTest_output.txt",append=TRUE, sep = " ")
write.table(wilcoxtest$p.value, file="statTest_output.txt",append=TRUE, sep = " ")
}

