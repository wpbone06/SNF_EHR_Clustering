#!/usr/bin/env Rscript

#snftool_runner.sh
#NOTE!!!!: script currently assumes you are providing a cluster label file with 3 clusters
#This script is designed to run SNFtool given:
#an input data file "(X file)"
#an input cluster label file "(Y file)"
# a value for K (any positive integer)
# a value for alpha (between 0 and 1)
# a value for T (any positive integer) Number of iterations
# the number of categorical columns in the X file
# the number of continuous columns in the X file

#################################################################################################################################
# Parse command-line arguments
#################################################################################################################################

args = commandArgs(TRUE)

arg_X_infile = args[1] # data file
arg_Y_file = args[2] # labels file
arg_K = args[3] # K value
arg_a = args[4] # alpha value
arg_T = args[5] # T value
arg_cat_cols = args[6] # number of categorical data columns
arg_cont_cols = args[7] # number of continuous data columns

print("NOTE!!!!: script currently assumes you are providing a cluster label file with 3 clusters!")
todate = paste(format(Sys.time(), "%Y-%m-%d"))
#print(todate)
print("Input data file:")
print(arg_X_infile)
print("cluster label file:")
print(arg_Y_file)

K = as.integer(arg_K)
alpha = as.numeric(arg_a)
T = as.numeric(arg_T)
cat_cols <- as.numeric(arg_cat_cols)
cat_cols_plus_1 <- cat_cols +1
cont_cols = as.numeric(arg_cont_cols)

print("number of categorical data columns:")
print(cat_cols)
print("number of continuous data columns:")
print(cont_cols)

print("K value (# of neighbors):")
print(K)
print("alpha value")
print(alpha)
print("T value(# of iterations):")
print(T)

#################################################################################################################################
#loading required libraries
#################################################################################################################################

library(SNFtool)
library(ggplot2)
library(SpatialTools)
library(viridis)
library(cluster)

#################################################################################################################################
#Read in data and labels
#################################################################################################################################

X.dum <- read.table(arg_X_infile, header=FALSE, sep=" ")

Y <- read.csv(arg_Y_file, header=FALSE, sep=" ")

#Split into categorical and continuous dataframes
cat.dum <- X.dum[, 1:cat_cols] #cat_cols
cont.dum <- X.dum[, cat_cols_plus_1:ncol(X.dum)] #cat_cols_plus_1

#################################################################################################################################
#Convert to matrix and store in a list
#################################################################################################################################

mat.cat.dum <- as.matrix(cat.dum)
mat.cont.dum <- as.matrix(cont.dum)
mat.dat.dum <- list(mat.cont.dum, mat.cat.dum)

#Calculate the Euclidean distance for each matrix
distL.dum =lapply(mat.dat.dum, function(x) dist2(x, x))

#################################################################################################################################
#Run SNFtool
#################################################################################################################################
print("Running SNFtool")


XfileName = basename(arg_X_infile)
WfileNameNoDot = paste("Wfile", XfileName, arg_K, arg_a, arg_T, todate, sep = "_" )
#print(WfileNameNoDot)
WfileName = paste(WfileNameNoDot, "txt", sep = ".")
print(WfileName)

affinityL.dum = lapply(distL.dum, function(x) affinityMatrix(x, K, alpha))
set.seed(3)

print("W.dum = SNF(affinityL.dum, K, T)")
W.dum = SNF(affinityL.dum, K, T)

#Write W.dum to file in case something happens
print("Writing W.dum to file")
write.table(W.dum, file=WfileName, sep="\t", row.names=FALSE, quote=FALSE)

#################################################################################################################################
# Run spectralClustering()
#################################################################################################################################
print("Running spectralClustering")
#print("group.dum = spectralClustering(W.dum,3)")
print("SNFcluster.dum <- as.data.frame(group.dum)")
print("custers = estimateNumberOfClustersGivenGraph(W.dum, NUMC=2:10)")
clusters = estimateNumberOfClustersGivenGraph(W.dum, NUMC=2:10)
print("recommended clusters")
print(clusters)
group.dum = spectralClustering(W.dum,clusters)
SNFcluster.dum <- as.data.frame(group.dum)

#Concatenate the true labels with the called labels by SNFTool
SNFcluster.dum <- cbind(SNFcluster.dum, Y)
colnames(SNFcluster.dum) <- c("spectralClustering", "TrueLabel")

#Write Cluster calls and true calls to file
SNFLablesfileNameNoDot = paste("SNFLables", XfileName, arg_K, arg_a, arg_T, todate, sep = "_" )
SNFLablesfileName = paste(SNFLablesfileNameNoDot, "txt", sep = ".")

write.table(SNFcluster.dum, file = SNFLablesfileName, sep="\t", row.names=FALSE, quote=FALSE)

#################################################################################################################################
#Calculate Network Mutual Information
#################################################################################################################################

NMI <- signif(calNMI(group.dum, Y$V1), digits=3)

#################################################################################################################################
#Get the silhouette values
#################################################################################################################################

silhouettes <- data.frame()
#Convert W to distance matrix

WdistfileNameNoDot = paste("Wdistfile", XfileName, arg_K, arg_a, arg_T, todate, sep = "_" )
#print(WfileNameNoDot)
WdistfileName = paste(WdistfileNameNoDot, "txt", sep = ".")

W.dist <- as.dist(1/W.dum)
W.dist <- as.matrix(W.dist)

#Write W.dist to file for heatmaps of distance for Anna
write.table(W.dist, file=WdistfileName, sep="\t", row.names=FALSE, quote=FALSE)


#Convert W to x,y coordinates
mds <- cmdscale(W.dist, k=2)
#This step takes a while

#Convert back to distance matrix
coord <- as.matrix(mds)
dist.mat <- dist1(coord)
sil <- silhouette(Y$V1, dist.mat)
avg.sil <- summary(sil)$avg.width

#################################################################################################################################
#Plot clusters
#################################################################################################################################

mds <- as.data.frame(mds)
mds <- cbind(mds, Y$V1)
names(mds) <- c("X", "Y", "Cluster")
mds$Cluster <- as.factor(mds$Cluster)
meth <- "SNFtool - dummy-encoded"
silhouettes <- cbind(Method=meth, Silhouettes=avg.sil)

clusterPlotNoDot = paste("clusterPlot", XfileName, arg_K, arg_a, arg_T, todate, sep = "_")
clusterPlotFileName = paste(clusterPlotNoDot, "pdf", sep = ".")

silhouletteNoDot = paste("silhoulette_values_SNFtool", XfileName, arg_K, arg_a, arg_T, todate, sep = "_")
silhouletteFileName = paste(silhouletteNoDot, "txt", sep = ".")

plotCluster <- ggplot(mds,aes(x=X,y=Y)) + geom_point(aes(color=Cluster),size=1) + ggtitle(paste(meth,",NMI=",NMI,sep="")) + scale_color_viridis(discrete=TRUE,name="Cluster") + theme(legend.title=element_text(size=9))

ggsave(plotCluster, filename=clusterPlotFileName, height=7, width=6, dpi=300)

write.table(silhouettes, file=silhouletteFileName, sep="\t", row.names=FALSE, quote=FALSE)

