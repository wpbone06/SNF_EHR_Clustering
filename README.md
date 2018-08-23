# SNF_EHR_Clustering
Scripts used to generate simulated data as well as run SNF on data.
#### Note: currently this repository contains all of the iterative versions of these scripts. All versions should have accurate comments in the code itself.

## Most Up to Date Code
### Scripts to generate simulated EHR data
* cluster_data_simulator_cat_noise_cluster_command.py
* cluster_data_simulator_cat_noise_cluster_command_subset0.py

Both of these scripts generate data belonging to separate clusters data from a multivariate normal distribution. The number of samples, number of features (continuous and categorical), and number of clusters can be set via command line arguements. cluster_data_simulator_cat_noise_cluster_command_subset0.py has an extra command line prompt, "-r", that allows for the random subsampling of the first cluster of data. This can be used to make clusters with different number of samples in them.

###cluster_data_simulator_cat_noise_cluster_command.py
#### How to Run this code
This script will output the simulation files in the directory you run it from. It requires t
hat you supply it with the number of samples, the number of signal continuous features, the number of signal categori
cal features, the number of noise features, the number of EVENLY SIZED clusters you wish to generate, and a seed in case you wish to regenerate the same data.

-n # of samples -x sig_con t -y sig_cat -w cat_noise_feat -z cont_noise_feat -s seed -c # of clusters

Example Command:
cluster_data_simulator_cat_noise_cluster_command.py -n 5000 -x 5 -y 5 -w 20 -z 20 -s 10 -c 2

###cluster_data_simulator_cat_noise_cluster_command_subset0.py
#### How to Run this code
This script will output the simulation files in the directory you run it from. It requires t
hat you supply it with the number of samples, the number of signal continuous features, the number of signal categori
cal features, the number of noise features, the number of EVENLY SIZED clusters you wish to generate, the number of s
amples you would like to remove from cluster 0, and a seed in case you wish to regenerate the same data.

-n # of samples -x sig_con t -y sig_cat -w cat_noise_feat -z cont_noise_feat -s seed -c # of clusters -r # of samples to remove from cluster 0

Example Command:
cluster_data_simulator_cat_noise_cluster_command_subset0.py -n 6667 -x 10 -y 10 -w 15 -z 15 -s 10 -c 2 -r 1667

### Scripts to run SNFtool
* snftool_runner_writes_dist_matrix_pdf_graphics_cluster_command.R

### snftool_runner_writes_dist_matrix_pdf_graphics_cluster_command.R
This script is an R script that runs SNFtool on a given set of samples. NOTE: this script assumes you know or have hypothesized "TRUE" subgroups/clusters in the data. Given that information, it then calculates the silhouette scores and and plots the clusters on a two dimensional space

This script is designed to run SNFtool given:
an input data file that has been dummy coded "(X file)", an input cluster label file "(Y file)", a value for K (any positive integer), a value for alpha (between 0 and 1), a value for T (any positive integer) Number of iterations, the number of categorical columns in the X file, the number of continuous columns in the X file, the number of clusters in the data

arg_X_infile = args[1] # data file
arg_Y_file = args[2] # labels file
arg_K = args[3] # K value
arg_a = args[4] # alpha value
arg_T = args[5] # T value
arg_cat_cols = args[6] # number of categorical data columns
arg_cont_cols = args[7] # number of continuous data columns
arg_clusters = args[8] # number of clusters in the data

Example Command:
Rscript snftool_runner_writes_dist_matrix_pdf_graphics_cluster_command.R X_file_5000_5_5_20_20_2_10.dummy.csv Y_file_5000_5_5_20_20_2_10.csv 20 0.5 20 25 25 2

#### Scripts to collect data from multiple simulations

* cluster_noise_results_generator.sh
* cluster_proportion_results_generator.sh
* cluster_sample_size_results_generator.sh
* cluster_structure_results_generator.sh
* altered_K_run_results_generator.sh
* altered_k_analysis_results.R

All of these scripts are designed to collect the silhouette scores for multiple simulations and SNFtool runs. All of the bash (".sh" files) are just collected silhouette scores from a collection of files in a directory. The altered_k_analysis_results.R file takes the output of altered_K_run_results_generator.sh and makes a histogram of the silhouette scores given different values of K. Feel free to use these if they are helpful!
