#!/bin/sh

# Copyright 2020 The arhat.dev Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

files() {
  make ensure
  make gen
  if ! git diff --exit-code; then
    echo "generated file not up to date"
    exit 1
  fi

  make clean
  if ! git diff --exit-code; then
    echo "file not cleaned up"
    exit 1
  fi
}

# shellcheck disable=SC2068
$@
