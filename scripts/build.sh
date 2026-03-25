#!/usr/bin/env bash
set -euo pipefail
export AEP_LOCATION="${PWD}"
export SG_DIRECTORY="/tmp/site-generator"
export SG_REPO_URL="${SG_REPO_URL:-https://github.com/infusionsoft/aep-site-generator.git}"

if [ ! -d "${SG_DIRECTORY}" ]; then
    git clone "${SG_REPO_URL}" "${SG_DIRECTORY}"
else
    # Keep local builds aligned with the latest upstream state.
    git -C "${SG_DIRECTORY}" remote set-url origin "${SG_REPO_URL}"
    if ! git -C "${SG_DIRECTORY}" pull --ff-only; then
        echo "Error: unable to fast-forward ${SG_DIRECTORY}." >&2
        echo "This usually means local changes or branch divergence in the cached checkout." >&2
        echo "Fix it by resetting the cache or reconciling the repo, then rerun build:" >&2
        echo "  rm -rf \"${SG_DIRECTORY}\"" >&2
        echo "  ./scripts/build.sh" >&2
        exit 1
    fi
fi

cd "${SG_DIRECTORY}" || exit
npm install
npm run generate
npm run build
