pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f k8s/namespace.yml
                    kubectl apply -f k8s/configmap.yml
                    kubectl apply -f k8s/secrets.yml
                    bash k8s/postgres/generate-init.sh
                    kubectl apply -f k8s/postgres/
                    kubectl apply -f k8s/rabbitmq/
                    kubectl wait --for=condition=ready pod -l app=postgres -n devops-app --timeout=120s
                    kubectl wait --for=condition=ready pod -l app=rabbitmq -n devops-app --timeout=120s
                    kubectl apply -f k8s/services/
                '''
            }
        }
        
        stage('Verify') {
            steps {
                sh 'kubectl get pods -n devops-app'
                sh 'kubectl get services -n devops-app'
            }
        }
    }
    
    post {
        always {
            echo "Pipeline finished!"
        }
    }
}