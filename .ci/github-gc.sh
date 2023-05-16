#!/bin/bash

# Copyright (c) 2020 Damien Ciabrini
# This file is part of ngdevkit


# Disable verbose to prevent leaking credentials
set +x


help() {
    echo "Usage: $0 --user={user} --repo={repo} --token={github-api-token} --tag-regex={str} --commit={sha1}" >&2
    exit ${1:-0}
}

error() {
    echo "Error: $1" >&2
    help 1
}

check() {
    if [ $2 != 200 ] && [ $2 != 204 ]; then
        error "unexpected return from '$1' ($2). Aborting"
    fi
}

# ----------------- config parsing -----------------
#
USER=
REPO=
COMMIT=
GITHUB_TOKEN=${GH_TOKEN:-}
TAG_REGEX=
DRYRUN=

OPTS=$(/usr/bin/getopt -n $0 --long help,dry-run,user:,repo:,token:,tag-regex:,commit: -- $0 $@)
if [ $? != 0 ]; then
    error "parsing arguments failed"
fi

eval set -- "$OPTS"
while true; do
    case "$1" in
        --help) help;;
        --dry-run ) DRYRUN=1; shift ;;
        --user ) USER="$2"; shift 2 ;;
        --repo ) REPO="$2"; shift 2 ;;
        --token ) GITHUB_TOKEN="$2"; shift 2 ;;
        --tag-regex ) TAG_REGEX="$2"; shift 2 ;;
        --commit ) COMMIT="$2"; shift 2 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

if [ -z "$USER" ]; then
    error "no user specified"
fi
if [ -z "$REPO" ]; then
    error "no repository specified"
fi
if [ -z "$GITHUB_TOKEN" ]; then
    error "no token/password specified for GitHub API credentials"
fi
if [ -z "$TAG_REGEX" ]; then
    error "no tag regex specified, cannot filter which tags to remove"
fi
if [ -z "$COMMIT" ]; then
    COMMIT=$(git log --pretty=format:"%H" -1 HEAD)
    echo "No commit specified, defaulting to current branch's HEAD ($COMMIT)"
fi
CREDS=$USER:$GITHUB_TOKEN

# There used to be github release for nightly tags. These releases
# held NSIS binaries for the Windows installer. They are no longer
# being built in CI and replaced by MSYS2 packages.

# ----------------- garbage-collect tags -----------------
#
echo "Downloading tags list from $REPO..."
ret=$(curl -s -w "%{http_code}" -X GET -u $CREDS https://api.github.com/repos/$USER/$REPO/git/refs/tags -o references)
check "downloading tags list" $ret

# all tags to remove
tags_rm=$(jq -r '.[] | select(.ref | test("^refs/tags/'"${TAG_REGEX#^}"'")) | select (.object.sha != "'"$COMMIT"'") | .ref' references)
if [ -n "$tags_rm" ]; then
    echo "Deleting all the remaining tags matching '$TAG_REGEX'"
else
    echo "  (no old tag detected)"
fi
for i in $tags_rm; do
    commit_rm=$(jq -r '.[] | select (.ref == "'"$i"'") | .object.sha' references)
    echo ". Removing tag reference $i pointing to commit $commit_rm"
    if [ -z "$DRYRUN" ]; then
        ret=$(curl -s -w "%{http_code}" -X DELETE -u $CREDS https://api.github.com/repos/$USER/$REPO/git/$i)
        check "  removing tag reference $i" $ret
        sleep 0.5
    fi
done
