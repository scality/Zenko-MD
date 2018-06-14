#!/usr/bin/env bash

set -e

if [ ! -f config.json.in ] ; then
    # Save the configuration file as a template
    # if it doesn't already exist
    cp config.json config.json.in
fi

JQ_FILTER="."

# Metadata Proxy Server parameters
if [ -n "$MDP_BIND_ADDRESS" ] ; then
    JQ_FILTER="${JQ_FILTER}|.bindAddress=\"${MDP_BIND_ADDRESS}\""
fi
if [ -n "$MDP_LISTEN_PORT" ] ; then
    JQ_FILTER="${JQ_FILTER}|.port=${MDP_LISTEN_PORT}"
fi
if [ -n "$MDP_WORKERS" ] ; then
    JQ_FILTER="${JQ_FILTER}|.workers=${MDP_WORKERS}"
fi
if [ -n "$LOG_LEVEL" ] ; then
    JQ_FILTER="${JQ_FILTER}|.log.logLevel=\"${LOG_LEVEL}\""
    JQ_FILTER="${JQ_FILTER}|.log.dumpLevel=\"${LOG_LEVEL}\""
fi

# Metadata Proxy Server driver parameters
if [ -n "$S3METADATA" ] ; then
    export MDP_DRIVER=$S3METADATA
fi
if [ -n "$MONGODB_HOSTS" ] ; then
    JQ_FILTER="${JQ_FILTER}|.mongodb.replicaSetHosts=\"${MONGODB_HOSTS}\""
fi
if [ -n "$MONGODB_RS" ] ; then
    JQ_FILTER="${JQ_FILTER}|.mongodb.replicatSet=\"${MONGODB_RS}\""
fi
if [ -n "$MONGODB_DATABASE" ] ; then
    JQ_FILTER="${JQ_FILTER}|.mongodb.database=\"${MONGODB_DATABASE}\""
fi

OUTSTANDING_CONFIG="$(mktemp config.json.XXXXXX)"
if [ -z "$OUTSTANDING_CONFIG" ] ; then
    echo "mktemp failed to create a new file" >&2
    exit 1
fi

jq "$JQ_FILTER" config.json.in > "$OUTSTANDING_CONFIG"
mv "$OUTSTANDING_CONFIG" config.json

exec "$@"
