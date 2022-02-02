#!/bin/bash

set -e

if [ -n "$DIST_VERSION" ]; then
    version=$DIST_VERSION
#Mod
elif [ -n "$npm_package_version" ]; then
    version=$npm_package_version
#Mod-End
else
    version=`git describe --dirty --tags || echo unknown`
fi

yarn clean
VERSION=$version yarn build

# include the sample config in the tarball. Arguably this should be done by
# `yarn build`, but it's just too painful.
cp config.sample.json webapp/

#Mod
if [[ ${version} =~ ^v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(-.+)?$ ]]; then
    echo ${version:1} > webapp/version.html
else
    echo ${version} > webapp/version.html
fi
#Mod-End

mkdir -p dist
cp -r webapp element-$version

# Just in case you have a local config, remove it before packaging
rm element-$version/config.json || true

$(dirname $0)/normalize-version.sh ${version} > element-$version/version

tar chvzf dist/element-$version.tar.gz element-$version
rm -r element-$version

echo
echo "Packaged dist/element-$version.tar.gz"
