#!/bin/bash -l

set -e

GIT_BRANCH=$1

exec sudo -i -u {{ user }} /bin/bash /home/{{ user }}/shared/deploy/static.sh "$GIT_BRANCH"
