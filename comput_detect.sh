#!/bin/bash
# Author: leib
# Time: 2020-9-1 21:18:43
# Name: comput_detect.sh
# Version: v1.0
# Description: Detect network segment computer

fun_ping(){
ping 192.168.4.$i -c 1 -w 1 2&>1 >/dev/null
if [ $? -eq 0 ]
then 
echo "192.168.4.$i active!"
else 
echo "192.168.4.$i down."
fi 
}
for i in {1..254}
do 
fun_ping
done
