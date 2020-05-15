#!/usr/bin/env bash
set -eo pipefail

DOCKER_IMAGE=sergiomartins8/jenkins-slave-base
DOCKER_TAG=1.0

## LOGIN
echo 'Logging into docker hub'
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

## BUILD IMAGE
echo 'Building docker image'
docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .

## TAG IMAGE
echo 'Tagging image'
docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest

## UPLOAD IMAGE
echo 'Uploading image'
docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
docker push ${DOCKER_IMAGE}:latest

## CLEAR WORKSPACE
echo 'Clearing workspace'
docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG}
docker rmi ${DOCKER_IMAGE}:latest
