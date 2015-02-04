# Riak
#
# VERSION       1.0.3

FROM phusion/baseimage:0.9.14
MAINTAINER Shane Davidson <shaned2222@gmail.com>

# Environmental variables
ENV DEBIAN_FRONTEND noninteractive
ENV RIAK_VERSION 2.0.2-1

ENV RIAK_LOG_CONSOLE console
ENV RIAK_LOG_CONSOLE_LEVEL info
ENV RIAK_LOG_CRASH on
ENV RIAK_LOG_CRASH_MAXIMUM_MESSAGE_SIZE 64KB
ENV RIAK_LOG_CRASH_SIZE 10MB
ENV RIAK_LOG_CRASH_ROTATION $D0
ENV RIAK_LOG_CRASH_ROTATION_KEEP 5
ENV RIAK_NODENAME riak@127.0.0.1
ENV RIAK_DISTRIBUTED_COOKIE riak
ENV RIAK_ERLANG_ASYNC_THREADS 64
ENV RIAK_ERLANG_MAX_PORTS 65536
ENV RIAK_ERLANG_SCHEDULERS_FORCE_WAKEUP_INTERVAL 500
ENV RIAK_ERLANG_SCHEDULERS_COMPACTION_OF_LOAD true
ENV RIAK_ERLANG_SCHEDULERS_UTILIZATION_BALANCING false
ENV RIAK_RING_SIZE 64
ENV RIAK_TRANSFER_LIMIT 2
ENV RIAK_STRONG_CONSISTENCY on
ENV RIAK_PROTOBUF_BACKLOG 128
ENV RIAK_ANTI_ENTROPY active
ENV RIAK_STORAGE_BACKEND leveldb
ENV RIAK_OBJECT_FORMAT 1
ENV RIAK_OBJECT_SIZE_WARNING_THRESHOLD 5MB
ENV RIAK_OBJECT_SIZE_MAXIMUM 50MB
ENV RIAK_OBJECT_SIBLINGS_WARNING_THRESHOLD 25
ENV RIAK_OBJECT_SIBLINGS_MAXIMUM 100
ENV RIAK_CONTROL on
ENV RIAK_CONTROL_AUTH_MODE off
ENV RIAK_CONTROL_AUTH_USER_ADMIN_PASSWORD pass
ENV RIAK_LEVELDB_MAXIMUM_MEMORY_PERCENT 70
ENV RIAK_SEARCH on
ENV RIAK_SOLR_START_TIMEOUT 30s
ENV RIAK_SOLR_JVM_OPTIONS -d64 -Xms1g -Xmx1g -XX:+UseCompressedOops
ENV RIAK_ERLANG_DISTRIBUTION_PORT_RANGE_MINIMUM 8088
ENV RIAK_ERLANG_DISTRIBUTION_PORT_RANGE_MAXIMUM 8092
ENV RIAK_JAVASCRIPT_MAXIMUM_STACK_SIZE 32MB
ENV RIAK_JAVASCRIPT_MAXIMUM_HEAP_SIZE 16MB
ENV RIAK_JAVASCRIPT_HOOK_POOL_SIZE 4
ENV RIAK_JAVASCRIPT_REDUCE_POOL_SIZE 6
ENV RIAK_JAVASCRIPT_MAP_POOL_SIZE 8

# Install Java 7
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y software-properties-common && \
    apt-add-repository ppa:webupd8team/java -y && apt-get update -qq && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java7-installer

# Install Riak
RUN curl https://packagecloud.io/install/repositories/basho/riak/script.deb | bash
RUN apt-get install -y riak=${RIAK_VERSION}

# Install envsubst for injecting ENV variables into riak config
RUN apt-get install -y gettext

# Install Etcdctl
RUN curl -L https://github.com/coreos/etcd/releases/download/v0.4.5/etcd-v0.4.5-linux-amd64.tar.gz -o /tmp/etcd-v0.4.5-linux-amd64.tar.gz
RUN cd /tmp && gzip -dc etcd-v0.4.5-linux-amd64.tar.gz | tar -xof -
RUN cp -f /tmp/etcd-v0.4.5-linux-amd64/etcdctl /usr/local/bin
RUN rm -rf /tmp/etcd-v0.4.5-linux-amd64.tar.gz

# Cleanup
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add Basho Riak configuration
RUN rm -f /etc/riak/riak.conf
ADD etc/riak/riak.conf.envsubst /etc/riak/
ADD etc/riak/riak.conf.tmpl /etc/riak/

# Make Riak's data and log directories volumes
VOLUME /var/lib/riak
VOLUME /var/log/riak

# Open ports for HTTP and Protocol Buffers
EXPOSE 8098 8087

# Add boot script
ADD bin/boot /bin/
RUN chmod 755 /bin/boot
CMD [ "/bin/boot" ]
