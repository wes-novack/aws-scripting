#!/bin/bash
#Author: Wes Novack

set -e

id=$1
sleep_duration=5
start_time=$(date +%s)

function check_parameter () {
	if echo "$1" | grep -P '^i-[a-zA-Z0-9]{8,}'; then
		return 0
	else
		echo "An instance id parameter is required. Example: i-0w7vjth3"
		return 1
	fi
}

function stop_instance () {
	aws ec2 stop-instances --instance-ids $1
}

function start_instance () {
	aws ec2 start-instances --instance-ids $1
}

function check_status () {
	aws ec2 describe-instances --instance-ids $1 \
		--query Reservations[].Instances[].State.Name --output text
}

function check_running () {
	status=$(check_status $1)
	if [ $status != "running" ]; then
		echo "Can't restart instance, its state is not running."
		return 1
	fi
}

function wait_for_status () {
	status=$(check_status $1)
	while [ $status != "$2" ]; do
		echo "Instance state not yet $2, sleeping"
		sleep $sleep_duration
		status=$(check_status $1)
	done
}

check_parameter $id
check_running $id
stop_instance $id
wait_for_status $id stopped
start_instance $id
wait_for_status $id running
end_time=$(date +%s)
duration=$((end_time - start_time))
echo "Your restart of instance $id is complete!"
echo "This script completed in $duration seconds."
