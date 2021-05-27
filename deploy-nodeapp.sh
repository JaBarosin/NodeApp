#!/bin/bash
USERNAME=jake
HOST="192.168.6.44"
ssh -o StrictHostKeyChecking=no -l ${USERNAME} ${HOST} "microk8s.kubectl apply -f /opt/jake-repos/node-docker/NodeApp/config/deployment.yaml"
