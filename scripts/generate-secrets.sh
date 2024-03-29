#!/bin/bash
# This script automates Kubernetes secret generation.

# Generate the AWS secrets
echo "Generating AWS secrets..."
kubectl create secret generic aws.secrets \
--from-literal=aws_access_key_id=$(aws configure get aws_access_key_id) \
--from-literal=aws_secret_access_key=$(aws configure get aws_secret_access_key) \
--save-config \
--dry-run=client \
--output=yaml | kubectl apply -f -

# Generate the Docker Registry secret
echo "Generating Docker Registry secret..."
githubtoken=`cat .ghcr.token`

kubectl create secret docker-registry ghcr-auth \
--docker-server=https://ghcr.io \
--docker-username=ivorscott \
--docker-password=$githubtoken \
--docker-email=ivor@devpie.io \
--save-config \
--dry-run=client \
--output=yaml | kubectl apply -f -

## Generate the Traefik secret
echo "Generating Traefik secret..."
username=`echo -n "saas-admin" | base64`
password=`cat .traefik.password`

cat << EoF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: traefik-secret
  namespace: default
type: kubernetes.io/basic-auth
data:
  username: $username
  password: $password
EoF

cd $1/saas

## Generate the Cognito secrets
echo "Generating Cognito secrets..."
kubectl create secret generic cognito.secrets \
--from-literal=admin_user_pool_id=$(terraform output -raw admin_user_pool_id) \
--from-literal=admin_app_client_id=$(terraform output -raw admin_user_pool_client_id) \
--from-literal=shared_user_pool_id=$(terraform output -raw shared_user_pool_id) \
--save-config \
--dry-run=client \
--output=yaml | kubectl apply -f -

## Generate the Postgres secrets
echo "Generating Postgres secrets..."
kubectl create secret generic postgres.secrets \
--from-literal=postgres_username_users=$(terraform output -raw postgres_username_users) \
--from-literal=postgres_password_users=$(terraform output -raw postgres_password_users) \
--from-literal=postgres_hostname_users=$(terraform output -raw postgres_hostname_users) \
--from-literal=postgres_username_admin=$(terraform output -raw postgres_username_admin) \
--from-literal=postgres_password_admin=$(terraform output -raw postgres_password_admin) \
--from-literal=postgres_hostname_admin=$(terraform output -raw postgres_hostname_admin) \
--from-literal=postgres_username_projects=$(terraform output -raw postgres_username_projects) \
--from-literal=postgres_password_projects=$(terraform output -raw postgres_password_projects) \
--from-literal=postgres_hostname_projects=$(terraform output -raw postgres_hostname_projects) \
--from-literal=postgres_username_subscriptions=$(terraform output -raw postgres_username_subscriptions) \
--from-literal=postgres_password_subscriptions=$(terraform output -raw postgres_password_subscriptions) \
--from-literal=postgres_hostname_subscriptions=$(terraform output -raw postgres_hostname_subscriptions) \
--save-config \
--dry-run=client \
--output=yaml | kubectl apply -f -