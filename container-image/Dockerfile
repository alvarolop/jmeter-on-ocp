# Inspired from https://github.com/fgiloux/auto-perf-test/blob/master/jmeter/container/Dockerfile
FROM registry.access.redhat.com/ubi8/openjdk-17
MAINTAINER Álvaro López<alopezme@redhat.com>
ENV JMETER_VERSION "5.6.3"

LABEL jmeter.version=${JMETER_VERSION}

# Set JMeter base and home
ENV JMETER_BASE /opt/jmeter
ENV JMETER_HOME $JMETER_BASE/apache-jmeter-${JMETER_VERSION}
# Add JMeter to the Path
ENV PATH $JMETER_HOME/bin:$PATH

# Create jmeter directory with tests and results folder and install JMeter
RUN mkdir -p $JMETER_BASE/{tests,results}

USER root

# Option 1: Download latest jmeter binaries from the Apache archive:
RUN microdnf install gzip && cd $JMETER_BASE && \
    curl -SLO https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && ls -la && \
    tar xvf apache-jmeter-${JMETER_VERSION}.tgz && ls -la && \
    rm -rf apache-jmeter-${JMETER_VERSION}.tgz

# Option 2: If you don't have internet access from the build machine use COPY instead of curl. In this case, you will need the binaries in the same folder as this Dockerfile.
# COPY apache-jmeter-${JMETER_VERSION}.tgz $JMETER_BASE
# RUN tar -xf $JMETER_BASE/apache-jmeter-${JMETER_VERSION}.tgz -C $JMETER_BASE \
#     && rm -rf $JMETER_BASE/apache-jmeter-${JMETER_VERSION}.tgz

############# ARE PLUGINS NEEDED?
# COPY binaries/JMeterPlugins-ExtrasLibs-1.4.0.zip $JMETER_BASE/apache-jmeter-${JMETER_VERSION}/

# Set working directory
WORKDIR $JMETER_BASE

# Entrypoint has same signature as "jmeter" command
COPY run.sh $JMETER_BASE/run.sh


RUN chgrp -R 0 $JMETER_BASE \
    && chmod -R g+rw $JMETER_BASE \
    && chmod  gu+x $JMETER_BASE/run.sh

#1001 is an arbitrary choice
USER 1001

ENTRYPOINT ["sh", "-c", "source ${JMETER_BASE}/run.sh && /bin/bash"]

# CMD ["/bin/bash"]
