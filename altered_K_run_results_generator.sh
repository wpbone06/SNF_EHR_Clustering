#!/bin/bash
# This will generate the bar graph of value of K vs silhouette score and a file containing the K values and silhouette scores of the positions with the max and min silhouette scores
# assumed you will run this in an altered K output folder

#parse the silouhette scores for reach run and write to file with the file name
echo
pathy=`pwd`
echo $pathy
fileName=`echo $pathy | sed "s|\(.*\)/|\1-|" | sed "s|.*/||g"`
echo $fileName
# Pick the color of the graph to feed to R for the bar graph
if [[ $fileName == *"20_noise"* ]]
then
    color="blue"

elif [[ $fileName == *"80_noise"* ]]
then
    color="green"

else
    color="red"
fi

echo $color

for file in ./silhoulette_values_SNFtool_X_*
do echo $file
    silVal=`grep SNFtool $file | tr " " "\t" | cut -f4`
    echo $file $silVal >> ./results_silhouette_values_SNFtool_X_$fileName.txt
done

echo ./results_silhouette_values_SNFtool_X_$fileName.txt
# remove the file names except for the K value
cat ./results_silhouette_values_SNFtool_X_$fileName.txt | tr " " "\t" | tr "_" "\t" | cut -f 10,14 | sort -nk 1 >  ./results_silhouette_values_SNFtool_X_"$fileName"_dataframe.txt

echo "./results_silhouette_values_SNFtool_X_$fileName_dataframe.txt file complete"

echo "running /home/wbone/group/personal/wbone/SNFtool_hyperparameter_project/code/altered_k_analysis_results.R"
# Run Rscript to read results_silhoulette_values_SNFtool_X_$fileName_dataframe.txt into R dataframe, generate ggbar output and find the K values that had the max and min silhouette scores

Rscript /home/wbone/group/personal/wbone/SNFtool_hyperparameter_project/code/altered_k_analysis_results.R ./results_silhouette_values_SNFtool_X_"$fileName"_dataframe.txt $fileName $color

