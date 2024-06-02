pipeline {

  agent any

   environment {
      GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-deployer')
      PROJECT_ID = 'level-ward-423317-j3'
      VERSION = "${env.BUILD_NUMBER}"
      DEPLOYMENT_FILE_BACKEND  = 'k8s/frontend-todolist-deployment.yml'
      SERVICE_FILE_BACKEND  = 'k8s/frontend-todolist-service.yml'
      MYSQL_FILE_DEPLOYMENT = 'k8s/mysql-deployment.yml'
      MYSQL_FILE_SERVICE = 'k8s/mysql-service.yml'
      MYSQL_FILE_PVC = 'k8s/mysql-pvc.yml'
      CLUSTER_NAME = 'lab-cluster'
      CLUSTER_LOCATION = 'us-west1-c'
      CLUSTER_LOCATION_REGISTRY = 'us-west1-docker'
      CREDENTIALS_KUBE_PLUGIN_ID = 'sa-kubectl'
      IMAGE_NAME_BACKEND = 'todo-list-devops-backend'
      REPO_NAME_BACKEND = 'todo-list-devops-backend'
  }

  stages {
    stage('Check gcloud installation') {
      steps {
        sh 'gcloud version'
      }
    }
    stage('Authenticate to GCP') {
      steps {
          script {
              withCredentials([file(credentialsId: 'gcp-deployer', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                  sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                  sh 'gcloud config set project $PROJECT_ID'
              }
          }
      }
    }
    stage('Build Docker Images') {
      steps {sh "docker build -t ${IMAGE_NAME_BACKEND}:latest .  -f Dockerfile --network=host"
      }
    }
    stage('Tag Docker Images') {
      steps {
          sh "docker tag ${IMAGE_NAME_BACKEND}:latest ${IMAGE_NAME_BACKEND}:${VERSION}"       
          sh "docker tag ${IMAGE_NAME_BACKEND}:${VERSION} ${CLUSTER_LOCATION_REGISTRY}.pkg.dev/${PROJECT_ID}/${REPO_NAME_BACKEND}/${IMAGE_NAME_BACKEND}:${VERSION}"
      }
    }
    stage('Push images') {
      steps {
          sh "gcloud auth configure-docker ${CLUSTER_LOCATION_REGISTRY}.pkg.dev"
          sh "docker push ${CLUSTER_LOCATION_REGISTRY}.pkg.dev/${PROJECT_ID}/${REPO_NAME_BACKEND}/${IMAGE_NAME_BACKEND}:${VERSION}"        
      }
    }
    stage('Update Deployment YAML') {
      steps {
          script {
            sh "sed -i 's|PLACEHOLDER_IMAGE_VERSION|${VERSION}|g' ${DEPLOYMENT_FILE_BACKEND}"
          }
      }
    }
    stage('Validate Deployment YAML') {
      steps {
          script {
              sh "cat ${DEPLOYMENT_FILE_BACKEND}"
          }
      }
    }
    stage('Deploy mysql pvc to kubernetes'){
      steps{
          step([
            $class: 'KubernetesEngineBuilder', 
            projectId: env.PROJECT_ID, 
            clusterName: env.CLUSTER_NAME, 
            location: env.CLUSTER_LOCATION, 
            manifestPattern: env.SERVICE_FILE_BACKEND, 
            credentialsId: env.CREDENTIALS_KUBE_PLUGIN_ID,
            verifyDeployments: true])
		   echo "Deployment to mysql pvc Finished ..."
      }
    }
    stage('Deploy mysql deployment to kubernetes'){
      steps{
          step([
            $class: 'KubernetesEngineBuilder', 
            projectId: env.PROJECT_ID, 
            clusterName: env.CLUSTER_NAME, 
            location: env.CLUSTER_LOCATION, 
            manifestPattern: env.SERVICE_FILE_BACKEND, 
            credentialsId: env.CREDENTIALS_KUBE_PLUGIN_ID,
            verifyDeployments: true])
		   echo "Deployment to mysql deployment Finished ..."
      }
    }
    stage('Deploy mysql service to kubernetes'){
      steps{
          step([
            $class: 'KubernetesEngineBuilder', 
            projectId: env.PROJECT_ID, 
            clusterName: env.CLUSTER_NAME, 
            location: env.CLUSTER_LOCATION, 
            manifestPattern: env.SERVICE_FILE_BACKEND, 
            credentialsId: env.CREDENTIALS_KUBE_PLUGIN_ID,
            verifyDeployments: true])
		   echo "Deployment to mysql service Finished ..."
      }
    }
    stage('Deploy backend deployment to kubernetes'){
      steps{
          step([
            $class: 'KubernetesEngineBuilder', 
            projectId: env.PROJECT_ID, 
            clusterName: env.CLUSTER_NAME, 
            location: env.CLUSTER_LOCATION, 
            manifestPattern: env.DEPLOYMENT_FILE_BACKEND, 
            credentialsId: env.CREDENTIALS_KUBE_PLUGIN_ID,
            verifyDeployments: true])
		   echo "Deployment to backend deployment Finished ..."
      }
    }
    stage('Deploy backend service to kubernetes'){
      steps{
          step([
            $class: 'KubernetesEngineBuilder', 
            projectId: env.PROJECT_ID, 
            clusterName: env.CLUSTER_NAME, 
            location: env.CLUSTER_LOCATION, 
            manifestPattern: env.SERVICE_FILE_BACKEND, 
            credentialsId: env.CREDENTIALS_KUBE_PLUGIN_ID,
            verifyDeployments: true])
		   echo "Deployment to backend service Finished ..."
      }
    }
  }
}