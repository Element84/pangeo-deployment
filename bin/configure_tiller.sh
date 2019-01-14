#! /bin/bash

Cluster="$1"
KubeConfig=/tmp/kubeconfig

# Configure kubectl
aws eks update-kubeconfig --name ${Cluster} --kubeconfig ${KubeConfig}

# Set up helm/tiller
kubectl create serviceaccount tiller --namespace=kube-system --kubeconfig ${KubeConfig}
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller --kubeconfig ${KubeConfig}
helm init --service-account tiller
kubectl --namespace=kube-system patch deployment tiller-deploy --type=json \
      --patch='[{"op": "add", "path": "/spec/template/spec/containers/0/command", "value": ["/tiller", "--listen=localhost:44134"]}]' \
      --kubeconfig ${KubeConfig}
