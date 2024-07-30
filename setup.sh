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

sleep 5
kubectl wait --for=condition=Ready pod \
 -l app=crossplane \
 --namespace crossplane-system \
 --timeout=180s

helm repo add external-secrets \
 https://charts.external-secrets.io

helm install \
 external-secrets \
 external-secrets/external-secrets \
 --namespace external-secrets \
 --create-namespace

chmod +x ./bash/ask-key.sh
./bash/ask-key.sh

sleep 5
kubectl wait --for=condition=Ready pod \
 -l app.kubernetes.io/instance=external-secrets \
 --namespace external-secrets \
 --timeout=180s

sleep 3
kubectl apply -f external-secrets-operator/secret-store.yaml
sleep 3
kubectl apply -f external-secrets-operator/crossplane-key.yaml


kubectl apply -f crossplane/gcp/provider.yaml
sleep 5
kubectl wait --for=condition=healthy provider.pkg.crossplane.io \
 --all --timeout=1000s

kubectl apply -f crossplane/gcp/provider-config.yaml
kubectl apply -f crossplane/compositions/xrd.yaml

chmod +x ./bash/for-loop.sh
./bash/for-loop.sh crds 2 "guga-api.com"

kubectl apply -f crossplane/compositions/composition.yaml
sleep 3

# simple approach :
# kubectl apply -f crossplane/compositions/gke.yaml

chmod +x ./bash/port-installation.sh

for (( exitCode=39; $exitCode == 39 ; ))
do
        ./bash/port-installation.sh
        exitCode=$?
done

helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd \
--namespace argocd \
--create-namespace argo/argo-cd \
--version 7.1.1

kubectl apply -f argocd/app.yaml

chmod +x destroy.sh