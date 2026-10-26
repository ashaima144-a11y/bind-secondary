
pipeline {
    agent { label 'podman' }

    options {
        skipDefaultCheckout(true)
    }

    environment {
        IMAGE = 'registry.assign.sali358.300.ops:5000/bind-secondary'
        TAG = "${BUILD_NUMBER}"
    }

    triggers {
        pollSCM('H/2 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh '''
                    podman build -t "$IMAGE:$TAG" .
                '''
            }
        }

        stage('Scan') {
            steps {
                sh '''
                    rc=0
                    podman save -o image.tar "$IMAGE:$TAG"
                    trivy image --input image.tar --scanners vuln \
                      --severity HIGH,CRITICAL --ignore-unfixed \
                      --exit-code 1 --format table \
                      --output trivy-report.txt || rc=$?
                    cat trivy-report.txt
                    rm -f image.tar
                    exit "$rc"
                '''
            }
        }

        stage('Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'registry-login',
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {
                    sh '''
                        echo "$REG_PASS" | podman login \
                          registry.assign.sali358.300.ops:5000 \
                          -u "$REG_USER" --password-stdin

                        podman push "$IMAGE:$TAG"
                        podman logout registry.assign.sali358.300.ops:5000
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-report.txt',
                allowEmptyArchive: true
        }
    }
}
