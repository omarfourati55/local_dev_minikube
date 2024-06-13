#!/bin/bash


#This script contains all needed for install infrastructure on our minikube cluster
#This script must be run successfully to the end, for install core-services on our cluster
#Edit this file, when new infrastructure is added, or infrastructure is removed

# Variables
NOCOLOR='\033[0m'
GREEN='\033[0;32m'

REDPANDA_VERSION="v2.1.17-23.3.11"

SLEEPING_TIME=120s

# redpanda-cluster path location variables
REDPANDA_CLUSTER_CONFIG="./redpanda-cluster.yaml"


Text_Green(){
  echo -e "${GREEN} $1 ${NOCOLOR}"
}



# ADD NEEDED HELM REPOS
helm repo add jetstack https://charts.jetstack.io
helm repo add redpanda https://charts.redpanda.com
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
minikube addons enable metrics-server


# INSTALL INFRASTRUCTURE
kubectl -n minikube rollout status deployment

# CERT-MANAGER
helm -n cert-manager install cert-manager jetstack/cert-manager --create-namespace --set crds.enabled=true
kubectl -n cert-manager rollout status deployment
kubectl -n cert-manager rollout status statefulset


# PROMETHEUS
helm -n monitoring install prometheus-stack prometheus-community/kube-prometheus-stack --create-namespace
kubectl -n monitoring rollout status deployment
kubectl -n monitoring rollout status statefulset

# REDPANDA (KAFKA)
kubectl create namespace redpanda-system
helm repo update
kubectl -n redpanda-system apply -k https://github.com/redpanda-data/redpanda-operator/src/go/k8s/config/crd?ref="$REDPANDA_VERSION"
helm -n redpanda-system install redpanda-operator redpanda/operator --create-namespace --set image.tag="$REDPANDA_VERSION"
helm repo update
kubectl -n redpanda-system rollout status deployment
kubectl -n redpanda-system rollout status statefulset

kubectl -n redpanda-system apply -f "$REDPANDA_CLUSTER_CONFIG"
sleep $SLEEPING_TIME
kubectl -n redpanda-system rollout status statefulset

