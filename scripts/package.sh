#!/bin/bash

set -e

if [ -n "$DIST_VERSION" ]; then
    version=$DIST_VERSION
elif [ -n "$npm_package_version" ]; then
    version=$npm_package_version
else
    version=`git describe --dirty --tags || echo unknown`
fi

yarn clean
yarn build

# include the sample config in the tarball. Arguably this should be done by
# `yarn build`, but it's just too painful.
cp config.sample.json webapp/

# if $version looks like semver with leading v, strip it before writing to file
if [[ ${version} =~ ^v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(-.+)?$ ]]; then
    echo ${version:1} > webapp/version.html
else
    echo ${version} > webapp/version.html
fi

mkdir -p dist
cp -r webapp element-$version

# Just in case you have a local config, remove it before packaging
rm element-$version/config.json || true

# if $version looks like semver with leading v, strip it before writing to file
if [[ ${version} =~ ^v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(-.+)?$ ]]; then
    echo ${version:1} > element-$version/version
else
    echo ${version} > element-$version/version
fi

tar chvzf dist/element-$version.tar.gz element-$version
rm -r element-$version

echo
echo "Packaged dist/element-$version.tar.gz"
