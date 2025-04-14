1. Helm reconhecer repositorio eks. Solução: adicionar o repositório do EKS Charts
helm repo add eks https://aws.github.io/eks-charts
helm repo update

2. Baixar o AWS LoadBalancer Controller 
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=vpc-098b5b4e19b35be8f -n kube-system
