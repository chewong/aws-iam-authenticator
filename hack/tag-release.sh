#!/bin/bash -xe

# Copyright 2022 The Kubernetes Authors.
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

VERSION=$(cat version.txt)

if [[ ! "${VERSION}" =~ ^([0-9]+[.][0-9]+)[.]([0-9]+)(-(alpha|beta)[.]([0-9]+))?$ ]]; then
  echo "Version ${VERSION} must be 'X.Y.Z', 'X.Y.Z-alpha.N', or 'X.Y.Z-beta.N'"
  exit 1
fi

BRANCH=$(git branch --show-current)

if [[ ! "${BRANCH}" =~ ^(release-)([0-9]+[.][0-9]+)$ ]]; then
    echo "Automatic tag creation must take place on a release branch."
    exit 1
fi

BRANCH_MAJ_MIN=${BRANCH#release-}
VERSION_MAJ_MIN=$(echo ${VERSION} | sed -Ee 's/-(alpha|beta)\.[0-9]+$//' | sed -Ee 's/\.[0-9]+$//')

if [[ ! "${BRANCH_MAJ_MIN}" = $VERSION_MAJ_MIN ]]; then
    echo "Major minor version of tag must match major minor version of branch."
    exit 1
fi

if [ "$(git tag -l "v${VERSION}")" ]; then
  echo "Tag v${VERSION} already exists"
  exit 0
fi

git tag -a -m "Release ${VERSION}" "v${VERSION}"
git push origin "v${VERSION}"