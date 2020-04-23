#!/bin/sh

## Enable this for crontab
# export PATH=$PATH:/usr/local/bin/
# export KUBECONFIG=/root/.kube/sa-eks004

test -e $HOME/log || mkdir $HOME/log

LOG_PATH=$HOME/log/ns_stats.log
KEY_PATH=$HOME/secrets/key.json

LINE_TOKEN_ME="reQphxR0nOG8hqNnoQ85Rxk85Uv9EPvuKD2hguShVtI"
LINE_TOKEN_GROUP="mBZsRyVzb2I9UmSuk5ctLX6VIF9V1PqJsjxeaQMXcnZ"
LINE_NOTIFY_TARGET=$LINE_TOKEN_ME

# Get total numuber of pods in the current namespace
CMD_GET_POD="kubectl get pod"
CMD_POD_COUNT="kubectl get pod | sed '1d' | wc -l | sed 's/[[:space:]]//g'"
CMD_GET_CONTEXTS="kubectl config get-contexts"

### Start
DATETIME=$(date)
echo $DATETIME ---------------------------------------------------------------------------------------------- >> $LOG_PATH

# set_cluster_ns() {
#     # Get contexts
#     kubectl config get-contexts >> $LOG_PATH

#     # Switch context
#     kubectl config use-context $CONTEXT >> $LOG_PATH
#     echo "" >> $LOG_PATH

#     # ---- Set namespace ----
#     NAMESPACE="level1"
#     kubectl config set-context --current --namespace=$NAMESPACE >> $LOG_PATH
#     echo "\nNamespace: $NAMESPACE\n" >> $LOG_PATH
# }

# CONTEXT="24c3c1e0-8094-11ea-a8cd-d6940539dde2-eks006"
# NAMESPACE=level1
# set_cluster_ns

# ---- Get pods ----
# eval $CMD_GET_POD >> $LOG_PATH
# echo "" >> $LOG_PATH

# ---- Get number of pods ----
# TOTAL=$(eval $CMD_POD_COUNT)
# echo "Total: $TOTAL\n" >> $LOG_PATH

# ---- Get current namespace quota ----
# NQ=$(kubectl get ns level1 -o yaml | grep namespacequota | awk '{print $2}')
# echo "Namesapce quota: $NQ" >> $LOG_PATH
# QUOTA_POD=$(kubectl get nq $NQ -o yaml | grep pods: | awk '{print $2}' | tr -d '\"')
# echo "Pod quota: $QUOTA_POD" >> $LOG_PATH

# -------- Use the API to get quota and usage --------

# ---- Prepare ----
MP_BASE_URL="https://portal-mp-ensaas.sa.wise-paas.com"
SSO_BASE_URL="https://api-sso-ensaas.sa.wise-paas.com"
DATA_CENTER="sa"
CLUSTER="eks004"
NAMESPACE="level1"

MSG_NOTIFY=""

get_namespace_info() {
    # Prepare API URLs
    API_AUTH="$SSO_BASE_URL/v4.0/auth/native"
    API_NS_INFO="$MP_BASE_URL/v1/datacenter/$DATA_CENTER/cluster/$CLUSTER/namespace/$NAMESPACE/info"

    # Get accessToken for calling the API
    TOKEN=$(curl -X POST $API_AUTH -H "Content-Type: application/json" -d @$KEY_PATH | jq '.accessToken' | tr -d '\"')

    # Get namespace information
    NS_INFO=$(curl $API_NS_INFO -H "Authorization: Bearer $TOKEN")

    echo "$NS_INFO\n" >> $LOG_PATH

    # Store all information
    limitCPU=$(echo $NS_INFO | jq '.limitCPU' | tr -d '\"')
    requestCPU=$(echo $NS_INFO | jq '.requestCPU' | tr -d '\"')
    totalCPU=$(echo $NS_INFO | jq '.totalCPU' | tr -d '\"')
    usedCPU=$(echo $NS_INFO | jq '.usedCPU' | tr -d '\"')

    limitCPU_Rate=`echo "scale=2; $limitCPU / $totalCPU" | bc -l`
    requestCPU_Rate=`echo "scale=2; $requestCPU / $totalCPU" | bc -l`

    limitMemory=$(echo $NS_INFO | jq '.limitMemory' | tr -d '\"' | tr -d '.00')
    requestMemory=$(echo $NS_INFO | jq '.requestMemory' | tr -d '\"' | tr -d '.00')
    totalMemory=$(echo $NS_INFO | jq '.totalMemory' | tr -d '\"')

    limitMemory_Rate=`echo "scale=2; $limitMemory / $totalMemory" | bc -l`
    requestMemory_Rate=`echo "scale=2; $requestMemory / $totalMemory" | bc -l`

    usedPod=$(echo $NS_INFO | jq '.usedPod' | tr -d '\"' | tr -d '.00')
    totalPod=$(echo $NS_INFO | jq '.totalPod' | tr -d '\"')

    MSG="%0D%0A\
    [$DATA_CENTER-$CLUSTER-$NAMESPACE]%0D%0A\
    cpu_lim: $limitCPU/$totalCPU, $limitCPU_Rate%0D%0A\
    cpu_req: $requestCPU/$totalCPU, $requestCPU_Rate%0D%0A\
    mem_lim: $limitMemory/$totalMemory, $limitMemory_Rate%0D%0A\
    mem_req: $requestMemory/$totalMemory, $requestMemory_Rate%0D%0A\
    pod: $usedPod/$totalPod\
    "
}

accumulate_msg() {
    MSG_NOTIFY="$MSG_NOTIFY$MSG%0D%0A"
}

# Function: get statistics for namespac
get_namespace_info
# Function: accumulate messages
accumulate_msg

# ---- sa-eks004-level2 ----
# MP_BASE_URL="https://portal-mp-ensaas.sa.wise-paas.com"
# SSO_BASE_URL="https://api-sso-ensaas.sa.wise-paas.com"
# DATA_CENTER="sa"
# CLUSTER="eks004"
NAMESPACE="level2"
# do
get_namespace_info
accumulate_msg

# ---- hz-eks006-level1 ----
MP_BASE_URL="https://portal-mp-ensaas.hz.wise-paas.com.cn"
SSO_BASE_URL="https://api-sso-ensaas.hz.wise-paas.com.cn"
DATA_CENTER="hz"
CLUSTER="eks006"
NAMESPACE="level2"
# do
get_namespace_info
accumulate_msg

# Send LINE notification
curl -H "Authorization: Bearer $LINE_NOTIFY_TARGET" -d "message=$MSG_NOTIFY" -X POST https://notify-api.line.me/api/notify

# To separate from the next log
echo "\n" >> $LOG_PATH
