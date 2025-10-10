pipeline {
  agent any

  environment {      
    CHART_DIR = "helm-chart"
    HELM_MONITORING_RELEASE = "monitoring"
    S3_BUCKET = "my-terraform-outputs-bucket"
  }

  stages {
    stage('Load Environment from S3') {
      steps {
        withAWS(region: 'us-east-1', credentials: 'aws-cred') { 
          script {
            // determine the file to get the architecture info.
            def envFile
            if (env.BRANCH_NAME == 'main') {
              envFile = 'outputs/prod-outputs.json'
            } else if (env.BRANCH_NAME.startsWith('feature/')) {
              envFile = "outputs/dev-outputs.json"
            } else if (env.BRANCH_NAME.startsWith('test')) {
              envFile = "outputs/test-outputs.json"
            } else {
              envFile = "outputs/dev-outputs.json"
            }

            // Ddowload the s3 file
            sh "aws s3 cp s3://${S3_BUCKET}/${envFile} ./outputs.json"

            // read json file
            def jsonText = readFile('outputs.json')
            def outputs = readJSON text: jsonText

            env.KUBE_CLUSTER = outputs.cluster_name.value
            env.ECR_REGISTRY = outputs.ecr_repository_url.value
            env.AWS_REGION = outputs.aws_region.value

            env.IMAGE_TAG = env.BRANCH_NAME  // branch name is going to be the image tag name
            env.HELM_RELEASE = "python-api-${env.BRANCH_NAME}"  // helm release por ambiente
            env.K8S_NAMESPACE = env.BRANCH_NAME
          }
        }
      }
    }
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
        sh "docker build -t ${ECR_REGISTRY}:${IMAGE_TAG} ./app"
      }
    }

    stage('Push to ECR') {
      steps {
        sh "docker push ${ECR_REGISTRY}:${IMAGE_TAG}"
      }
    }
    stage('Validate AWS') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh 'aws --version'
          sh 'aws sts get-caller-identity'
          sh 'aws eks list-clusters'
        }
      }
    }

    stage('Deploy Monitoring Stack') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh """
            aws eks update-kubeconfig --region ${AWS_REGION} --name ${KUBE_CLUSTER}

            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
            helm repo update
            
            helm upgrade --install ${HELM_MONITORING_RELEASE} prometheus-community/kube-prometheus-stack \
              --namespace observability \
              --create-namespace \
              -f monitoring/values-monitoring.yaml
          """
        }
      }
    }
    stage('Deploy to EKS via Helm') {
      steps {
        withAWS(region: "${AWS_REGION}", credentials: 'aws-cred') {
          sh """
            aws eks update-kubeconfig --region ${AWS_REGION} --name ${KUBE_CLUSTER}

            helm upgrade --install ${HELM_RELEASE} ${CHART_DIR} \\
              -f ${CHART_DIR}/values.yaml \\
              --namespace ${K8S_NAMESPACE} \\
              --create-namespace \\
              --set image.repository=${ECR_REGISTRY} \\
              --set image.tag=${IMAGE_TAG} 
          """
        }
      }
    }
    
    
    
  }

  post {
    success {
      echo "Deploy successful"
    }
    failure {
      echo "Pipeline failed"
    }
  }
}
