#!/bin/bash

# uninstalling as required in official Crossplane documentation:
# https://docs.crossplane.io/latest/software/uninstall/

# Crossplane

kubectl get xrds -oname | xargs kubectl delete

kubectl get managed -oname | xargs kubectl delete

kubectl get providers -oname | xargs kubectl delete

helm uninstall crossplane --namespace crossplane-system
kubectl delete namespace crossplane-system

# External Secrets Operator

helm uninstall external-secrets --namespace external-secrets
kubectl delete namespace external-secrets

# is this needed?
#kubectl get crd -oname | grep --color=never 'upbound.io' | xargs kubectl delete
#kubectl get crd -oname | grep --color=never 'crossplane.io' | xargs kubectl delete