# pangeo-deployment
Baseline deployment helpers for Pangeo on AWS

This project deploys a base Kubernetes stack, and a Pangeo BinderHub on top of it. It creates minimally permissive IAM roles and profiles, sets up a secured VPC, deploys an EKS cluster, and deploys worker nodes to that cluster. Then, BinderHub is deployed in the environment via helm.

## Deploying

To deploy the base cluster, use the `bin/deploy` command. 

*Note:* This command assumes you've uploaded the templates in `cfn-templates/` to S3. That S3 location is referenced in the `deploy` script.

To deploy the binderhub, run:

```
$ bin/configure_tiller.sh
$ bin/deploy_pangeo.sh
```

*Note:* Make sure you are running as an AWS user with proper credentials and permissions. I also recommend you use the `AWS_DEFAULT_REGION` environment variable.

