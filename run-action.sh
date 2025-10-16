#!/bin/bash
set -e
echo "Listing EC2 instances..."
aws ec2 describe-instances --region eu-west-1 --query "Reservations[*].Instances[*].{ID:InstanceId,State:State.Name}" --output table
