#!/bin/bash
# Inspired from https://github.com/justb4/docker-jmeter/blob/master/entrypoint.sh
# Basically runs jmeter, assuming the PATH is set to point to JMeter bin-dir (see Dockerfile)
#
# This script expects the standard JMeter command parameters.
#
set -e
freeMem=`awk '/MemFree/ { print int($2/1024) }' /proc/meminfo`
s=$(($freeMem/10*8))
x=$(($freeMem/10*8))
n=$(($freeMem/10*2))
export JVM_ARGS="-Xmn${n}m -Xms${s}m -Xmx${x}m"

echo "JVM_ARGS=${JVM_ARGS}"
echo "jmeter args=$@"

# Ejecute the JMeter command.
# Keep entrypoint simple: we must pass the standard JMeter arguments
#echo "START Running Jmeter on `date`"
#$JMETER_BIN/jmeter \
#    -n \
#    -D "java.rmi.server.hostname=${IP}" \
#    -D "client.rmi.localport=${RMI_PORT}" \
#    -t "/load_tests/${TEST_DIR}/${TEST_PLAN}.jmx" \
#    -l "/load_tests/${TEST_DIR}/${TEST_PLAN}.jtl" \
#    -R $REMOTE_HOSTS
# exec tail -f jmeter.log
echo "END Running Jmeter on `date`"