#!/bin/sh
echo "------------1. Creating KIND Cluster-------------"
kind create cluster --config deploy-with-ingress/kind-cluster-with-ingress.yml
echo kubectl cluster-info

echo "------------2. Deploy Nginx Ingress Controller-------------"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "------------3. Wait for Ngnix Controller to be up and running-------------"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

wait

echo "------------6. Install Dashboard-------------"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml

echo "------------7. Install Dashboard User Service Accounts-------------"
kubectl apply -f deploy-with-ingress/dashboard-user-account.yml
wait

echo "------------4. Deploy the app-------------"
kubectl apply -f deploy-with-ingress/deployment.yml

echo "------------5. Get Deployments-------------"
kubectl get deployments 

echo "Port Forwarding"
kubectl port-forward bar-app 8009:5678

echo "------------8. Dashboard Get Secret Token-------------"
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

echo "------------9. Open Below URL and enter the token below-------------"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

echo "------------10. Run the Proxy------------"
kubectl proxy 

