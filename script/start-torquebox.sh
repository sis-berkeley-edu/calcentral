#!/bin/bash

######################################################
#
# Start CalCentral, running on Torquebox
#
######################################################

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=`date +"${PWD}/log/start-stop_%Y-%m-%d.log"`
TORQUEBOX_LOG=`date +"${PWD}/log/torquebox_%Y-%m-%d.log"`

LOGIT="tee -a ${LOG}"

# Kill active Torquebox processes, if any.
echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "`date`: Stopping running instances of CalCentral..." | ${LOGIT}
./script/stop-torquebox.sh

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
source "${PWD}/.rvmrc"

export RAILS_ENV=${RAILS_ENV:-production}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "`date`: Starting CalCentral..." | ${LOGIT}
OPTS=${CALCENTRAL_JRUBY_OPTS:="-J-Djruby.openssl.x509.lookup.cache=8 -Xcompile.invokedynamic=false -J-Djruby.thread.pool.enabled=true -J-Djava.io.tmpdir=${PWD}/tmp"}
export JRUBY_OPTS=${OPTS}

# The CALCENTRAL_JVM_OPTS env variable (optional) will override default JVM args
JVM_OPTS=${CALCENTRAL_JVM_OPTS:="\-server \-verbose:gc \-Xmn500m \-Xms3000m \-Xmx3000m \-XX:+CMSParallelRemarkEnabled \-XX:+CMSScavengeBeforeRemark \-XX:+PrintGCCause \-XX:+PrintGCDateStamps \-XX:+PrintGCDetails \-XX:+ScavengeBeforeFullGC \-XX:+UseCMSInitiatingOccupancyOnly \-XX:+UseCodeCacheFlushing \-XX:+UseConcMarkSweepGC \-XX:CMSInitiatingOccupancyFraction=85 \-XX:MaxMetaspaceSize=1024m \-XX:ReservedCodeCacheSize=256m"}

LOG_DIR=${CALCENTRAL_LOG_DIR:=`pwd`"/log"}
MAX_THREADS=${CALCENTRAL_MAX_THREADS:="90"}
export CALCENTRAL_LOG_DIR=${LOG_DIR}
IP_ADDR=`/sbin/ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

cd deploy

JBOSS_HOME=`bundle exec torquebox env jboss_home`
cp ~/.calcentral_config/standalone-ha.xml ${JBOSS_HOME}/standalone/configuration/

nohup bundle exec torquebox run -b ${IP_ADDR} -p=3000 --jvm-options="${JVM_OPTS}" --clustered --max-threads=${MAX_THREADS} < /dev/null >> ${TORQUEBOX_LOG} 2>> ${LOG} &
cd ..

# Verify that CalCentral is alive and warm up caches.
./script/check-alive.sh || exit 1

./script/init.d/calcentral online

exit 0
