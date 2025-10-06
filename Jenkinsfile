pipeline {
    agent any

    environment {
        IMAGE_NAME = "pavdev777/reactapp"
        KUBE_CONFIG = credentials('kubeconfig') // kubeconfig Secret File
        HELM_RELEASE = "reactapp"
        HELM_CHART_PATH = "react" // путь к helm-чарту
        NAMESPACE = "reactapp"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/PavDev777/react-app.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci' // быстрее и стабильнее, чем npm install
            }
        }

        stage('Run Tests') {
            steps {
                echo 'Running Jest tests...'
                // Jest завершится ошибкой, если хоть один тест упадет
                sh 'npm test -- --watchAll=false'
            }
        }

        stage('Build React App') {
            steps {
                echo 'Building React production build...'
                sh 'npm run build'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                echo "Building Docker image..."
                docker build -t $IMAGE_NAME .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub_creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push $IMAGE_NAME:latest
                    docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes via Helm') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                    export KUBECONFIG=$KUBECONFIG_FILE
                    helm upgrade --install $HELM_RELEASE $HELM_CHART_PATH \
                        --namespace $NAMESPACE \
                        --create-namespace \
                        --set image.repository=$IMAGE_NAME \
                        --set image.tag=latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Tests passed and deployment completed successfully!"
        }
        failure {
            echo "❌ Build, tests, or deployment failed."
        }
    }
}