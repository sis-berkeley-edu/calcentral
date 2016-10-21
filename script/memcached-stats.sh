#!/bin/bash

######################################################
#
# Summarize memcached usage and effectiveness.
#
######################################################

source "${HOME}/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG="${PWD}/log/memcached_stats_$(date +"%Y-%m-%d").log"
LOGIT="tee -a ${LOG}"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
source "${PWD}/.rvmrc"

export RAILS_ENV=${RAILS_ENV:-production}
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO

# JVM args per CalCentral convention
source "${PWD}/script/standard-calcentral-JVM-OPTS-profile"

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

cd deploy

bundle exec rake memcached:get_stats | ${LOGIT}

exit 0
