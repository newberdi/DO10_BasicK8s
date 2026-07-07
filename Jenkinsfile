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
                        bash k8s/postgres/generate-init.sh
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

        stage('Run Postman Tests') {
            steps {
                dir('src/postman') {
                    sh '''
                        # пробрасываем порт к gateway
                        kubectl port-forward service/gateway-service -n devops-app 8087:8087 &
                        kubectl port-forward service/session-service -n devops-app 8081:8081 &
                        sleep 5
                        
                        # запускаем тесты
                        newman run application_tests.postman_collection.json
                        
                        # убиваем port-forward
                        pkill -f "port-forward.*devops-app"
                    '''
                }
            }
        }
    }
}