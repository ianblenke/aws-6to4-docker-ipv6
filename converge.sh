#!/bin/bash -e

ACTION=$1

if [ -z "$ACTION" ]; then
  echo "Usage: $0 {action} {{filenames}.env}"
  echo "Where {action} is a terraform action, like: plan, apply, destroy"
  echo "Optionally {filenames}.env is a list of environment files to source"
  exit 1
fi

shift

# Source the passed *.env files
for file in $@; do
  export $(cat $file)
done

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-$(aws configure get aws_access_key_id --profile default)}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-$(aws configure get aws_secret_access_key --profile default)}
export AWS_REGION=${AWS_REGION:-$(aws configure get region --profile default)}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-${AWS_REGION}}
export TF_VAR_aws_access_key_id=${AWS_ACCESS_KEY_ID}
export TF_VAR_aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
export TF_VAR_aws_region=${AWS_REGION}
export SSH_KEY=${SSH_KEY:-secrets/id_rsa-6to4}
export TF_VAR_ssh_key_path_6to4=../${SSH_KEY}
export SSH_USER=${SSH_USER:-ubuntu}
export TF_VAR_linux_distro_name_6to4=ubuntu

mkdir -p secrets
[ -s "${SSH_KEY}" ] || ssh-keygen -t rsa -b 4096 -f "${SSH_KEY}" -P ''

cd terraform/

case $ACTION in
  destroy)
    exec terraform destroy -force
  ;;
  output)
    exec terraform output ssh_6to4
  ;;
  docker-machine)
    eval "$(terraform output docker-machine_6to4)"
    eval $(terraform output ssh_6to4) bash -c '
      PUBLIC_IPV4="$(curl -qs http://169.254.169.254/2014-11-05/meta-data/public-ipv4)" ;
      [ -n "$PUBLIC_IPV4" ] || PUBLIC_IPV4="$(curl -qs ipinfo.io/ip)" ;
      PUBLIC_IPV6="$(printf '2002:%02x%02x:%02x%02x' $(echo $PUBLIC_IPV4 | tr '.' ' '))" ;
      echo DOCKER_OPTS='"'-H tcp://0.0.0.0:2376 -H unix:///var/run/docker.sock --storage-driver aufs --tlsverify --tlscacert /etc/docker/ca.pem --tlscert /etc/docker/server.pem --tlskey /etc/docker/server-key.pem --label provider=generic --ipv6 --fixed-cidr-v6=${PUBLIC_IPV6}:D0CC::/80 --bip=172.17.0.1/16 --fixed-cidr=172.17.0.1/16"'" > /etc/default/docker ;
      restart docker
    '
    docker-machine ls
  ;;
  *)
    exec terraform $ACTION .
  ;;
esac
exit $?
