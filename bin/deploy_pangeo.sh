#!/bin/bash

set -e

helm repo add pangeo https://pangeo-data.github.io/helm-chart/
helm repo update

helm install pangeo/pangeo --version=0.1.1-69b4a02 --namespace=pangeo --name=jupyter \
     -f ../config/secret_config.yaml -f ../config/jupyter_config.yaml
