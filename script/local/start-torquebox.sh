#! /bin/bash

# Script to start CalCentral Torquebox in a local / development environment.
# WARNING: You must also set your local.yml configuration to include:
#
# cache:
#   servers: ["localhost"]
#   store: "memcached"

set -xv

TORQUEBOX_LOG=`date +"${PWD}/log/torquebox_%Y-%m-%d.log"`

killall memcached
killall gulp
sleep 1
memcached -d

rm -rf public/assets log/*.log .bundle
bundle install & npm install
bundle exec torquebox deploy .

# Adapted from current start-torquebox.sh settings
OPTS="-J-Djruby.openssl.x509.lookup.cache=8 -Xcompile.invokedynamic=false -J-XX:+UseConcMarkSweepGC -J-XX:+CMSPermGenSweepingEnabled -J-XX:+CMSClassUnloadingEnabled -J-Djruby.thread.pool.enabled=true -J-Djava.io.tmpdir=${PWD}/tmp"
export JRUBY_OPTS=${OPTS}
JVM_OPTS="\-server \-verbose:gc \-Xmn768m \-Xms6144m \-Xmx6144m \-XX:+CMSParallelRemarkEnabled \-XX:+CMSScavengeBeforeRemark \-XX:+PrintPromotionFailure \-XX:+PrintGCDateStamps \-XX:+PrintGCDetails \-XX:+ScavengeBeforeFullGC \-XX:+UseCMSInitiatingOccupancyOnly \-XX:+UseCodeCacheFlushing \-XX:+UseConcMarkSweepGC \-XX:CMSInitiatingOccupancyFraction=85 \-XX:MaxMetaspaceSize=1024m \-XX:ReservedCodeCacheSize=256m"
MAX_THREADS=${CALCENTRAL_MAX_THREADS:="250"}

# build assets without watcher / browser sync
gulp build --env production

bundle exec torquebox run -p=3000  --clustered --jvm-options="$JVM_OPTS" --max-threads=${MAX_THREADS} >> ${TORQUEBOX_LOG}
