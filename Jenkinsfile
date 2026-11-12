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

        COMPOSE_PROJECT_NAME = 'rent-a-ride-devops-internship-project'
        APP_ENV_FILE = '/etc/rent-a-ride/.env'

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

        stage('Cleanup Local Build Tags') {
            steps {
                sh '''
                    docker image rm \
                      "$DOCKERHUB_BACKEND:$IMAGE_TAG" \
                      "$DOCKERHUB_FRONTEND:$IMAGE_TAG" \
                      "$ECR_REGISTRY/$ECR_BACKEND:$IMAGE_TAG" \
                      "$ECR_REGISTRY/$ECR_FRONTEND:$IMAGE_TAG" \
                      || true
                '''
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-rent-a-ride',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x

                        test -r "$APP_ENV_FILE"

                        printf '%s' "$DOCKERHUB_TOKEN" | \
                          docker login --username "$DOCKERHUB_USER" --password-stdin

                        trap 'docker logout >/dev/null 2>&1 || true' EXIT

                        docker compose \
                          -p "$COMPOSE_PROJECT_NAME" \
                          pull backend frontend

                        docker compose \
                          -p "$COMPOSE_PROJECT_NAME" \
                          up -d --remove-orphans --wait --wait-timeout 180

                        curl -fsS http://127.0.0.1:3001/ >/dev/null

                        curl -fsS \
                          http://127.0.0.1:3001/api/user/listAllVehicles \
                          >/dev/null

                        docker compose -p "$COMPOSE_PROJECT_NAME" ps
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Task 8 CI/CD pipeline and Docker Compose deployment completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs before retrying.'
        }
    }
}
