#!/bin/bash

# Jenkins credentials
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_PASSWORD="your_initial_admin_password"
TOKEN_NAME="ansible-token"

# Login to Jenkins and get the crumb
CRUMB=$(curl -s --user "$JENKINS_USER:$JENKINS_PASSWORD" "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

# Generate API token
RESPONSE=$(curl -s -X POST --user "$JENKINS_USER:$JENKINS_PASSWORD" -H "$CRUMB" "$JENKINS_URL/me/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" --data "newTokenName=$TOKEN_NAME")

# Extract the token from the response
API_TOKEN=$(echo $RESPONSE | grep -oP '(?<="tokenValue":")[^"]*')

# Print the API token
echo "Generated Jenkins API Token: $API_TOKEN"