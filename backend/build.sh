#!/usr/bin/env bash
set -eux

docker image build -t org.rm3l/dev-feed-backend:0.4.1 .
