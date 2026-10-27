pipeline {
    agent {
        label 'podman'
    }

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
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
                    set -eu
                    podman build --pull=missing -t "$IMAGE:$TAG" .
                '''
            }
        }

        stage('Scan') {
            steps {
                sh '''
                    set -eu

                    rm -f image.tar trivy-report.txt

                    podman save -o image.tar "$IMAGE:$TAG"

                    rc=0

                    trivy image \
                        --timeout 40m \
                        --input image.tar \
                        --scanners vuln \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        --exit-code 1 \
                        --format table \
                        --output trivy-report.txt || rc=$?

                    if [ -f trivy-report.txt ]; then
                        cat trivy-report.txt
                    fi

                    rm -f image.tar

                    exit "$rc"
                '''
            }
        }

        stage('Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'registry-login',
                        usernameVariable: 'REG_USER',
                        passwordVariable: 'REG_PASS'
                    )
                ]) {
                    sh '''
                        set -eu

                        printf '%s' "$REG_PASS" | podman login \
                            registry.assign.sali358.300.ops:5000 \
                            --username "$REG_USER" \
                            --password-stdin

                        podman push "$IMAGE:$TAG"

                        podman logout \
                            registry.assign.sali358.300.ops:5000
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts(
                artifacts: 'trivy-report.txt',
                allowEmptyArchive: true
            )
        }
    }
}
