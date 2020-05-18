#!/bin/bash

######################################################
#
# Download and deploy the "calcentral.knob" (see WAR_URL).
#
######################################################

HOST=$(uname -n)
if [[ "${HOST}" = *calcentral* ]]; then
  APP_MODE="calcentral"
else
  APP_MODE="junction"
fi
WAR_URL=${WAR_URL:="https://bamboo.media.berkeley.edu/bamboo/browse/MYB-MVPWAR/latest/artifact/JOB1/warfile/calcentral.knob"}
MAX_ASSET_AGE_IN_DAYS=${MAX_ASSET_AGE_IN_DAYS:="45"}
DOC_ROOT="/var/www/html/${APP_MODE}"

LOG=$(date +"${PWD}/log/update-build_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"

cd $( dirname "${BASH_SOURCE[0]}" )/..

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
source .rvmrc

# Update source tree (from which these scripts run)
./script/update-source.sh

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Stopping CalCentral..." | ${LOGIT}

./script/stop-torquebox.sh

rm -rf deploy
mkdir deploy
cd deploy

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Fetching new calcentral.knob from ${WAR_URL}..." | ${LOGIT}

curl -k -s ${WAR_URL} > calcentral.knob

echo "Unzipping knob..." | ${LOGIT}

jar xf calcentral.knob

if [ ! -d "versions" ]; then
  echo "$(date): ERROR: Missing or malformed calcentral.knob file!" | ${LOGIT}
  exit 1
fi
echo "Last commit in calcentral.knob:" | ${LOGIT}
cat versions/git.txt | ${LOGIT}

# Fix permissions on files that need to be executable
chmod u+x ./script/*
chmod u+x ./vendor/bundle/jruby/2.3.0/bin/*
find ./vendor/bundle -name standalone.sh | xargs chmod u+x

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Deploying new CalCentral knob..." | ${LOGIT}

bundle exec torquebox deploy calcentral.knob --env=production | ${LOGIT}

echo "Copying assets into ${DOC_ROOT}" | ${LOGIT}
cp -Rvf public/assets ${DOC_ROOT} | ${LOGIT}

echo "Deleting old assets from ${DOC_ROOT}/assets" | ${LOGIT}
find ${DOC_ROOT}/assets -type f -mtime +${MAX_ASSET_AGE_IN_DAYS} -delete | ${LOGIT}

echo "Copying bCourses static files into ${DOC_ROOT}" | ${LOGIT}
cp -Rvf public/canvas ${DOC_ROOT} | ${LOGIT}

echo "Copying OAuth static files into ${DOC_ROOT}" | ${LOGIT}
cp -Rvf public/oauth ${DOC_ROOT} | ${LOGIT}

exit 0
