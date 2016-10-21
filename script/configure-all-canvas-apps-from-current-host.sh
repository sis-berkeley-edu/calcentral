#!/bin/bash

######################################################
#
# Configure, or reconfigure, all LTI apps on the
# linked bCourses server and provided by the current
# CalCentral server. This will add any new apps and
# overwrite current LTI keys and secrets.
#
# Make sure the normal shell environment is in place,
# since it may not be when running as a cron job.
#
######################################################

source "${HOME}/.bash_profile"

cd $( dirname "${BASH_SOURCE[0]}" )/..

LOG=$(date +"${PWD}/log/canvas_configure_all_apps_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
source "${PWD}/.rvmrc"

export RAILS_ENV=${RAILS_ENV:-production}
export LOGGER_STDOUT=only
export LOGGER_LEVEL=INFO

# Set JVM args per CalCentral convention
source "${PWD}/script/standard-calcentral-JVM-OPTS-profile"

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Run LTI application configuration script..." | ${LOGIT}

cd deploy

bundle exec rake canvas:configure_all_apps_from_current_host | ${LOGIT}

exit 0
