#!/bin/bash
HOST="192.168.6.44"
ssh ${HOST} "microk8s.kubectl apply -f /opt/jake-repos/node-docker/NodeApp/config/deployment.yaml"
