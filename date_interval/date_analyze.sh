#!/bin/bash
# Finds all *.csv files from selected directories given in argument
# cuts first line from each file (first line included head of document
arr+=$(find $1 -name "*.csv" -type f)

# function solves problem with parsing date to number e.g. '01' to '1'
convertTo1DecimalNumb () {
               var=$1  # dorobiť- poskúšať ako sa to dá bez pomocných premenných
               var2=$(echo "$1" | cut -c1-1)
               result=0
               if [[ var2 -eq 0 ]]
               then echo "$(echo "$var" | cut -c2-2)"
               else echo "$(echo "$var" | cut -c1-2)"
               fi
           }



smallerDate="$2"
greaterDate="$3"

#Taken second argument (smaller date) for making lower limit variables
lowerLimitYear="${smallerDate:6:4}" #only variable (even not in "") and numbers works - any complex expressions
lowerLimitMonth=$(convertTo1DecimalNumb "${smallerDate:3:2}")
lowerLimitDay=$(convertTo1DecimalNumb "${smallerDate:0:2}")

#Taken third argument (greater date) to make lower limit variables
greaterLimitYear="${greaterDate:6:4}" #only variable (even not in "") and numbers works - any complex expressions
greaterLimitMonth=$(convertTo1DecimalNumb "${greaterDate:3:2}")
greaterLimitDay=$(convertTo1DecimalNumb "${greaterDate:0:2}")

# allLogs is variable where are joined all logs. In allLogs is only
# name and date (with removed log mistake - where 4 last characters was redundent
allLogs=$(
  for file in ${arr[*]}; do
    #delete first row of each log (that which contains head)
    sed '1d' $file |
      #Remove last 4 characters, because there was a mistake in the log in
      #last 4 characters. And pipe gets second and fourth column with new
      #delimeter ','
      awk -F ',' ' { print ""$2","substr($4,1,length($4)-4)""}' #|
    # This part controls if current date (date taken by awk (so precisely one row))
    # is between two given dates. It works with all three numbers representing a date.
    # At first it controls if is between same year, then month than day. At day it
    # has to take only part with date information and not with text of name and surname
    #(because of used delimiter) and at the end - it takes name and surname (text that is cut by
    # 2 characters (which represent day - e.g. 21 (21.12.1988)
    #      awk   -F '-' -v v1="$lowerLimitYear" -v v2="$lowerLimitMonth" -v v3="$lowerLimitDay" -v v4="$greaterLimitYear" -v v5="$greaterLimitMonth" -v v6="$greaterLimitDay" '
    #      {if ( ($3 -ge v1) && ($3 -le v4) ) print $3; print v1
    #                     if ( ($2 -ge v2) && ($2 -le v5) );
    #                       if ( ("$(substr($1,length($1)-2,length($1))" -ge v3) && ("$(substr($1,length($1)-2,length($1))" -le v6) )
    #                                  printf "%s; ", substr($1,1,length($1)-3) } '
  done
)

while IFS= read -r line; do
  {
    #length of input (name and date)
    line_length= echo -n $line | wc -m
    #current date, which should or should not be printed (printed only when is between specified dates)
    currentYear="${line:($line_length - 4):4}"
    currentMonth=$(convertTo1DecimalNumb "${line:($line_length - 7):2}")
    currentDay=$(convertTo1DecimalNumb "${line:($line_length - 10):2}")

#when is current year between two years
    if [[ "$currentYear" -gt "$lowerLimitYear" && "$currentYear" -lt "$greaterLimitYear" ]]; then
      printf "%s" "${line:0:($line_length - 11)}"
    fi
#when is current year is the same, lower and upper year
      if [[ "$lowerLimitYear" -eq "$greaterLimitYear" && "$currentYear" -eq "$lowerLimitYear"  ]]; then                                                  #the same year
        if   [[ "$currentMonth" -gt "$lowerLimitMonth" && "$currentMonth" -lt "$greaterLimitMonth" ]]; then #specific month is between limits
                printf "%s" "${line:0:($line_length - 11)}"
        elif [[ "$currentMonth" -eq "$lowerLimitMonth" && "$currentMonth" -eq "$greaterLimitMonth" ]] ; then #the same month #finding record from one specific day-- the same day
          if [[ "$currentDay" -ge "$lowerLimitDay" && "$currentDay" -le "$greaterLimitDay" ]] ; then         #01.01.2020 greater date
                printf "%s" "${line:0:($line_length - 11)}"                                                    #01.01.2020 current (to find)
          fi                                                                                                   #01.01.2020 lower date
        elif [[ "$currentMonth" -ge "$lowerLimitMonth" ]]; then       #only if lowerLimit is the same - not both how above this
            if [[ "$currentDay" -ge "$lowerLimitDay" ]]; then
                printf "%s" "${line:0:($line_length - 11)}"
            fi
        elif [[ "$currentMonth" -ge "$greaterLimitMonth" ]] ; then       #only greaterLimit is the same - not both how above this
            if [[ "$currentDay" -le "$greaterLimitDay" ]] ; then
                printf "%s" "${line:0:($line_length - 11)}"
            fi
        fi
      elif [[ "$currentYear" -eq "$lowerLimitYear" ]]; then
              if [[ "$currentMonth" -gt "$lowerLimitMonth" ]]; then
                printf "%s" "${line:0:($line_length - 11)}"
              elif [[ "$currentMonth" -eq "$lowerLimitMonth" ]]; then
                if [[ "$currentDay" -ge "$lowerLimitDay" ]]; then
                  printf "%s" "${line:0:($line_length - 11)}"
                fi
              fi

      elif [[ "$currentYear" -eq "$greaterLimitYear" ]] ; then
          if [[ "$currentMonth" -lt "$lowerLimitMonth" ]] ; then
            printf "%s" "${line:0:($line_length - 11)}"
          elif [[ "$currentMonth" -eq "$greaterLimitMonth" ]] ; then
            if [[ "$currentDay" -le "$lowerLimitDay" ]] ; then
                    printf "%s" "${line:0:($line_length - 11)}"
            fi
          fi
      fi
}
done <<<"$allLogs" |
  awk '  (!( $1~/^[0-9]+$/)) { printf "%s %s\n", $1, substr($2,0,length($2)-2 ) }   '






#
#echo $lowerLimitYear
#echo $lowerLimitMonth
#echo $lowerLimitDay
#cut -c startIndx-stopIndx
#
#"${"$2":4:10}"

# ${varname:n:m}
#"${substr($2,length($2)-4,length($2))}"




#NOT WORKING RIghT

#
#if [ "$currentYear" -gt "$lowerLimitYear" ] && [ "$currentYear" -lt "$greaterLimitYear" ]; then
#      printf "%s" "${line:0:($line_length - 11)}"
#
#      elif [ "$lowerLimitYear" -eq "$greaterLimitYear" ]; then
#        if [ "$currentMonth" -gt "$lowerLimitMonth" ] && [ "$currentMonth" -lt "$greaterLimitMonth" ]; then
#          printf "%s" "${line:0:($line_length - 11)}"                                       # not function
#        elif [ "$currentDay" -ge "$lowerLimitDay" ] && [ "$currentDay" -le "$greaterLimitDay" ]; then
#          printf "%s" "${line:0:($line_length - 11)}"
#        fi
#
#          elif [ "$currentYear" -eq "$lowerLimitYear" ]; then
#              if [ "$currentMonth" -gt "$lowerLimitMonth" ]; then
#                printf "%s" "${line:0:($line_length - 11)}"
#              elif [ "$currentMonth" -eq "$lowerLimitMonth" ]; then
#                if [ "$currentDay" -ge "$lowerLimitDay" ]; then
#                  printf "%s" "${line:0:($line_length - 11)}"
#                fi
#              fi
#
#            elif [ "$currentYear" -eq "$greaterLimitYear" ]; then
#                if [ "$currentMonth" -lt "$lowerLimitMonth" ]; then
#                  printf "%s" "${line:0:($line_length - 11)}"
#                elif [ "$currentMonth" -eq "$greaterLimitMonth" ]; then
#                  if [ "$currentDay" -le "$lowerLimitDay" ]; then
#                    printf "%s" "${line:0:($line_length - 11)}"
#                  fi
#                fi
#    fi
#

#
#
#
#
#&& [ "$currentMonth" -lt "$greaterLimitMonth" ];  then
#      printf "%s" "${line:0:($line_length - 11)}"
#    els [ "$currentDay" -gt "$lowerLimitDay" ] && [ "$currentDay" -lt "$greaterLimitDay" ];
#      printf "%s" "${line:0:($line_length - 11)}"
#    fi
#
#
#
#
#    if [ "$currentYear" -eq "$greaterLimitYear" ] && [ "$currentMonth" -lt "$greaterLimitMonth" ] && [ "$currentMonth" -gt "$lowerLimitMonth" ]; then
#      printf "%s" "${line:0:($line_length - 11)}"
#    else [ "$currentDay" -gt "$lowerLimitDay" ] && [ "$currentDay" -lt "$greaterLimitDay" ];
#      printf "%s" "${line:0:($line_length - 11)}"
#    fi
#  }
#
#
#
#

#bad if logic
#if [ "$currentYear" -gt "$lowerLimitYear" ] && [ "$currentYear" -lt "$greaterLimitYear" ]; then
#      printf "%s" "${line:0:($line_length - 11)}"
#
#    elif [ "$currentYear" -eq "$lowerLimitYear" ] && [ "$currentMonth" -gt "$lowerLimitMonth" ] && [ "$currentMonth" -lt "$greaterLimitMonth" ]; then
#      printf "%s" "${line:0:($line_length - 11)}"
#
#    elif [ "$currentYear" -eq "$greaterLimitYear" ] && [ "$currentMonth" -lt "$greaterLimitMonth" ] && [ "$currentMonth" -gt "$lowerLimitMonth" ]; then
#      printf "%s" "${line:0:($line_length - 11)}"
#
#    elif [ "$currentDay" -gt "$lowerLimitDay" ] && [ "$currentDay" -lt "$greaterLimitDay" ]; then
#      printf "%s" "${line:0:($line_length - 11)}"
#    fi




# 01-08-2999 06-01-3200
#
#+ IFS=
#+ read -r line
#+ line_length=
#+ echo -n Brielle Patel,24-05-2020
#+ wc -m
#+ currentYear=2020
#+ currentMonth=05
#+ currentDay=24
#+ '[' 2020 -gt 2999 ']'
#+ '[' 2020 -eq 2999 ']'
#+ '[' 2020 -eq 3200 ']'
#+ '[' 24 -gt 01 ']'
#+ '[' 24 -lt 06 ']'
#
#
#











#
#
#
#a=25
#b=35
#if [ 1 -lt 2 ]
#then echo ahoj
#fi
#
#
#

##
##
#g="065ahoj016"
#
#j="${g:7:3}"
#i=${g:0:3}
#echo $j
#echo $i
#
#
#








#
#if false; then
#printf "154654531351543153"
#elif false; then
#printf "uuuuu"
#elif true; then
#printf "bbbbbbbbbbbbbbbbb"
##03-02-2121
##04-04-2020
##01-08-2999 06-01-3200
##
##
#
#
#fi



#
#if [ "$j" -gt  "$i" ] # so it compares right
#then echo ahojhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
#else echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#fi
#if [ "$j" -lt  "$i" ]
#then echo ahojhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
##else echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#fi
#




#if [ true ]; then
#      printf "%s" ${prva}
#fi
#    elif [ true ]; then
#      printf "%s" "${druha}"








#
#good
#if [ "$j" -gt  "$i" ]
#then echo ahojhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
# line 98: [: : integer expression expected err -- because óf " "
#fi
#
#[ 1919 -ge 1890 ']'
#+ '[' 1919 -le 2128 ']'
#+ '[' 12 -ge 12 ']'
#+ '[' 12 -le 12 ']'
#+ '[' 30 -ge 21 ']'
#+ '[' 30 -le 31 ']'
#+ printf %s 'Aphrodite Strong'
#Aphrodite Strong+ IFS=
#
#
#if [ "$a" -gt 0 ]
#then
#  if [ "$a" -lt 5 ]
#  then
#    echo "The value of \"a\" lies somewhere between 0 and 5."
#  f i
#fi
#
#
#var8=$"abcdef" ;
##f= "${var8:1:4}";
##echo "$f";
#
#
#var77= expr length  $var8
#echo "$var77"
#
#
#
#' {if ( ($3 -ge $v1) && ($3 -le $v4) ) print 1
#                     if ( ($2 -ge $v2) && ($2 -le $v5) ) print 2;
#                       if ( ("$(substr($1,length($1)-2,length($1))" -ge $v3) && ("$(substr($1,length($1)-2,length($1))" -le $v6) )
#                                  printf "%s; ", substr($1,1,length($1)-3) } '
#
#
#awk -F '-' ' {if ( $3 -ge $lowerLimitYear && $3 -le $greaterLimitYear );
#                              if ( $2 -ge $lowerLimitMonth && $2 -le $greaterLimitMonth );
#      if ( "$(substr($1,length($1)-2,length($1))" -ge $lowerLimitDay && "$(substr($1,length($1)-2,length($1))" -le $greaterLimitDay )
#                                  {$1= substr($1,1,length($1) )}} '
#
#awk -F '-'  '{print ${ if ( "$3" -ge $lowerLimitYear && "$3" -le $greaterLimitYear );
#                  else if ( $2 -ge $lowerLimitMonth && $2 -le $greaterLimitMonth );
#                  else if ( $(substr($1,length("$1")-2,length("$1")) -ge $lowerLimitDay && $(substr($1,length("$1")-2,length("$1")) -le $greaterLimitDay )}
#      } ' |
#
#
#awk -F"#" '{if($1==12)
#              print $1;
#           else if($3 == "google")
#             print $3;
#           else
#              print $0}' test-1.txt
##
#var=$2
#lend5= expr length $var
#echo $lend5

#lend=length($2)
#lend5= ${#strvar}
#print $(substr($1,1,length("$1")-2))}

#                      fi
#                    fi
#                   fi}

#a="21-12-1988"
#b="24-12-1988"
#
#
#
##a=5555454
##b=5555
##c= $(( (a>b) ? a : b ))
#
#
#
#
#
#
#    {print ""$2","substr($4,1,length($4)-4)""}
#
#    (( $2 > $dateFrom || $2 < $dateTo ? {print "$1"} : {print "$2"} ))'
#  done
#)
# #(( numVar == numVal ? (resVar=1) : (resVar=0) ))
#
#if ( "$b" -ge "$a" )
#then
#  echo "plati"
#fi

#| sort -n -t '-' -k3 -k2 -k1 | sort -n -t ','

#not working attempts

#
#date_sorted_list= $(print $allLogs | sort -n -t '-' -k3 -k2 -k1 )
#echo date_sorted_list

#$(sort -n -t '-' -k3 -k2 -k1 "$allLogs")
# concatenate of files in one stream
#doriešiť, aby to bolo robené ako begin v cykle nižšie

#
#for file in ${array(*)};
#do
#    array2=$(sed '1d' "$file")
#done

#awk -F ',' {'$4=substr($4,1,length($4)-4) "$array2(1)"};{print "$4"}'
#echo "$array2"

#
#for file in ${array(*)};
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
#              $1=mktime(date(3) " " date(2) " " date(1) " " "00 00 00");
#              print}' #| sort -n $1

#awk '{print $1.strftime("%d-%m-%Y")}' | awk '{print $1}'

#
#awk -F ',' '{$4=substr($4,1,length($4)-4) "$file2"}'; print "$4"  |
#    #sorting dates in files by year, month and day.
#    sort -t '-' -nk3 -nk2 -nk1; print






