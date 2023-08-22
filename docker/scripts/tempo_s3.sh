#!/usr/bin/env sh
set -e

S3_BUCKET=$(echo $VCAP_SERVICES | jq -r '.["hsdp-s3"][0]'.credentials.bucket)
S3_ENDPOINT=$(echo $VCAP_SERVICES | jq -r '.["hsdp-s3"][0]'.credentials.endpoint)
S3_API_KEY=$(echo $VCAP_SERVICES | jq -r '.["hsdp-s3"][0]'.credentials.api_key)
S3_SECRET_KEY=$(echo $VCAP_SERVICES | jq -r '.["hsdp-s3"][0]'.credentials.secret_key)
S3_URI=$(echo $VCAP_SERVICES | jq -r '.["hsdp-s3"][0]'.credentials.uri)

cat <<EOF > /sidecars/etc/tempo.yaml

auth_enabled: false

server:
  http_listen_port: 3100

query_frontend:
  # When increasing concurrent_jobs, also increase the queue size per tenant,
  # or search requests will be cause 429 errors.
  max_outstanding_per_tenant: 200

  search:
    # At larger scales, increase the number of jobs attempted simultaneously,
    # per search query.
    concurrent_jobs: 200

distributor:
  receivers:                           # this configuration will listen on all ports and protocols that tempo is capable of.
    jaeger:                            # the receives all come from the OpenTelemetry collector.  more configuration information can
      protocols:                       # be found there: https://github.com/open-telemetry/opentelemetry-collector/tree/master/receiver
        thrift_http:                   #
        grpc:                          # for a production deployment you should only enable the receivers you need!
        thrift_binary:
        thrift_compact:
    zipkin:
    otlp:
      protocols:
        http:
        grpc:
    opencensus:

ingester:
  trace_idle_period: 10s               # the length of time after a trace has not received spans to consider it complete and flush it
  max_block_bytes: 1_000_000           # cut the head block when it hits this size or ...
  max_block_duration: 5m               #   this much time passes

compactor:
  compaction:
    compaction_window: 1h              # blocks in this time window will be compacted together
    max_block_bytes: 100_000_000        # maximum size of compacted blocks
    block_retention: 1h
    compacted_block_retention: 10m

querier:
  # Greatly increase the amount of work each querier will attempt
  max_concurrent_queries: 20

storage:
  trace:
    backend: s3                        # backend configuration to use
    block:
      bloom_filter_false_positive: .05 # bloom filter false positive rate.  lower values create larger filters but fewer false positives
    wal:
      path: /tmp/tempo/wal             # where to store the the wal locally
    s3:
      bucket: "${S3_BUCKET}"                    # how to store data in s3
      endpoint: "${S3_ENDPOINT}"
      access_key: "${S3_API_KEY}"
      secret_key: "${S3_SECRET_KEY}"
      insecure: false
      # For using AWS, select the appropriate regional endpoint and region
      # endpoint: s3.dualstack.us-west-2.amazonaws.com
      # region: us-west-2
    pool:
      max_workers: 100                 # the worker pool mainly drives querying, but is also used for polling the blocklist
      queue_depth: 10000
EOF

exec /sidecars/bin/tempo "$@"
