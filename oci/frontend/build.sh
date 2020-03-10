#!/bin/bash

# ---
# Based on : https://github.com/SUSE/Portus/wiki/The-frontend-of-Portus
# And corrected...
# ---

echo "This script will build portus frontend"
ls -allh > ./pwd.ls.before.build
npm install
yarn install
yarn check
#because the bloody yarn command is interactively watching
# npm install -g webpack
webpack --config config/webpack.js
# yarn run webpack

cp -fR ./* /portus/dev/share

echo "---------------------------------------------------------------"
echo "The FRONTEND BUILD SHOULD NOW BE FINISHED : "
echo "---------------------------------------------------------------"
echo ''
echo "---------------------------------------------------------------"
echo "------ content before build : "
echo "---------------------------------------------------------------"
cat ./pwd.ls.before.build
echo "---------------------------------------------------------------"
echo "------ content after build, in [/portus/dev/share] : "
echo "---------------------------------------------------------------"
echo "---------------------------------------------------------------"
ls -allh
echo "---------------------------------------------------------------"
