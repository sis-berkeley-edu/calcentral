#!/bin/bash

# Extremely primitive JRuby dependency handler for JARs outside Ruby's Gem community.
# 1. Check for the JAR libraries we expect to be in place.
# 2. If found, copy them into the application's "lib" directory for packaging into a WAR or KNOB.

JRUBY_LIB="${HOME}/.rvm/rubies/${RUBY_VERSION}/lib"

TARGET="${PWD}/lib/ojdbc8.jar"

for f in "ojdbc8.jar" "ojdbc7.jar"
do
  CANDIDATE="${JRUBY_LIB}/${f}"
  if [[ -f ${CANDIDATE} ]] ; then
    echo "`date`: Copying ${CANDIDATE} to ${TARGET}"
    cp -f "${CANDIDATE}" "${TARGET}"
    exit 0
  fi
done

echo "`date`: Did not find ojdbc8.jar; Oracle DB will not be available"

exit 1
