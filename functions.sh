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

iamdelete () {
        #delete an iam user and related objects. Pass IAM username in as first positional parameter.
        username=$1
        accountnumber=$(aws sts get-caller-identity --query Account --output text)
        aws iam delete-login-profile --user-name ${username}
        aws iam delete-virtual-mfa-device --serial-number "arn:aws:iam::${accountnumber}:mfa/${username}"
        iamdeletegroupmemberships ${username}
        aws iam delete-user --user-name ${username}
}

iamdeletegroupmemberships () {
        #delete group memberships for an IAM user. Pass IAM username in as first positional parameter.
        username=$1
        groups=$(aws iam list-groups-for-user --user-name ${username} --query Groups[].GroupName --output text)
        for group in $groups; do
                aws iam remove-user-from-group --group-name ${group} --user-name ${username}
        done
}

