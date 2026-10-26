# bind-secondary
OPS300 Assignment 1 - BIND Secondary DNS Container


# OPS300 Assignment 1 - BIND Secondary DNS

This project builds a BIND9 secondary DNS container image using Jenkins and Podman.

## Pipeline

1. Checkout the source code from GitHub.
2. Build the container image using Podman.
3. Scan the image for HIGH and CRITICAL vulnerabilities using Trivy.
4. Push the image to the private registry if the scan passes.

## Environment

- Jenkins Controller: 192.168.103.204
- SSH Build Agent: 192.168.103.202
- Private Registry: 192.168.103.203:5000
- Primary DNS: 192.168.103.201

Registry credentials and SSH keys are stored outside this repository.
