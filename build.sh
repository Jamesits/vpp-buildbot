#!/bin/bash
set -Eeuo pipefail
set -x

docker run \
    -v "$(pwd)":/root \
    --workdir "/root" \
    --name vpp-builder \
    --env-file <( env| cut -f1 -d= ) \
    $(CONTAINER) bash /root/build_docker.sh
