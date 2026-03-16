#!/usr/bin/env bash
set -x
export AEP_LOCATION="${PWD}"
export SG_DIRECTORY="/tmp/site-generator"

if [ ! -d "${SG_DIRECTORY}" ]; then
    git clone git@github.com:infusionsoft/aep-site-generator.git "${SG_DIRECTORY}"
fi

cd "${SG_DIRECTORY}" || exit
npm install
npm run generate
npm run build
