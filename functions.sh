#!/bin/bash
#Author: Wes Novack

getidfromip () { aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query Reservations[].Instances[].InstanceId --output text; }

getnamefromip () { aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text; }

getidfromname () { aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query Reservations[].Instances[].InstanceId --output text; }

getipfromname () { aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query Reservations[].Instances[].PrivateIpAddress --output text; }

sp () {
        if [ $# -eq 0 ]; then
                echo "Aborting: 1 profile name argument is required."; return 1
        elif ! grep -q "$1" ~/.aws/config; then
                echo "Aborting: $1 is not configured as an AWS profile."; return 1
        else
                export AWS_PROFILE="$1"
                echo '$AWS_PROFILE == '$AWS_PROFILE
        fi
}
