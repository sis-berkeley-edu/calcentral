#!/bin/bash

######################################################
#
# Run load tests.
#
# Make sure the normal shell environment is in place,
# since it may not be when running as a cron job.
#
######################################################

source "${HOME}/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$(date +"${PWD}/log/load_test_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
source "${PWD}/.rvmrc"

export RAILS_ENV=${RAILS_ENV:-production}

# JVM args per CalCentral convention
source "${PWD}/script/standard-calcentral-JVM-OPTS-profile"

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Restart CalCentral..." | ${LOGIT}

~/init.d/calcentral restart | ${LOGIT}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Clear cache and cache statisics..." | ${LOGIT}

cd ~/calcentral/deploy
bundle exec rake memcached:clear | ${LOGIT}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Start empty-cache load test on ${LOAD_TEST_AGENT}..." | ${LOGIT}

ssh ${LOAD_TEST_AGENT} "cd tsung && ./automated_tsung.sh calcentral-dev" | ${LOGIT}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Get cache statistics for empty-cache load test..." | ${LOGIT}

bundle exec rake memcached:get_stats | ${LOGIT}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Start primed-cache load test on ${LOAD_TEST_AGENT}..." | ${LOGIT}

ssh ${LOAD_TEST_AGENT} "cd tsung && ./automated_tsung.sh calcentral-dev-cached" | ${LOGIT}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Get cache statistics for primed-cache load test..." | ${LOGIT}

bundle exec rake memcached:get_stats | ${LOGIT}

exit 0
