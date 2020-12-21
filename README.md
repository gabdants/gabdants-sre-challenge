# remessa-sre-challenge

In this repo you will find a IaaC solution to create a EKS Cluster and Network resources using Terraform.
The repository is divided in two modules: EKS Cluster and VPC.

- EKS CLuster
Here lies the code to create a EKS Cluster with the evironment based on the terraform workspaces. The cluster includes: The main cluster, A Node Group attached to the main cluster (Only 1 node, a t3-large ec2 machine) and 3 different AZ subnets for the cluster.

- VPC
On this module, I'm creating the VPC and some network resources that are the base of everything that will be built on top of it. My idea was to create more resources over the infrastructure, but I wanted to keep it simple and directly to the point.

Obs: Nothing is created right now, I don't want to pay more than I already payed haha, buuut I created an output log that proves that the cluster and the network resources were created correctly. (Proof of that is that the remessa-app was deployed on the other repo using GH Actions as a simple CI/CD tool)
