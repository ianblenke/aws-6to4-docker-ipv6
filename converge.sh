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
    terraform destroy -force
    cd ..
    eval "$(cd terraform; terraform output docker-machine_rm_6to4)"
  ;;
  output)
    exec terraform output ssh_6to4
  ;;
  docker-machine)
    cd ..
    set -x
    echo -n 'Waiting for instance to become ready.'
    while ! $(cd terraform; terraform output ssh_6to4) -- docker ps -a ; do
      echo -n '.'
      sleep 10
    done
    echo 'Creating docker-machine!'
    eval "$(cd terraform; terraform output docker-machine_create_6to4)"
    eval "$(cd terraform; terraform output docker-machine_env_6to4)"
    eval "$(cd terraform; terraform output docker-machine_scp_6to4 | sed -e s/%/fix_docker_defaults.sh/g)"
    eval "$(cd terraform; terraform output docker-machine_ssh_6to4) -- sudo bash -x /tmp/fix_docker_defaults.sh"
  ;;
  *)
    exec terraform $ACTION .
  ;;
esac
exit $?
