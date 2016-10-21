#!/bin/bash

######################################################
#
# Update all users in Canvas
#
# Make sure the normal shell environment is in place,
# since it may not be when running as a cron job.
#
######################################################

source "${HOME}/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$(date +"${PWD}/log/canvas_new_user_sync_%Y-%m-%d.log")
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
echo "$(date): Run the new campus user sync script..." | ${LOGIT}

cd deploy

bundle exec rake canvas:new_user_sync | ${LOGIT}

exit 0
