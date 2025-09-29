pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"           
    ECR_REGISTRY =  "463470979148.dkr.ecr.us-east-1.amazonaws.com"
    ECR_REPO = "python-api-repo"
    IMAGE_TAG = "deploy"
    CHART_DIR = "helm/python-api"
    KUBE_CLUSTER_NAME = "my-eks-cluster" 
  }

  stages {
    stage('Build Docker Image') {
            steps {
                sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ./app"
            }
        }
        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
                    ecrLogin(region: 'us-east-1')  // login al registro ECR
                    sh "docker tag ${ECR_REPO}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
                    sh "docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }
  
    
  }

  post {
    success {
      echo "Deploy successful: ${ECR_REPO}:${IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
