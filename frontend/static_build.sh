#!/bin/bash
set -e
print_usage() {
    echo "static_build.sh [Options]"
    echo "    Combines static resources from upstream/amundsen_application/static and frontend/configs/static by copying all"
    echo "    files into a temp directory, installing, building, and deploying from there."
}

destination="/usr/local/amundsen/frontend/configs/.custom_build"
upstream_static="/usr/local/amundsen/frontend/upstream/amundsen_application/static"
private_static="/usr/local/amundsen/frontend/configs/static"

echo "Cleaning previous build in: ${destination}/"
rm -rf ${destination}
mkdir ${destination}

echo "Copying base static files from ${upstream_static} to ${destination}"
cp -TRv ${upstream_static} ${destination}

echo "Copying custom static files from ${private_static} to ${destination}"
cp -TRv ${private_static} ${destination}

echo "Installing Node modules in ${destination}"
pushd ${destination} || exit

npm install
npm rebuild node-sass

echo "Running Webpack Build in Production Mode"
npm run build

popd || exit
