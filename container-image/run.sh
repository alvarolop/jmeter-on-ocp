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
if [ $RUN_JMETER != false ]
then
    echo "START Running Jmeter on `date`"
    # -n(--nongui),-D(--systemproperty),-t(--testfile),-l(--logfile)
    # -p(--propfile),-e(--reportatendofloadtests),-o(--reportoutputfolder)
    export TEST_PLAN="${TEST_NAME:-example}"
    jmeter \
    -n \
    -p "$JMETER_BASE/tests/config.properties" \
    -t "$JMETER_BASE/tests/${TEST_PLAN}.jmx" \
    -l "$JMETER_BASE/results/${TEST_PLAN}.jtl" \
    -e \
    -o "$JMETER_BASE/results/${TEST_PLAN}-report"
    exec tail -f jmeter.log
    echo "END Running Jmeter on `date`"
else
    echo "Skipping the execution of jmeter, run it manually..."
fi

# Wait to download results from the test
while true;
do
    sleep 30;
done;
