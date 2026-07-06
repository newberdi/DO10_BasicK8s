pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy Infrastructure') {
            steps {
                dir('src') {
                    sh '''
                        kubectl apply -f k8s/namespace.yml
                        kubectl apply -f k8s/configmap.yml
                        kubectl apply -f k8s/secrets.yml
                        bash /var/jenkins_home/workspace/devops-pipeline/src/app/services/database/init.sql
                        kubectl apply -f k8s/postgres/
                        kubectl apply -f k8s/rabbitmq/
                    '''
                }
            }
        }
        
        stage('Wait for DB') {
            steps {
                sh '''
                    kubectl wait --for=condition=ready pod -l app=postgres -n devops-app --timeout=120s
                    kubectl wait --for=condition=ready pod -l app=rabbitmq -n devops-app --timeout=120s
                '''
            }
        }
        
        stage('Deploy Services') {
            steps {
                dir('src') {
                    sh 'kubectl apply -f k8s/services/'
                }
            }
        }
        
        stage('Verify') {
            steps {
                sh 'kubectl get pods -n devops-app'
            }
        }
    }
}