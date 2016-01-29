#!/bin/bash
PUBLIC_IPV4=$(curl -qs http://169.254.169.254/2014-11-05/meta-data/public-ipv4)
[ -n "$PUBLIC_IPV4" ] || PUBLIC_IPV4=$(curl -qs ipinfo.io/ip)
PUBLIC_IPV6="$(printf '2002:%02x%02x:%02x%02x' $(echo $PUBLIC_IPV4 | tr '.' ' ' ))"

if ! grep ipv6 /etc/default/docker ; then
  cat <<EOF > /etc/default/docker

DOCKER_OPTS='
-H tcp://0.0.0.0:2376
-H unix:///var/run/docker.sock
--storage-driver aufs
--tlsverify
--tlscacert /etc/docker/ca.pem
--tlscert /etc/docker/server.pem
--tlskey /etc/docker/server-key.pem
--label provider=generic
--ipv6 --fixed-cidr-v6=${PUBLIC_IPV6}:D0CC::/80 --bip=172.17.0.1/16 --fixed-cidr=172.17.0.1/16

'

EOF
  restart docker
fi

