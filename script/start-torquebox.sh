#!/bin/bash

######################################################
#
# Start CalCentral, running on Torquebox
#
######################################################

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$(date +"${PWD}/log/start-stop_%Y-%m-%d.log")
TORQUEBOX_LOG=$(date +"${PWD}/log/torquebox_%Y-%m-%d.log")

LOGIT="tee -a ${LOG}"

# Kill active Torquebox processes, if any.
echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Stopping running instances of CalCentral..." | ${LOGIT}

./script/stop-torquebox.sh

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
source "${PWD}/.rvmrc"

export RAILS_ENV=${RAILS_ENV:-production}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Starting CalCentral..." | ${LOGIT}

# Set JVM args per CalCentral convention
./script/export-JVM-args-per-calcentral-standards.sh

# Custom additions to JRuby JVM_OPTS
export JRUBY_OPTS="${JRUBY_OPTS} -J-Djruby.thread.pool.enabled=true -J-Djava.io.tmpdir=${PWD}/tmp"

MAX_THREADS=${CALCENTRAL_MAX_THREADS:="90"}

export CALCENTRAL_LOG_DIR=${CALCENTRAL_LOG_DIR:="$(pwd)/log"}

IP_ADDR=$(/sbin/ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')

cd deploy

JBOSS_HOME=$(bundle exec torquebox env jboss_home)

cp ~/.calcentral_config/standalone-ha.xml ${JBOSS_HOME}/standalone/configuration/

# Set JVM args per CalCentral convention
source "${PWD}/script/standard-calcentral-JVM-OPTS-profile"

nohup bundle exec torquebox run -b ${IP_ADDR} -p=3000 --jvm-options="\-server \-verbose:gc ${ESCAPED_JVM_OPTS}" --clustered --max-threads=${MAX_THREADS} < /dev/null >> ${TORQUEBOX_LOG} 2>> ${LOG} &

cd ..

# Verify that CalCentral is alive and warm up caches.
./script/check-alive.sh || exit 1

./script/init.d/calcentral online

exit 0
