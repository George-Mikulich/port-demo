#!/bin/bash

echo "Credentials are needed for External Secrets Operator"
for (( createSecretErrorCode=1; $createSecretErrorCode != 0 ; ))
do
        echo "Please specify full path to Service Account key (.json file)"
        read -r -p '(Default path is ../key.json): ' answer
        export fullpath="${answer:-../key.json}"
        kubectl create secret \
         generic gcp-secret \
         --namespace external-secrets \
         --from-file=creds=$fullpath
        createSecretErrorCode=$?
        if [ $createSecretErrorCode != 0 ]
        then
                echo "There is no such file, try again"
                echo
        fi
done