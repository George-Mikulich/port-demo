#!/bin/bash

# for loop for waiting
# usage:
# arg1=resource<plural>, defaults to 'pods'
# arg2=number of resources to wait, defaults to '1'
# arg3=namespace, defaults to 'default'


set -e

for (( ; ; ))
do
        sleep 1
        number=$(kubectl get ${1:-pods} --namespace ${3:-default} | grep guga-api.com | wc -l)
        if [ $number == ${2:-1} ]
        then
                echo "all ${1:-pods} are ready"
                break
        fi
done