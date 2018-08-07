#!/usr/bin/python2.7

import re,time,os,sys,getopt,pdb,datetime
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification

def dummyCat(X_data_df,cat_feat):
    
    #convert to numpy array
    X_data = X_data_df.as_matrix()

    X_cat_data = X_data[:, :cat_feat]
    X_cont_data = X_data[:, cat_feat:]

    X_cat_df = pd.DataFrame(X_cat_data)
    X_cont_df = pd.DataFrame(X_cont_data)

    #cat_feat minus 1 because these data frames have column names starting at 0 to sig_cat -1
    cat_feat_counter = cat_feat -1

    #convert categorical columns to dummy variable columns
    #pdb.set_trace()
    while cat_feat_counter >= 0 :

        cat_feat_dummy_cols = pd.get_dummies(X_cat_df[cat_feat_counter], drop_first= True)

        X_cont_df = pd.concat([cat_feat_dummy_cols, X_cont_df], axis=1)

        cat_feat_counter = cat_feat_counter -1

    #convert X_cont_df back to a numpy matrix
    X_dummy_data = pd.DataFrame.as_matrix(X_cont_df)
    
    return(X_dummy_data)

def main():

    argsList = sys.argv[1:] ## grab arguments from command line
    helpstatement = "This script takes a sorted (cat vars then continuous vars) CAD_data file and returns a file that has the dummy coded categorical variables. NOTE: I recommend running this script in the same directory as the input file"

    if len(argsList) != 2:
        print "\nYou have supplied too many or too few arguments!\nAccepted arguments are:\n\n-i input_file"
        print helpstatement
        exit(1)

    ## Parsing arguments from command line
    else:
        try:
            opts, args = getopt.getopt(argsList,"i:")

        except:
            print("Usage: %s -i input_file" % sys.argv[0])
            print helpstatement
            exit(1)

    for (opt, arg) in opts:

        if opt == '-i':
            input_file_str = arg
            X_data_df = pd.read_table(input_file_str ,sep=" ")
            print "Input file: %s\n" %input_file_str

        else:
            print "\n%s is not an accepted option for this script" %opt
            print helpstatement
            exit(1)

    #hard coded number of categorical variables for now
    cat_feat = 5

    X_dummy_data = dummyCat(X_data_df,cat_feat)

    name = '{}'.format(input_file_str)

    np.savetxt('{}.dummy.txt'.format(name), X_dummy_data)

if __name__ == "__main__":
    main()

