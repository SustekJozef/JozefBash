#!/bin/bash


# Finds all *.csv files from selected directories given in argument
# concatenate of files in one stream
array+=$(find $1 -name "*.csv" -type f)



# removes additional 4 characters in 4th collum,because of mistakes in log, which has writen 2 times year eg.1.1.20202020.
for file in ${array[*]}
do
    awk -F ',' '{$4=substr($4,1,length($4)-4)} {print $4}' "$file" | sort -t '-' -nk3 -nk2 -nk1 ;  print
    #sorting dates in files by year, month and day.
done




 #splits date to value of year, month and day (numeric value). After that is possible to get second from epoch (from %Y%m%d)
   # awk -F, '{split($1,date,"-");
   #              $1=mktime(date[3] " " date[2] " " date[1] " " "00 00 00");
   #              print}' #| sort -n $1

    #awk '{print $1.strftime("%d-%m-%Y")}' | awk '{print $1}'



