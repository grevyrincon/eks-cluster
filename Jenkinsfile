pipeline {
  agent {
        docker {
            image 'amazon/aws-cli:2.14.10'  // ya incluye aws cli
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

  environment {
    AWS_REGION = "us-east-1"           
    ECR_REGISTRY =  "463470979148.dkr.ecr.us-east-1.amazonaws.com"
    ECR_REPO = "python-api-repo"
    IMAGE_TAG = "deploy"
    CHART_DIR = "helm/python-api"
    KUBE_CLUSTER_NAME = "my-eks-cluster" 
  }

  stages {
    stage('Login to ECR') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh '''
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
          '''
        }
      }
    }
    stage('Build Docker image') {
      steps {
        sh "docker build -t ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG} ./app"
      }
    }

    stage('Push to ECR') {
      steps {
        sh "docker push ${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
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
