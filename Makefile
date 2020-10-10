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

include scripts/check.mk
include scripts/lint.mk

CLUSTER_NAME ?= all
KUBERNETES_VERSION ?= v1.18

HELM_STACK := docker run -t --rm -v "$(shell pwd):$(shell pwd)" -w "$(shell pwd)" \
	-e PATH="/opt/helm/v3:/opt/kube/${KUBERNETES_VERSION}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
	--entrypoint /bin/sh arhatdev/helm-stack:latest -c "/helm-stack

ensure:
	${HELM_STACK} ensure"

gen:
	${HELM_STACK} gen ${CLUSTER_NAME}"

clean:
	${HELM_STACK} clean"
