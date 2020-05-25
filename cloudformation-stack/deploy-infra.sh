#!/bin/bash
STACK_NAME=awsbootstrap
REGION=eu-central-1
EC2_INSTANCE_TYPE=t2.micro

AWS_ACCOUNT_ID=`docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli sts get-caller-identity --profile awsbootstrap \
  --query "Account" --output text`
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID" 

# Deploy the setup.yml template. S3 buckets
echo -e "\n\n==========Deploying main.yml=============="
docker run --rm -it -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli cloudformation deploy \
  --region $REGION \
  --stack-name $STACK_NAME-setup \
  --template-file setup.yml \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    CodePipelineBucket=$CODEPIPELINE_BUCKET

# Deploy the cloudformation template
echo -e "\n\n==========Deploying main.yml=============="
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
