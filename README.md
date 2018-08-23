# SNF_EHR_Clustering
Scripts used to generate simulated data as well as run SNF on data.
#### Note: currently this repository contains all of the versions of the iterative versions of these scripts. All versions should have accurate comments in the code itself.

## Most Up to Date Code
### Scripts to generate simulated EHR data
cluster_data_simulator_cat_noise_cluster_command.py
cluster_data_simulator_cat_noise_cluster_command_subset0.py

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
