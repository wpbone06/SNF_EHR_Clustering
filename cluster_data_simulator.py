#!/usr/bin/python2.7

import re,time,os,sys,getopt,pdb,datetime
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification

## The purpose of this script is to generate simulated categorical and continuous variables over 50 features to test unsupervised learning methods.
def flat(vector):

    flat_vector = vector.flatten()
    #pdb.set_trace()

    return flat_vector


################################################################################
## cat3: Generate 3 level categorical values from continuous values

################################################################################
def cat3(vector):

    return pd.qcut(vector, [0, .33, .66, 1]).codes

################################################################################
## make_data: Run make_classification and generates noise feature using numpy. Also calls cat3 to generate categorical features.

################################################################################
def make_data(n_samples, sig_cont, sig_cat, noise_feat, clusters, seed):

    sig_feat = sig_cont + sig_cat

    #Make the simulated data using make_classification
    X_data, y_vector = make_classification(n_samples= n_samples,
                               n_features= sig_feat,
                               n_informative= sig_feat,
                               n_classes=clusters,
                               n_redundant= 0,
                               n_repeated= 0,
                               class_sep= 2,
                               n_clusters_per_class= 1,
                               shuffle= False,
                               random_state= seed)

    #generate the noise features from a uniform distribution
    X_data = np.concatenate([X_data, np.random.random((n_samples, noise_feat))],axis = 1)

    #generate the categorical features from the first n continuous variables for all n samples in X_data
    if sig_cat > 0:
        X_data[:, :sig_cat] = np.apply_along_axis(cat3, axis=0, arr=X_data[:, :sig_cat])

        X_cat_data = X_data[:, :sig_cat]
        X_cont_data = X_data[:, sig_cat:]
        
        # convert to pandas dataframes
        X_cat_df = pd.DataFrame(X_cat_data)
        X_cont_df = pd.DataFrame(X_cont_data)

        cat_feat_counter = sig_cat -1

        #sig_cat minus 1 because these data frames have column names starting at 0 to sig_cat -1
        while cat_feat_counter >= 0 :

            cat_feat_dummy_cols = pd.get_dummies(X_cat_df[cat_feat_counter], drop_first= True)

            X_cont_df = pd.concat([cat_feat_dummy_cols, X_cont_df], axis=1)


            cat_feat_counter = cat_feat_counter -1

        #convert X_cont_df back to a numpy matrix
        X_dummy_data = pd.DataFrame.as_matrix(X_cont_df)

    else:
         X_dummy_data = "No_cats"
 
    #generate a boolean vector of which features are categorical
    cat_bool = np.arange(sig_feat + noise_feat) < sig_cat

    return (X_data, y_vector, cat_bool, X_dummy_data)

################################################################################
## run_sim generates output files and coordinates the call to generate the simulated data.

################################################################################
def run_sim(n_samples, sig_cont, sig_cat, noise_feat, clusters, seed):

    X_data, y_vector, cat_bool, X_dummy_data = make_data(n_samples, sig_cont, sig_cat, noise_feat, clusters, seed)

    name = '_{}_{}_{}_{}_{}'.format(n_samples, sig_cont, sig_cat, noise_feat, seed)

    np.savetxt('./X{}.csv'.format(name), X_data) # Matrix n samples by d features
    np.savetxt('./Y{}.csv'.format(name), y_vector) # vector of which cluster each sample belongs to
    np.savetxt('./cat{}.csv'.format(name), cat_bool)

    if X_dummy_data != "No_cats":
        np.savetxt('./X{}.dummy.csv'.format(name), X_dummy_data) # Matrix with


def main():

    argsList = sys.argv[1:] ## grab arguments from command line
    helpstatement = "\n\nThis script will output the simulation files in the directory you run it from. It requires that you supply it with the number of samples, the number of signal continuous features, the number of signal categorical features, the number of noise features, and a seed in case you wish to regenerate the same data.\n"

    if len(argsList) != 10:
        print "\nYou have supplied too many or too few arguments!\nAccepted arguments are:\n\n-n n_samples -x sig_cont -y sig_cat -z noise_feat -s seed"
        print helpstatement
        exit(1)

    ## Parsing arguments from command line
    else:
        try:
            opts, args = getopt.getopt(argsList,"n:x:y:z:s:")

        except:
            print("Usage: %s -n n_samples -x sig_cont -y sig_cat -z noise_feat -s seed" % sys.argv[0])
            print helpstatement
            exit(1)

    for (opt, arg) in opts:

        if opt == '-n':
            samples_str = arg
            n_samples = int(samples_str)
            print "Number of samples =  %s\n" %samples_str

        elif opt == '-x':
            sig_cont_str = arg
            sig_cont = int(sig_cont_str)
            
            print "Number of continuous signal features %s\n" %sig_cont_str

        elif opt == '-y':
            sig_cat_str = arg
            sig_cat = int(sig_cat_str)

            print "Number of categorical signal features %s\n" %sig_cat_str

        elif opt == '-z':
            noise_feat_str = arg
            noise_feat = int(noise_feat_str)

            print "Number of noise features %s, (all continuous)\n" %noise_feat_str 

        elif opt == '-s':
            seed_str = arg
            seed = int(seed_str)

            print "seed for random value generator %s" %seed_str

        else:
            print "\n%s is not an accepted option for this script" %opt
            print helpstatement
            exit(1)

    
    #n_samples = 100 ## number of samples
    #sig_feat = 40 ## number of signal features
    #sig_cat = 20 ## number of categorical signal features
    #sig_cont = 20 ## number of continuous signal features
    #noise_feat = 10 ## number of continous 

    #Currently script only generates 3 cluster simulated data
    clusters = 3 ## number of clusters

    run_sim(n_samples, sig_cont, sig_cat, noise_feat, clusters, seed)

if __name__ == "__main__":
    main()
