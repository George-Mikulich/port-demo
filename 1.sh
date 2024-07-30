#!/bin/bash

chmod +x ./bash/port-installation.sh

for (( exitCode=39; $exitCode == 39 ; ))
do
        ./bash/port-installation.sh
        exitCode=$?
done
