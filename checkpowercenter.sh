#!/bin/bash
#check_powercenter.sh
# This is a nagios plugin that checks the status of powercenter workflows.
#
# Author: Asa Gage
# Date: 6-16-2014
# Version 1.0.0
# 
#check for missing parameters
if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
	echo "Missing parameters! Syntax: ./check_powercenter.sh WORKFLOW_NAME SCHEDULE_INTERVAL_MIN WORKFLOW_TIMEOUT_MIN"
	exit 2
fi
#This checks the status of powercenter workflows
cmdout=`pmcmd getworkflowdetails -sv YOURINTEGRATIONSERVICEVARNAME -d YOURDOMAIN -uv YOURUSERNAMEVAR -pv YOURPASSWORDVAR -f YOURFOLDERNAME $1`
#echo $cmdout

status=$(echo "$cmdout" | sed -n -e 's/^.*Workflow run status: //p' | sed -r 's/(\[|\])//g')
starttime=$(echo "$cmdout" | sed -n -e 's/^.*Start time: //p' | sed -r 's/(\[|\])//g')
endtime=$(echo "$cmdout" | sed -n -e 's/^.*End time: //p' | sed -r 's/(\[|\])//g')
currenttime=$(echo "$cmdout" | sed -n -e 's/^.*Completed at //p')
#echo $status
#echo $starttime
#echo $endtime
#echo $currenttime
starttimestamp=$(date -d "$starttime" "+%s")
#echo $starttimestamp
currenttimestamp=$(date -d "$currenttime" "+%s")
#echo $currenttimestamp
timediff=$(($currenttimestamp-starttimestamp))
#echo $timediff
#echo $((timediff/60))

#if status = Succeeded and last start time was less than SCHEDULE_INTERVAL_MIN ago then OK
if [[ "$status" -eq "Succeeded" ]]; then
	if [[ "$((timediff/60))" -lt $2 ]]; then
		echo "OK - Workflow status is OK"
		exit 0
	else
		echo "CRITICAL - Workflow Unscheduled"
		exit 2
	fi
elif [[ "$status" -eq "Running" ]]; then
	if [[ "$((timediff/60))" -lt $3 ]]; then
		echo "OK"
		exit 0
	else
		echo "WARNING - Workflow has been running longer than expected."
		exit 1
	fi
else
#	UNKNOWN response
	echo "CRITICAL - Unknown Workflow status."
	exit 2
fi
#
