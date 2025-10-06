pipeline {
    agent any

    environment {
        APP_NAME = "reactapp"
        IMAGE = "pavdev777/reactapp:latest" 
        NAMESPACE = "reactapp"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build React App') {
            steps {
                dir('./') {
                    sh '''
                    npm ci
                    npm run build
                    '''
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Сборка Docker-образа
                    sh "docker build -t ${IMAGE} ."

                    // Логин в DockerHub через Jenkins Credentials
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub_creds', 
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${IMAGE}
                        docker logout
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Используем kubeconfig из Jenkins credentials
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh '''
                        helm upgrade --install ${APP_NAME} ./reactapp/react \
                            --namespace ${NAMESPACE} \
                            --create-namespace \
                            --set image.repository=pavdev777/reactapp \
                            --set image.tag=latest
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}