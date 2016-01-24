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

mkdir -p secrets
[ -f secrets/id_rsa-6to4 ] || ssh-keygen -t rsa -b 4096 -f secrets/id_rsa-6to4 -P ''

cd terraform/

OPTIONS=""
if [ "$ACTION" = "destroy" ]; then
  OPTIONS=-force
fi
TARGET=.
if [ "$ACTION" = "output" ]; then
  TARGET=ssh_6to4
fi

exec terraform $ACTION $OPTIONS $TARGET
