#!/bin/bash
STACK_NAME=awsbootstrap
REGION=eu-central-1
EC2_INSTANCE_TYPE=t2.micro

# Deploy the cloudformation template
echo -e ==========Deploying main.yml==============
docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli cloudformation deploy \
  --region $REGION \
  --stack-name $STACK_NAME \
  --template-file main.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides EC2InstanceType=$EC2_INSTANCE_TYPE

# If the deploy succeeded, show the DNS name of the created instance
if [ $? -eq 0 ]; then
  docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli cloudformation list-exports \
    --query "Exports[?Name=='InstanceEndpoint'].Value" 
fi
