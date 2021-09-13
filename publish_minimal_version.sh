#!/bin/bash

set -euo pipefail

# Given a VERSION (env var) like v4.4.1, creates a new branch
# "${VERSION}-minimal" that only includes goredis drivers
# for Redis v8.
#
# If no env var is specified, defaults to the latest version.

: "${VERSION:=$(git tag | tail -n 1)}"

if ! git diff --quiet; then
  echo "Working tree is dirty; exiting." >&2
  exit 1
fi

echo "Fetching from https://github.com/go-redsync/redsync..."

git remote add upstream https://github.com/go-redsync/redsync || true
git fetch upstream

git checkout master
git merge upstream/master

function cleanup() {
  git reset --hard HEAD
  git checkout master
}
trap cleanup EXIT

echo "Checking out branch for $VERSION"
git checkout -b "release-$VERSION-minimal"

rm -r examples/
rm -r redis/redigo
rm -r redis/goredis/v7
rm redis/goredis/*.go
rm ./*_test.go
go mod tidy

git add .
git commit -m "Publish $VERSION-minimal"
git tag "$VERSION-minimal"
git push --tags
