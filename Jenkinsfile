pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"           
    ECR_REPO = "463470979148.dkr.ecr.us-east-1.amazonaws.com/python-api-repo"    
    IMAGE_NAME = "api"    
    IMAGE_TAG = "deploy"
    CHART_DIR = "helm/python-api"
    KUBE_CLUSTER_NAME = "my-eks-cluster" 
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker image') {
      steps {
        sh 'docker --version || true'
        sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO%%/*}
          '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'
      }
    }

    stage('Update kubeconfig') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            aws eks update-kubeconfig --name ${KUBE_CLUSTER_NAME} --region ${AWS_REGION}
            kubectl version --client
            helm version
          '''
        }
      }
    }

    stage('Helm deploy') {
      steps {
        sh """
          helm upgrade --install python-api ${CHART_DIR} \
            --set image.repository=${IMAGE_NAME} \
            --set image.tag=${IMAGE_TAG} \
            --wait --timeout 5m
        """
      }
    }
  }

  post {
    success {
      echo "Deploy successful: ${IMAGE_NAME}:${IMAGE_TAG}"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
