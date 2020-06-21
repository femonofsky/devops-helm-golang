# Golang and Kubernetes using helm 

Helm is the package manager for Kubernetes 
![test and build GO](https://github.com/femonofsky/devops-helm-golang/workflows/test%20and%20build%20GO/badge.svg?branch=master)

## Installation 


The Kubernetes command-line tool, [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) , allows you to run commands against Kubernetes clusters. You can use kubectl to deploy applications, inspect and manage cluster resources, and view logs.
######  For kubectl
```bash
brew install kubectl
```

Use the package manager [helm](https://helm.sh/docs/intro/install/) to deploy. 
######  For helm
```bash
brew install helm
```

Install [minikube](https://minikube.sigs.k8s.io/docs/start/) to test locally
######  For minikube
```bash
brew install minikube
```



## Usage

steps in running application locally [minikube](https://minikube.sigs.k8s.io/docs/)
- ##### start minikube with two nodes and check minikube status  
```bash
minikube start --nodes 2 -p multinode-demo
kubectl get nodes
minikube status
```
- #### label the nodes
```bash
kubectl label node minikube env=development
kubectl label node minikube-m02 env=production
```

### for development(staging) environment

- ### build docker image
```bash
 ./run_docker.sh development 8080  
or  
make docker-build app_env=development app_port=8080
```

- ### run docker container
```bash
docker run -p 8080:8080 web-app-development  
or
make docker-run app_env=development app_port=8080
```
- ### push docker to registry
```bash 
./upload_docker.sh development 
or
make docker-push  app_env=development
```
NB:
This will push to my docker hub registry:
https://hub.docker.com/repository/docker/nofsky/web-app-development

- ###  deploy to Kubernetes cluster using helm
```bash
helm install development ./web-app 
```



### for production(master branch) environment

- ### build docker image
```bash
 ./run_docker.sh production 8080  
or  
make docker-build app_env=production app_port=8080
```

- ### run docker container
```bash
docker run -p 8080:8080 web-app-production  
or
make docker-run app_env=production app_port=8080
```
- ### push docker to registry
```bash 
./upload_docker.sh production 
or
make docker-push  app_env=production
```
NB:
This will push to my docker hub registry:
https://hub.docker.com/repository/docker/nofsky/web-app-development

- ###  deploy to Kubernetes cluster using helm
```bash
helm install production ./web-app  -f ./web-app/prod-values.yaml 
```


## References
- https://golang.org/
- https://www.docker.com/
- https://helm.sh/
- https://kubernetes.io/
- https://minikube.sigs.k8s.io/docs/
