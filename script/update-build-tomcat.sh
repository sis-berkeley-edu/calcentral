#!/bin/bash

######################################################
#
# Modified from update_build.sh for Tomcat deployment
#
######################################################

HOST=$(uname -n)
MYSCRIPT=`basename "$0"| sed "s/\..*//g"`

# If the WAR_URL is not defined in the environment the deploy will abort for safety, we do not want to default to any branch
WAR_URL=${WAR_URL}
MAX_ASSET_AGE_IN_DAYS=${MAX_ASSET_AGE_IN_DAYS:="45"}
DOC_ROOT="/var/www/html/calcentral"

CC_LOG_DIR="$HOME/calcentral/log"
LOG=$(date +"${CC_LOG_DIR}/update-build-tomcat_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"



function show_help {

    cat <<EOF

CalCentral Code Deploy script usage:
------------------------------------

By default, it deploys code without a server restart

   $ ./${MYSCRIPT}

To Deploy offline with a server restart:
----------------------------------------

   $ ./${MYSCRIPT} -o offline

     Note: The parameter needs to be written exactly as shown in the help above, any other keyword will not work.

EOF

}


while getopts o:h option ; do
    case $option in
        o) OFFLINE=$OPTARG
           if [ "${OFFLINE}" != "offline" ] ; then
           echo "Offline parameter = ${OFFLINE}"
           show_help
           fi
           ;;
        *) show_help
           exit 1 ;;
    esac
done

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
source .rvmrc

# If the WAR_URL is not defined in the environment the deploy will abort for safety, we do not want to default to any branch
if [ -z "$WAR_URL" ] ; then
     echo "WAR_URL variable not defined in the node"| ${LOGIT}
     exit 1
fi

# Update source tree (from which these scripts run)

# Change dir to the calcentral home dir to update the source code from GitHub
cd ${CLC_HOME} || exit 1
#####./script/update-source.sh

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

if [ -n "${OFFLINE}" ] ; then
   # Check status of Tomcat
   ~/bin/tomcat9-calcentral.sh status | grep "is running"

   TOMRETURN=$?

   # Stop Tomcat
   if [ $TOMRETURN -eq 0 ] ; then
      echo "$(date): Stopping CalCentral..." | ${LOGIT}
      ~/bin/tomcat9-calcentral.sh stop | ${LOGIT} 2>&1
   else
      echo "WARNING: Tomcat not running. No shutdown attempted, will proceed with code deploy" | ${LOGIT}
   fi
fi

# New location where the war file will be downloaded to
cd ${TOMCAT_DEPLOY} || exit 1

echo | ${LOGIT}
echo "------------------------------------------" | ${LOGIT}
echo "$(date): Fetching new calcentral.war from ${WAR_URL}..." | ${LOGIT}

# For now renaming the calcentral.war file to ROOT.war until we decide if we will create a sepatate context to deploy
# it is using the default Tomcat ROOT location
curl -k -s ${WAR_URL} > ROOT.war | ${LOGIT} || exit 1
echo | ${LOGIT}


if [ -n "${OFFLINE}" ] ; then
   # Start Tomcat which deploys the war file
   ~/bin/tomcat9-calcentral.sh start | ${LOGIT}
fi

# Wait for 20 seconds before running checks that it was deployed
sleep 20

if [ ! -d "ROOT/WEB-INF/versions" ]; then
  echo "$(date): ERROR: Missing or malformed calcentral.war file!" | ${LOGIT}
  exit 1
fi
echo "Last commit in calcentral.war deployed:" | ${LOGIT}
cat ${TOMCAT_DEPLOY}/ROOT/WEB-INF/versions/git.txt | ${LOGIT}

# Fix permissions on files that need to be executable
##chmod u+x ./script/*
##chmod u+x ./vendor/bundle/jruby/2.3.0/bin/*

# The assets are now under webapps/ROOT - TOMCAT_DEPLOY variable
# We made a cd to $TOMCAT_DEPLOY earlier

echo "Copying assets into ${DOC_ROOT}" | ${LOGIT}
##cp -Rvf public/assets ${DOC_ROOT} | ${LOGIT}
cp -Rvf ${TOMCAT_DEPLOY}/ROOT/WEB-INF/public/assets ${DOC_ROOT} | ${LOGIT}

echo "Deleting old assets from ${DOC_ROOT}/assets" | ${LOGIT}

#find ${DOC_ROOT}/assets -type f -mtime +${MAX_ASSET_AGE_IN_DAYS} -delete | ${LOGIT}
find ${DOC_ROOT}/assets -type f -mtime +${MAX_ASSET_AGE_IN_DAYS} -delete | ${LOGIT}

echo "Copying bCourses static files into ${DOC_ROOT}" | ${LOGIT}
##cp -Rvf public/canvas ${DOC_ROOT} | ${LOGIT}
cp -Rvf ${TOMCAT_DEPLOY}/ROOT/WEB-INF/public/canvas ${DOC_ROOT} | ${LOGIT}

echo "Copying OAuth static files into ${DOC_ROOT}" | ${LOGIT}
##cp -Rvf public/oauth ${DOC_ROOT} | ${LOGIT}
cp -Rvf ${TOMCAT_DEPLOY}/ROOT/WEB-INF/public/oauth ${DOC_ROOT} | ${LOGIT}

# Fix file permissins for Tomcat deploys
cd /var/www/html/calcentral/

chmod -R o+r *

chmod -R g+w *

# Give execute to Others for directories only
find /var/www/html/calcentral/ -type d -execdir chmod o+x {} \;

###exit 0
