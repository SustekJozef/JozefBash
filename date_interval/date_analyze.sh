#!/bin/bash

# Finds all *.csv files from selected directories given in argument
# cuts first line from each file (first line included head of document
arr+=$(find $1 -name "*.csv" -type f)

allLogs=$(
  for file in ${arr[*]}; do
    sed '1d' $file |
      awk -F ',' ' {print substr($4,1,length($4)-4)}'
  done
)

echo "$allLogs"
#    sort -n -t '-' -k3 -k2 -k1










#$(sort -n -t '-' -k3 -k2 -k1 "$allLogs")
# concatenate of files in one stream
#doriešiť, aby to bolo robené ako begin v cykle nižšie

#
#for file in ${array[*]};
#do
#    array2=$(sed '1d' "$file")
#done

#awk -F ',' {'$4=substr($4,1,length($4)-4) "$array2[1]"};{print "$4"}'
#echo "$array2"

#
#for file in ${array[*]};
#do
#    # removes additional 4 characters in 4th column,because of mistakes in log, which has writen 2 times year eg.1.1.20202020.
# #   awk "{ print "$4"}" "$file2";
#
##    awk BEGIN {sed '1d' "$file"} |
#
#    awk '{ sed '1d' "$file"}' {print}  "$file"  |
#    awk -F ',' '{print} {substr($1,1,length($)-4)}' "$file" |
#    #sorting dates in files by year, month and day.
#    sort -t '-' -nk3 -nk2 -nk1;
#done
#awk options 'selection _criteria {action }' input-file > output-file

#splits date to value of year, month and day (numeric value). After that is possible to get second from epoch (from %Y%m%d)
# awk -F, '{split($1,date,"-");
#              $1=mktime(date[3] " " date[2] " " date[1] " " "00 00 00");
#              print}' #| sort -n $1

#awk '{print $1.strftime("%d-%m-%Y")}' | awk '{print $1}'

#
#awk -F ',' '{$4=substr($4,1,length($4)-4) "$file2"}'; print "$4"  |
#    #sorting dates in files by year, month and day.
#    sort -t '-' -nk3 -nk2 -nk1; print
