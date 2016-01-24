# aws-ec2-ipv6-6to4

This is a self-contained example of how to spin up an AWS EC2 instance supporting IPV6 using 6to4.

Prerequisites:

- terraform
- make
- AWS Credentials configured (aws configure, or environment variables)

To see what AWS cloud resources this harness will try and create:

	make plan

To create the 6to4 testbed:

	make apply

To destroy the 6to4 testbed and all of the AWS cloud resources:

	make destroy

To see the ssh command you need to ssh into the generated EC2 instance:

	$ make output
	ssh -i terraform/../secrets/id_rsa-6to4 ubuntu@ec2-54-85-83-208.compute-1.amazonaws.com

You can eval or cut and paste that to get a shell on the instance.

## Docker

The generated instance has docker on it as well, with ipv6 support. Give it a try.

## Notes

This really isn't something to use in production.

- The 192.88.99.1 gateway is not provided by AWS.
- DNS requires some effort to handle ipv6 and retain the public/private IPV4 AWS split-horizon.

The radvd mentioned in the `user-env.sh` script is currently not used. No route advertisement is done.

