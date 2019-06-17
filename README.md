# Jenkins

CX Cloud can be configured to use Jenkins for continues integration and continues delivery/deployment. Other services like SonarQube can also easily be used as a part of the pipeline to enforce the quality of the projects.

## Jenkins Dockerfile

Jenkins for CX Cloud is meant to run on a Kubernetes clusters. The docker image contains all jobs and plugins for Jenkins to operate with CX Cloud CI/CD pipelines.

Have a look at the [jenkins-master docker file](dockerfiles/jenkins-master/Dockerfile).

### Worker Dockerfile

The Jenkins image is installed with the Kubernetes plugin, hence it is possible to choose to run the jobs in worker pods that gets automatically terminated after finishing the job. The docker image for the worker have all pipeline dependencies installed for executing the CI/CD pipelines.

Have a look at the [cxcloud-worker docker file](dockerfiles/cxcloud-worker/Dockerfile).

## Building the images

There is a helper script for automatically building and pushing the docker images to AWS ECR. The scrip take the following parameters.

| Option | Description | Type | Default|
| --- | --- | --- | --- |
| -t | Docker image name and tag in the 'name:tag' format | String | Not set |
| -r | AWS ECR Repository | String | Not Set |
| -p | Push to registry | Boolean | false |
| -a | AWS Profile | String | Not set |
| -n | Build Docker image with flag --no-cache | Boolean | false |

### Build Jenkins master image

Update the [jenkins-master Dockerfile](dockerfiles/jenkins-master/Dockerfile) (first line) with the preferred Jenkins version. Have a look in the Jenkins [changelog](https://jenkins.io/changelog/) in order to find the latest Jenkins version.

Run the following command in order to build and push to the registry a Jenkins master image (redefine variables and image tag):

```sh
dockerfiles/build.sh -p true -r 012345678901.dkr.ecr.eu-west-1.amazonaws.com -t jenkins-master:0.1.0-v2.180
```

### Build Jenkins worker image

Run the following command in order to build and push to the registry a CX Cloud Jenkins worker image (redefine variables and image tag):

```sh
dockerfiles/build.sh -p true -r 012345678901.dkr.ecr.eu-west-1.amazonaws.com -t cxcloud-worker:0.1.0
```

## Installing Jenkins

The official Jenkins Helm chart is used for installing Jenkins to the Kubernetes clusters. However, before the helm chart can be installed some other Kubernetes templates for rbac and persistent storage need to be installed.

```sh
kubectl create namespace ci
kubectl apply -f helm/sc.yaml
kubectl apply -f helm/pvc.yaml
kubectl apply -f helm/rbac.yaml
```

Installing Jenkins to the Kubernetes cluster (redefine Docker image tags and other variables)

```sh
helm install --name jenkins --namespace ci -f ./helm/values.yaml stable/jenkins \
  --set Master.Image=012345678901.dkr.ecr.eu-west-1.amazonaws.com/jenkins-master \
  --set Master.ImageTag=0.1.0-v2.180 \
  --set Agent.Image=012345678901.dkr.ecr.eu-west-1.amazonaws.com/cxcloud-worker \
  --set Agent.ImageTag=0.1.0 \
  --set Master.HostName=int-jenkins.cxcloud.com
```

### Jenkins credentials

In order to run the CI/CD pipelines Jenkins need three configured credentials. The table show needed credentials.

| ID | Description | Kind |
| --- | --- | --- |
| jenkins-cli | Jenkins CLI Token | Username with password |
| notify-flowdock | Notify Flowdock channel | Secret text |
| cxcloud-git | GitHub API Token | Username with password |

**Note** by using the CX Cloud demo pipeline the IDs has to be exactly named as in the table or the pipelines will not successfully run.

## Maintaining Jenkins

Jenkins should run inside a private network. Jenkins should only be accessable with an VPN connection or jumping server. However, it is still a good practice constantly upgrade Jenkins with plugins. There are four Jenkins jobs for exporting/importing Jenkins plugins and configured jobs to version control.

- Export Jobs, export all the configured jobs to VCS, GitHub
- Export Plugins, export all the installed plugins (with version information) to VCS, GitHub
- Import Jobs, import all the jobs that is under version control
- Import Plugins, imports all plugins (with version information) that is under version control

Jenkins and the worker should also regularly be upgraded with the building jenkins image steps above in this document.

The Jenkins pod can be upgraded with the following commands (redefine variables and image tag):

```sh
helm upgrade jenkins -f ./helm/values.yaml stable/jenkins \
  --set Master.Image=012345678901.dkr.ecr.eu-west-1.amazonaws.com/jenkins-master \
  --set Master.ImageTag=0.2.0-v2.181 \
  --set Agent.Image=012345678901.dkr.ecr.eu-west-1.amazonaws.com/cxcloud-worker \
  --set Agent.ImageTag=0.2.0 \
  --set Master.HostName=int-jenkins.cxcloud.com
```
