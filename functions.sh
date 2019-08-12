#!/bin/bash
#Author: Wes Novack

getidfromip () { id=$(aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query "Reservations[].Instances[].InstanceId" --output text);echo $id; }

getnamefromid () { name=$(aws ec2 describe-instances --filter Name=instance-id,Values="$1" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text);echo $name; }

getnamefromip () { name=$(aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text);echo $name; }

getidfromname () { id=$(aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query "Reservations[].Instances[].InstanceId" --output text);echo $id; }

getipfromname () { ip=$(aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query "Reservations[].Instances[].PrivateIpAddress" --output text);echo $ip; }

sp () {
        if [ $# -eq 0 ]; then
                echo "Aborting: 1 named profile argument is required."; return 1
        elif ! grep -q "$1" ~/.aws/credentials; then
                echo "Aborting: $1 is not configured as an AWS named profile."; return 1
        else
                export AWS_PROFILE="$1"
                echo '$AWS_PROFILE == '$AWS_PROFILE
        fi
}

unsetaws () {
        aws_envs=$(env|grep -Po 'AWS.*(?=\=)|SAML.*(?=\=)')
        for i in $aws_envs; do unset $i; done
}

