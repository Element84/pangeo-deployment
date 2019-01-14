#!/bin/bash

###
# Note: This script expects an existing EKS cluster deployment
#
# This script performs the following actions:
#    1. Authorize EC2 instances with $WorkerNodeIAMRole to register as workers
#    2. Create an admin role binding
#    3. Set EBS (gp2) as the default StorageClass for the cluster
###

set -ex

EMAIL="andrew@element84.com"

Cluster="$1"
WorkerNodeIAMRole="$2"
KubeConfig=/tmp/kubeconfig

###
# Setup kubectl
###
aws eks update-kubeconfig --name ${Cluster} --kubeconfig ${KubeConfig}

###
# Allow worker nodes to register with EKS master
###
cat << EOF > /tmp/aws-auth-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${WorkerNodeIAMRole}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
EOF
kubectl apply -f /tmp/aws-auth-cm.yaml --kubeconfig ${KubeConfig}


kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=${EMAIL} --kubeconfig ${KubeConfig}

# Allow cluster to spin up GP2 EBS volumes for dynamic PV
kubectl create -f ../config/gp2-storage-class.yaml --kubeconfig ${KubeConfig}
kubectl patch storageclass gp2 \
      -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' \
      --kubeconfig ${KubeConfig}
