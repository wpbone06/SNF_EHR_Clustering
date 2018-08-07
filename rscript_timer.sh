#rscript_timer.sh
# $1 is the snftool_runner.R wrapper file you wish to run

while read line
do
    echo $line
    filePath=`echo $line | cut -f3 -d " "`
    fileName=`basename $filePath`
    echo $fileName

    params=`echo $line | cut -f5,6,7 -d " " | tr " " "_"`
    echo $params

    time_fileName="time_"$fileName"_"$params.txt
    echo $time_fileName
    /usr/bin/time -o ./$time_fileName $line
done < $1
