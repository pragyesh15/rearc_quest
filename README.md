Problem Statement
=================

- Deploy the app in a container in any public cloud using the services you think best solve this problem.
- Use Node as the base image. Version node:10 or later should work.
- Navigate to the index page to obtain the SECRET_WORD.
- Inject an environment variable (SECRET_WORD) in the Docker container using the value on the index page.
- Deploy a load balancer in front of the app.
- Add TLS (https). You may use locally-generated certs.


Technical Specification
=======================

 - **Cloud Provider** : AWS
 - **AWS Services** : EKS, Loadbalancer
 - **Infrastructure as code** : Terraform
 - **Containerization** : Docker
 - **Container Orchestration** : Kubernetes
 - **Version Control** : Git
 - **Container Registry** : DockerHub





