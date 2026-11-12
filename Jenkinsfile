pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '332730082659'

        DOCKERHUB_BACKEND = 'shahzaibazeem/rent-a-ride-backend'
        DOCKERHUB_FRONTEND = 'shahzaibazeem/rent-a-ride-frontend'

        ECR_REGISTRY = '332730082659.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_BACKEND = 'rent-a-ride-backend'
        ECR_FRONTEND = 'rent-a-ride-frontend'

        IMAGE_TAG = "task7-${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Build Backend') {
            steps {
                sh '''
                    docker build \
                      -f backend/Dockerfile \
                      -t "$DOCKERHUB_BACKEND:$IMAGE_TAG" \
                      -t "$ECR_REGISTRY/$ECR_BACKEND:$IMAGE_TAG" \
                      .
                '''
            }
        }

        stage('Build Frontend') {
            steps {
                sh '''
                    docker build \
                      -f client/Dockerfile \
                      --build-arg VITE_FIREBASE_API_KEY="" \
                      --build-arg VITE_RAZORPAY_KEY_ID="" \
                      --build-arg VITE_PRODUCTION_BACKEND_URL="" \
                      -t "$DOCKERHUB_FRONTEND:$IMAGE_TAG" \
                      -t "$ECR_REGISTRY/$ECR_FRONTEND:$IMAGE_TAG" \
                      .
                '''
            }
        }

        stage('Push Images') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-rent-a-ride',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        set +x

                        printf '%s' "$DOCKERHUB_TOKEN" | \
                          docker login --username "$DOCKERHUB_USER" --password-stdin

                        aws ecr get-login-password --region "$AWS_REGION" | \
                          docker login --username AWS --password-stdin "$ECR_REGISTRY"

                        docker push "$DOCKERHUB_BACKEND:$IMAGE_TAG"
                        docker push "$DOCKERHUB_FRONTEND:$IMAGE_TAG"

                        docker push "$ECR_REGISTRY/$ECR_BACKEND:$IMAGE_TAG"
                        docker push "$ECR_REGISTRY/$ECR_FRONTEND:$IMAGE_TAG"

                        docker logout
                        docker logout "$ECR_REGISTRY"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Task 7 CI pipeline completed successfully.'
        }
        failure {
            echo 'Task 7 CI pipeline failed. Check the stage logs.'
        }
    }
}
