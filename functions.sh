#!/bin/bash
#Description: a collection of bash functions that leverage the AWS CLI
#Formatting: tab spacing

getidfromip () { id=$(aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query "Reservations[].Instances[].InstanceId" --output text);echo $id; }

getnamefromid () { name=$(aws ec2 describe-instances --filter Name=instance-id,Values="$1" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text);echo $name; }

getnamefromip () { name=$(aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text);echo $name; }

getidfromname () { id=$(aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query "Reservations[].Instances[].InstanceId" --output text);echo $id; }

getipfromname () { ip=$(aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query "Reservations[].Instances[].PrivateIpAddress" --output text);echo $ip; }

gettagsfromip () { aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query 'Reservations[].Instances[].Tags' --output table; }

gettagsfromname () { aws ec2 describe-instances --filter Name=tag:Name,Values="$1" --query 'Reservations[].Instances[].Tags' --output table; }

getkeyfromip () { name=$(aws ec2 describe-instances --filter Name=private-ip-address,Values="$1" --query 'Reservations[].Instances[].KeyName' --output text);echo $name; }

gettagsfromid () { aws ec2 describe-instances --instance-ids "$1" --query 'Reservations[].Instances[].Tags' --output table; }

sp () {
	#switch profile to an aws cli named profile
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
	#unsets all AWS and SAML environment variables
	aws_envs=$(env|grep -o 'AWS\|SAML'|sed 's/=.*//g')
	for i in $aws_envs; do unset $i; done
}

iamdelete () {
	#delete an iam user and related objects. Pass IAM username in as first positional parameter.
	username=$1

	echo "Checking for login profile and delete if found"
	aws iam get-login-profile --user-name ${username} >/dev/null 2>&1
	if [ "$?" -eq 0 ]; then 
		aws iam delete-login-profile --user-name ${username}
	fi

	echo "Checking for virtual-mfa-device and delete if found"
	mfaserial=$(aws iam list-mfa-devices --user-name ${username} --query MFADevices[].SerialNumber --output text)
	if [ ! -z "$mfaserial" ]; then 
		aws iam deactivate-mfa-device --user-name ${username} --serial-number "${mfaserial}"
		aws iam delete-virtual-mfa-device --serial-number "${mfaserial}"
	fi

	echo "Checking and removing group memberships if found"
	iamdeletegroupmemberships ${username}

	echo "Checking for inline user policies and removing if found"
	inlinepolicies=$(aws iam list-user-policies --user-name ${username} --query PolicyNames --output text)
	for policy in $inlinepolicies; do
		echo "${policy}"
		aws iam delete-user-policy --user-name ${username} --policy-name ${policy}
	done

	echo "Checking for attached user policies and detaching if found"
	policyarns=$(aws iam list-attached-user-policies --user-name ${username} --query AttachedPolicies[].PolicyArn --output text)
	for policyarn in $policyarns; do
		echo "${policyarn}"
		aws iam detach-user-policy --user-name ${username} --policy-arn "${policyarn}"
	done

	echo "Checking for access keys and deleting if found"
	accesskeyids=$(aws iam list-access-keys --user-name ${username} --query AccessKeyMetadata[].AccessKeyId --output text)
	if [ ! -z "$accesskeyids" ] && echo "Access Keys Found, attempting to delete them"; then
		for id in ${accesskeyids}; do
			aws iam delete-access-key --user-name ${username} --access-key-id ${id}
		done
	else
		echo "No Access Keys Found"
	fi
        aws iam delete-user --user-name ${username}
	if [ "$?" -eq 0 ]; then 
		echo "IAM user ${username} deleted successfully"
	fi
}

iamdeletegroupmemberships () {
	#delete group memberships for an IAM user. Pass IAM username in as first positional parameter.
	username=$1
	groups=$(aws iam list-groups-for-user --user-name ${username} --query Groups[].GroupName --output text)
	for group in $groups; do
	echo "Removing user ${username} from group ${group}"
		aws iam remove-user-from-group --group-name ${group} --user-name ${username}
	done
}
