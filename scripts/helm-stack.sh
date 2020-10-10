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

HELM_STACK="${HELM_STACK:-"helm-stack"}"

_run_helm_stack() {
  if command -v "${HELM_STACK}"; then
    ${HELM_STACK} "$@"
    return
  fi

  if [ -f "$(go env GOPATH)/bin/helm-stack" ]; then
    "$(go env GOPATH)/bin/helm-stack" "$@"
    return
  fi

  container_path_env="/opt/helm/${HELM_VERSION:-"v3"}:/opt/kube/${KUBERNETES_VERSION:-"v1.18"}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  docker run -t --rm -v "$(pwd):$(pwd)" -w "$(pwd)" \
	    -e PATH="${container_path_env}" --entrypoint /bin/sh \
      arhatdev/helm-stack:latest \
      -c "/helm-stack $*"
}

run() {
  _run_helm_stack "$@"
}

# shellcheck disable=SC2068
run $@
