#!/bin/bash



                            # -printf '%f\n'
array=$(find $1 -name "*.log" -type f) 

for file in ${array[*]}
do 
    sum=$((sum + $(awk -F ',' '{$6=substr($6,2,length($6)-2)} {print $6}' $file | awk '{SUM+=$1}END{print SUM}')))
    
done
echo $sum
    
#awk -F ',' 'sum+= $6'; echo $sum
#$6="substr($6,2,length($6)-1)"
