# kind-k8s
This repo contains template for Kind and k8s ref project deployments

---

#### Create a KIND cluster and deploy and expose a simple API using Node Port
* Install kind and docker desktop in your local machine: https://kind.sigs.k8s.io/
* Create a KIND cluster, single control-plane and single worker. Run command ``` kind create cluster --config <nameOfTheFileWithBelowContent>.yml```
  * ```yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
    - role: worker
      # port forward 80 on the host to 80 on this node
      extraPortMappings:
        - containerPort: 30950
          hostPort: 80
          # optional: set the bind address on the host
          # 0.0.0.0 is the current default
          listenAddress: "127.0.0.1"
          # optional: set the protocol to one of TCP, UDP, SCTP.
          # TCP is the default
          protocol: TCP
     ```
* This will create the Cluster in your local machine.
* Check if kubectl is configured to the right context by running: ```kubectl cluser-info ```
* Create a deployment file with below content and run ```kubectl apply -f <nameOfTheFileWithBelowContent>.yml ```
 ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: backend
    spec:
      selector:
        matchLabels:
          app: hello
          tier: backend
      replicas: 1
      template:
        metadata:
          labels:
            app: hello
            tier: backend
        spec:
          containers:
            - name: hello
              image: "gcr.io/google-samples/hello-go-gke:1.0"
              ports:
                - name: http
                  containerPort: 80
                  hostPort: 80
```
* Create a service with below content and run ```kubectl apply -f <nameOfTheFileWithBelowContent>.yml ```
```yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: hello
  spec:
    type: NodePort
    selector:
      app: hello
      tier: backend
    ports:
      - protocol: TCP
        port: 80
        nodePort: 30950 # this should be exactly the same what is present in the kind-cluster.yml file value under   extraPortMappings:- containerPort: 30950
        targetPort: http
```
* Hit, localhost:80 should see:  
```json
{"message":"Hello"}
```

#### Deploy the K8s default Dashboard
* Follow links: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
* Follow Links: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
* Steps to follow:
  * Run command: ```kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/rec```
  * This will deploy the dashboard in new namespace named dashboard-k8s 
  * Create user using the link: https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
    * Create a new yml file like this: (dashboard-adminuser.yml)[backendservice-deploy-nodeport/dashboard-adminuser.yml]
    * Run ```kubectl apply -f backendservice-deploy-nodeport/dashboard-adminuser.yml```
    * This will create user access
    * Then get the token by running: ```kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"```
    * you will get the token, copy it
    * Run, ```kubectl proxy```; this will start the dashboard
    * Go to link in your browser: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
    * It will ask for token, enter the token generated from previous Step.