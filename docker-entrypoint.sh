#!/bin/bash
set -e

if [ "$1" == 'teamcity-server.sh' ]; then
	chown -R teamcity /var/{lib,log}/teamcity
	set -- gosu teamcity "$@"
fi

exec "$@"
