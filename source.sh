#!/bin/env bash

] version.sh

] colors.sh

] argparse.sh

] rootcheck.sh

] fn_depscheck.sh

depscheck || exit 1

echo "VERSION: $VERSION"
