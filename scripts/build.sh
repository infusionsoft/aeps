#!/usr/bin/env bash
set -x
export AEP_LOCATION="${PWD}"
export SG_DIRECTORY="/tmp/site-generator"

if [ ! -d "${SG_DIRECTORY}" ]; then
    git clone https://github.com/aep-dev/site-generator.git "${SG_DIRECTORY}"
fi

cd "${SG_DIRECTORY}" || exit
# make rules / website folder
mkdir -p src/content/docs/tooling/website
npm install
npx playwright install --with-deps chromium
npm run generate
npm run build
