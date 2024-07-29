#!/bin/bash

set -e

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
 --namespace crossplane-system

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
kubectl apply -f external-secrets-operator/crossplane-key.yaml \
 --namespace external-secrets


kubectl apply -f crossplane/gcp/provider.yaml
sleep 5
kubectl wait --for=condition=healthy provider.pkg.crossplane.io \
 --all --timeout=1000s

kubectl apply -f crossplane/gcp/provider-config.yaml
kubectl apply -f crossplane/compositions/xrd.yaml

chmod +x ./bash/for-loop.sh
./bash/for-loop.sh crds 2

kubectl apply -f crossplane/compositions/composition.yaml
sleep 3

# final step
# commented for port
# kubectl apply -f crossplane/compositions/gke.yaml

chmod +x destroy.sh