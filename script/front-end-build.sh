#!/bin/bash

# Install the correct node version (specified in package.json) on Travis
if [ -d "${HOME}/.nvm" ] && [ "${TRAVIS}" = "true" ]; then
  source ${HOME}/.nvm/nvm.sh
  nvm install $(node -e 'console.log(require("./package.json").engines.node.replace(/[^\d\.]+/g, ""))')
fi

echo "Node version: $(node --version)"
npm config set strict-ssl false
npm install --production || { echo "ERROR: npm install failed" ; exit 1 ; }

# Build and fingerprint front-end assets.
npm run build || { echo "ERROR: npm front-end assets build failed" ; exit 1 ; }

exit 0
