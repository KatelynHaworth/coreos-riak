# coreos-riak


Install Service: (install-riak.service)
```
[Unit]
After=docker.service
Description=Download <%= @cloud_config.capitalize %> Docker image
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/docker pull shaned2222/coreos-riak
ExecStart=/bin/echo Riak Docker Image Installed

[X-Fleet]
MachineMetadata=type=riak
```

Run Service (riak@.service)
```


```



Etcd Bind Service (riak-discovery@.service)
```
[Unit]
Description=Riak Etcd Bind Service
BindsTo=riak@%i.service
After=riak@%i.service

[Service]
EnvironmentFile=/etc/environment
ExecStart=/bin/sh -c "while true; do etcdctl set /riak/machines/$private_ipv4 %i --ttl 60;sleep 45;done"
ExecStop=/usr/bin/etcdctl rm /riak/machines/$private_ipv4

[X-Fleet]
MachineOf=riak@%i.service
```
