
aws eks update-kubeconfig --region us-east-1 --name ez-frame-generator-dev-cluster

kubectl get pods -n kube-system

kubectl delete pod -n kube-system -l k8s-app=kube-dns

kubectl describe pod coredns-6b9575c64c-bvrhq -n kube-system

kubectl get pods -n kube-system | findstr aws-load-balancer

helm list -n kube-system


aws eks list-fargate-profiles --cluster-name ez-frame-generator-dev-cluster


kubectl describe pod coredns-6b9575c64c-p8kj2 -n ez-frame-generator-namespace

kubectl get ingress -n ez-frame-generator-namespace

kubectl get ingress -n ez-frame-generator-namespace

CHECK PODS AND SERVICE:
kubectl get pods -n ez-frame-generator-namespace -o wide
kubectl get svc -n ez-frame-generator-namespace
kubectl logs ez-video-ingestion-ms-deployment-5b6b89bb7f-5bd4p -n ez-frame-generator-namespace
kubectl get ingress -n ez-frame-generator-namespace

kubectl delete pod ez-video-ingestion-ms-deployment-5647689547-k7prs -n ez-frame-generator-namespace

kubectl rollout restart deployment ez-video-ingestion-ms-deployment -n ez-frame-generator-namespace


kubectl apply -f C:\THAYNARA_DEV\workspaces\ez-video-ingestion-ms\k8s\ingress.yaml


1. Helm reconhecer repositorio eks. Solução: adicionar o repositório do EKS Charts
helm repo add eks https://aws.github.io/eks-charts
helm repo update

2. Baixar o AWS LoadBalancer Controller 
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=vpc-02de13728b68edc02 -n kube-system
## SEGUNDA TENTATIVA
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=vpc-02de13728b68edc02 -n kube-system


## TERCEIRA TENTATIVA
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller --set region=us-east-1 --set vpcId=vpc-02de13728b68edc02 --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller -n kube-system

helm uninstall aws-load-balancer-controller -n kube-system

# QUARTA TENTATIVA
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller --set clusterName=ez-frame-generator-dev-cluster --set region=us-east-1 --set vpcId=vpc-02de13728b68edc02 --set serviceAccount.create=true --set image.repository=602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller -n kube-system

