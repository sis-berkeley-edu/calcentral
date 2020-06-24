#!/bin/bash

HOST=$(uname -n)
MYSCRIPT=`basename "$0"| sed "s/\..*//g"`
CC_LOG_DIR="$HOME/calcentral/log"
LOG=$(date +"${CC_LOG_DIR}/${MYSCRIPT}_%Y-%m-%d.log")
LOGIT="tee -a ${LOG}"

# Define the deploy script name and location
DEPLOY_SCRIPT="/home/app_calcentral/calcentral/script/update-build-tomcat.sh"

function show_help {

    cat <<EOF

CalCentral Code Deploy script usage:
------------------------------------

By default, it deploys code restarting the Apache webserver to do a rolling code deploy/restart

   $ ./${MYSCRIPT}

To Deploy without an Apache server restart
------------------------------------------

   $ ./${MYSCRIPT} -w online

     Note: The parameter needs to be written exactly as shown in the help above, any other keyword will not work.

EOF

}

function exitfail {
  echo | ${LOGIT}
  echo "$(date): [ERROR] ${1:-"Unknown Error"}" | ${LOGIT}
  echo | ${LOGIT}
  exit 1
}

function log_error {
  echo | ${LOGIT}
  echo "$(date): [ERROR] ${1}" | ${LOGIT}
  echo | ${LOGIT}
}

function log_info {
  echo | ${LOGIT}
  echo "$(date): [INFO] ${1}" | ${LOGIT}
  echo | ${LOGIT}
}


while getopts w:h option ; do
    case $option in
        w) WEBSERVER=$OPTARG
           if [ "${WEBSERVER}" != "online" ] ; then
           echo "Webserver parameter = ${WEBSERVER}"
           show_help
           fi
           ;;
        *) show_help
           exit 1 ;;
    esac
done

# Enable rvm and use the correct Ruby version and gem set.
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && . "${HOME}/.rvm/scripts/rvm"
#source .rvmrc
source ~/calcentral/.rvmrc

# Update source tree (from which these scripts run)
# Change dir to the calcentral home dir to update the source code from GitHub
cd ${CLC_HOME} || exitfail "Error changing to CalCentral HOME directory"

./script/update-source.sh || exitfail "Error updating source code, aborting deploy process"

# Shutdown Apache
if [ -z "${WEBSERVER}" ] ; then
   ~/bin/apache_restart.sh stop || exitfail "Error shutting down Apache, aborting deploy process"
fi

# Call the Deploy script
${DEPLOY_SCRIPT} -o offline || exitfail "Error Deploying the code, aborting process without bringing Apache back up"

# Startup Apache
if [ -z "${WEBSERVER}" ] ; then
  ~/bin/apache_restart.sh start || exitfail "Error starting Apache, aborting deploy process"
fi

# Clear memcached - We are alredy under the CalCentral home directory
# bundle exec rake memcached:clear || exitfail "Error clearing the memcached"

echo "End Deploy on node: ${HOST}"| ${LOGIT}
echo "------------------------------------------" | ${LOGIT}

exit 0
