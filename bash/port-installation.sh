#!/bin/bash
# The following script will install a Port K8s integration

set -e
RED='\033[0;31m'
NC='\033[0m' # stands for 'No Color'

echo -e "${RED}WARNING! DON'T SKIP THIS MESSAGE!${NC}"
read -r -p "Type 'confirm' if port client is already installed: " confirmation
if [ $confirmation == 'confirm' ]
        then
                exit 12
                break
        fi

read -r -p 'Enter Port Client ID: ' CLIENT_ID
read -r -p 'Enter Port Client Secret: ' CLIENT_SECRET

echo
echo -e "${RED}please check spelling:${NC}"
echo "client ID: $CLIENT_ID"
echo "client secret: $CLIENT_SECRET"
echo
read -r -p "Type 'n' if something is wrong: " good
if [ $good == 'n' ]
        then
                echo 
                exit 39
                break
        fi

helm repo add port-labs https://port-labs.github.io/helm-charts
helm upgrade --install miniport port-labs/port-k8s-exporter \
 --namespace port-k8s-exporter \
        --set secret.secrets.portClientId="$CLIENT_ID"  \
        --set secret.secrets.portClientSecret="$CLIENT_SECRET"  \
        --set portBaseUrl="https://api.getport.io"  \
        --set stateKey="miniport"  \
        --set integration.eventListener.type="POLLING"  \
        --set "extraEnv[0].name"="minikube"  \
        --set "extraEnv[0].value"="miniport" \
      --set createDefaultResources=false