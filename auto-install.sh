#!/bin/sh

set -e

# Set your environment variables here
JMETER_NAMESPACE=jmeter
JMETER_APP_NAME=jmeter
JMETER_GIT_REPO=https://github.com/chrisphillips-cminion/jmeter-on-ocp.git
JMETER_TEST="example"
MEMORY_REQUEST="4096"
MEMORY_LIMIT="6144"
CPU_REQUEST="3.0"
CPU_LIMIT="4.0"

#############################
## Do not modify anything from this line
#############################

# Print environment variables
echo -e "\n=============="
echo -e "ENVIRONMENT VARIABLES:"
echo -e " * JMETER_NAMESPACE: $JMETER_NAMESPACE"
echo -e " * JMETER_APP_NAME: $JMETER_APP_NAME"
echo -e " * JMETER_GIT_REPO: $JMETER_GIT_REPO"
echo -e "==============\n"

# Check if the user is logged in
if ! oc whoami &> /dev/null; then
    echo -e "Check. You are not logged out. Please log in and run the script again."
    exit 1
else
    echo -e "Check. You are correctly logged in. Continue..."
    oc project $JMETER_NAMESPACE # To avoid issues with deleted projects
fi

#craete the ns if its not there
oc create ns $JMETER_NAMESPACE || true


# Create JMeter configuration on ConfigMap
echo -e "\n[1/3]Creating JMeter configuration on ConfigMap"
oc delete configmap ${JMETER_APP_NAME}-config -n $JMETER_NAMESPACE 
oc create configmap ${JMETER_APP_NAME}-config -n $JMETER_NAMESPACE \
--from-file=${JMETER_TEST}.jmx=tests/${JMETER_TEST}/test.jmx \
--from-file=config.properties=tests/${JMETER_TEST}/config-k8s.properties
oc get cm
# Create RHDG Client configmap
echo -e "\n[2/3]Building the JMeter container image"
oc process -f templates/jmeter-bc.yaml \
    -p APP_NAMESPACE=$JMETER_NAMESPACE \
    -p APPLICATION_NAME=$JMETER_APP_NAME \
    -p GIT_REPOSITORY=$JMETER_GIT_REPO | oc apply -f -

# Deploy the RHDG client
echo -e "\n[3/3]Deploying the JMeter client"
oc process -f templates/jmeter-dc.yaml \
    -p APP_NAMESPACE=$JMETER_NAMESPACE \
    -p APPLICATION_NAME=$JMETER_APP_NAME \
    -p MEMORY_REQUEST=$MEMORY_REQUEST \
    -p MEMORY_LIMIT=$MEMORY_LIMIT \
    -p CPU_REQUEST=$CPU_REQUEST \
    -p CPU_LIMIT=$CPU_LIMIT \
    -p TEST_NAME=$JMETER_TEST | oc apply -f -

sleep 5
# Wait for DeploymentConfig
echo -n -e "\nWaiting for pods ready..."
while [[ $(oc get pods -l app=$JMETER_APP_NAME -n $JMETER_NAMESPACE -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do oc get po && sleep 1; done; echo -n -e "  [OK]\n"

JMETER_POD=$(oc get pods -l app=$JMETER_APP_NAME -n $JMETER_NAMESPACE --template='{{(index .items 0).metadata.name}}')
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p ./results/ocp-$NOW-$JMETER_TEST-report

echo -e "\JMeter pod information:"
echo -e " * POD: $JMETER_POD"
echo -e " * LOGS: oc logs -f $JMETER_POD"
echo -e " * REPORT: oc rsync $JMETER_POD:/opt/jmeter/results/$JMETER_TEST-report/ ./results/ocp-$NOW-$JMETER_TEST-report"
