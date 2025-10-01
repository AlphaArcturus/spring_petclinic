pipeline {
    agent any

    tools {
        maven 'Maven3'   // Make sure Maven is installed on Jenkins
        jdk 'Java17'     // Ensure Jenkins has JDK 17 configured
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Code Quality') {
            steps {
                // Requires SonarQube plugin configured in Jenkins
                withSonarQubeEnv('SonarQubeServer') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Security Scan') {
            steps {
                // Example using OWASP Dependency-Check
                sh 'mvn org.owasp:dependency-check-maven:check'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t petclinic-app:latest .'
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh 'docker run -d -p 8080:8080 --name petclinic-staging petclinic-app:latest'
            }
        }

        stage('Monitoring & Release') {
            steps {
                echo 'Monitoring via Spring Boot Actuator + Prometheus'
                echo 'Manual approval required before production release'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
