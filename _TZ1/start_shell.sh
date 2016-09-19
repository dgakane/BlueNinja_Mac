#!/bin/bash -ex

export TZ1_BASE=$(cd $(dirname ${BASH_SOURCE}) && pwd)/
export PATH="$PATH:${TZ1_BASE}scripts"

export TOOL_DIR=${TZ1_BASE}tools/bin/
export SDK_DIR=${TZ1_BASE}sdk/




