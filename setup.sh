#!/bin/bash

#set -e

kubectl config use-context minikube

helm repo add \
crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane \
--version 1.15.0

kubectl wait --for=condition=Ready pod -l app=crossplane -n crossplane-system

helm repo add external-secrets \
    https://charts.external-secrets.io

helm install \
    external-secrets \
    external-secrets/external-secrets \
    --namespace external-secrets \
    --create-namespace

echo "Credentials are needed for external secrets (all other secrets will be managed by ESO)"
for (( createSecretErrorCode=1; $createSecretErrorCode != 0 ; ))
do
        echo "Please specify full path to Service Account key (.json file)"
        read -r -p '(Default path is ../key.json): ' answer
        export fullpath="${answer:-../key.json}"
        kubectl create secret \
        generic gcp-secret \
        -n external-secrets \
        --from-file=creds=$fullpath
        createSecretErrorCode=$?
        if [ $createSecretErrorCode != 0 ]
        then
                echo "There is no such file, try again"
                echo
        fi
done

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=external-secrets -n external-secrets

sleep 3
kubectl apply -f external-secrets-operator/secret-store.yaml
sleep 3
kubectl apply -f external-secrets-operator/crossplane-key.yaml -n crossplane-system


kubectl apply -f crossplane/gcp/provider.yaml
kubectl wait --for=condition=healthy provider.pkg.crossplane.io --all

kubectl apply -f crossplane/gcp/provider-config.yaml
kubectl apply -f crossplane/compositions/xrd.yaml

chmod +x bash/for-loop.sh
./bash/for-loop.sh crds 2

kubectl apply -f crossplane/compositions/composition.yaml
sleep 3

kubectl apply -f gke.yaml

