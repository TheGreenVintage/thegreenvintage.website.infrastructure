#!/bin/bash -l

set -e

GIT_BRANCH=$1

exec sudo -u {{ user }} /bin/bash /home/{{ user }}/shared/deploy/static.sh "$GIT_BRANCH"
