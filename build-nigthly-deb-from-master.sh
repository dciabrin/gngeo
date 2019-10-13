#!/bin/bash

set -ex

export DEBFULLNAME="bot"
export DEBEMAIL="bot@address.local"

PROJECT=ngdevkit-gngeo
UPSTREAM_VERSION=$(git grep AC_INIT origin/ngdevkit:configure.ac | sed -ne 's/.*\[\(.*\)\].*/\1/p')
read DATE SHORTHASH LONGHASH <<<$(git log -1 --date=format:"%Y%m%d%H%M" --pretty=format:"%cd %h %H" origin/ngdevkit)
DEB_VERSION=${UPSTREAM_VERSION}~${DATE}.${SHORTHASH}

dch -v ${DEB_VERSION}-1 -U "Nightly build from tag ${LONGHASH}"
git archive --format=tar --prefix=${PROJECT}-${DEB_VERSION}/ origin/ngdevkit | gzip -c > ${PROJECT}_${DEB_VERSION}.orig.tar.gz
tar xf ${PROJECT}_${DEB_VERSION}.orig.tar.gz
cd ${PROJECT}-${DEB_VERSION}
cp -a ../debian .
dpkg-buildpackage -rfakeroot -us -uc
