#!/bin/bash

# BASH CONFIG VARIABLES
BLUE='\033[1;34m'
RED='\033[0;31m'
NOCOLOR='\033[0m'
GREEN='\033[0;32m'
DARK_GREY='\033[1;30m'
MIN_MEMORY_REQUIRED=8120
MIN_CORES_REQUIRED=8
AVAILABLE_MEMORY=0
AVAILABLE_CORES=0


# VARIABLES
USE_KUBERNETES_VERSION=1.30.0

# Functions
Text_Red () {
  echo -e "${RED} $1 ${NOCOLOR}"
}

Text_Green(){
  echo -e "${GREEN} $1 ${NOCOLOR}"
}

Text_Blue(){
  echo -e "${BLUE} $1 ${NOCOLOR}"
}

Text_Dark_Grey(){
  echo -e "${DARK_GREY} $1 ${NOCOLOR}"
}

# Check Available Resources on Current Laptop
Check_Resources() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    AVAILABLE_MEMORY=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    AVAILABLE_CORES=$(grep -c ^processor /proc/cpuinfo)
    AVAILABLE_MEMORY=$((AVAILABLE_MEMORY / 1024)) # convert from KB to MB
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    AVAILABLE_MEMORY=$(sysctl -n hw.memsize)
    AVAILABLE_CORES=$(sysctl -n hw.ncpu)
    AVAILABLE_MEMORY=$((AVAILABLE_MEMORY / 1024 / 1024)) # convert from bytes to MB
  else
    Text_Red "Unsupported OS. This script supports Linux and macOS only."
    exit 1
  fi

  if [[ AVAILABLE_MEMORY -ge MIN_MEMORY_REQUIRED ]] && [[ AVAILABLE_CORES -ge MIN_CORES_REQUIRED ]]; then
    Text_Green "Sufficient resources available: ${AVAILABLE_MEMORY} MB memory, ${AVAILABLE_CORES} cores."
    return 0
  else
    Text_Red "Insufficient resources: ${AVAILABLE_MEMORY} MB memory, ${AVAILABLE_CORES} cores."
    exit 1
  fi
}

# CHECK NEEDED PROGRAMS
Check_Is_Installed(){
if ! command -v "$1" >/dev/null; then
  Text_Red "This script requires {$1} to be installed and on your PATH ..."
  exit 1
fi
}

# minikube
Check_Is_Installed 'minikube'
# helm
Check_Is_Installed 'helm'
# kubectl
Check_Is_Installed 'kubectl'
# git
Check_Is_Installed 'git'


# Start installation
Text_Green "Welcome, this script install minikube with everything needed"
Text_Green "     this should be finished in 3 minutes "

# Check resources
Check_Resources

# build minikube
Text_Blue "  -----> start build cluster "
minikube start --kubernetes-version="$USE_KUBERNETES_VERSION" --driver=docker --static-ip="10.10.10.10"

minikube status

Text_Green "--- minikube created"

Text_Blue "  ------> start install infrastructure on minikube "
Text_Blue "  ------> this take up to 2 minutes"



# INSTALL INFRASTRUCTURE
./install_infrastructure.sh