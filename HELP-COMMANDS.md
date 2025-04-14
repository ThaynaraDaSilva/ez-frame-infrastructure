
aws eks update-kubeconfig --region us-east-1 --name ez-frame-generator-dev-cluster

kubectl get pods -n kube-system

kubectl delete pod -n kube-system -l k8s-app=kube-dns

kubectl describe pod coredns-6b9575c64c-p8kj2 -n kube-system

kubectl get pods -n kube-system | findstr aws-load-balancer

helm list -n kube-system


aws eks list-fargate-profiles --cluster-name ez-frame-generator-dev-cluster


kubectl describe pod coredns-6b9575c64c-p8kj2 -n ez-frame-generator-namespace



1. Helm reconhecer repositorio eks. Solução: adicionar o repositório do EKS Charts
helm repo add eks https://aws.github.io/eks-charts
helm repo update

2. Baixar o AWS LoadBalancer Controller 
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=vpc-098b5b4e19b35be8f -n kube-system
## SEGUNDA TENTATIVA
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=vpc-098b5b4e19b35be8f -n kube-system
