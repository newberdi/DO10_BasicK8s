pipeline {
    agent any
    
    stages {
        stage('Hello') {
            steps {
                echo 'Jenkins работает!'
                sh 'echo "Текущая директория:"'
                sh 'pwd'
                sh 'echo "Файлы в директории:"'
                sh 'ls -la'
            }
        }
        
        stage('Check Environment') {
            steps {
                sh '''
                    echo "=== Проверка Docker ==="
                    docker --version || echo "Docker не найден"
                    
                    echo "=== Проверка Kubernetes ==="
                    kubectl version --client || echo "kubectl не найден"
                '''
            }
        }
    }
}