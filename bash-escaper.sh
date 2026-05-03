#!/bin/sh

. "$(git rev-parse --show-toplevel || echo .)/templates/version.sh"
sed -E 's/[$\\]/\\&/g;s/^VERSION=\?\?\?/VERSION='"$VERSION"'/'
