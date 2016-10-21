#!/bin/bash

######################################################
#
# Check for overwritten configurations on
# bCourses test/beta. Reset CAS authentication base
# URLs if needed (see CLC-3917) and enable the
# test-only admin if needed (see CLC-5516).
#
# Make sure the normal shell environment is in place,
# since it may not be when running as a cron job.
#
######################################################

source "${HOME}/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$(date +"${PWD}/log/canvas_reconfigure_cas_authorization_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
source "${PWD}/.rvmrc"

export RAILS_ENV=${RAILS_ENV:-production}
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO

# JVM args per CalCentral convention
source "${PWD}/script/standard-calcentral-JVM-OPTS-profile"

cd deploy

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Run the CAS Authentication reconfiguration script..." | ${LOGIT}

bundle exec rake canvas:reconfigure_auth_url | ${LOGIT}

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Run the Test Admin reconfiguration script..." | ${LOGIT}

bundle exec rake canvas:add_test_admin | ${LOGIT}

exit 0
