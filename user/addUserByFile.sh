#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

cat /usr/local/userData | while read line
do
    if [[ $str == -* ]]; then
        echo $line
        array=(${line//|/ })
        for var in ${array[@]}
        do
            echo $var
        done
    fi
done
# python mujson_mgr.py -a -u $uname -p $uport -k $upass -m $um1 -O $ux1 -o $uo1 -t $ut -S $us -G $uparam
