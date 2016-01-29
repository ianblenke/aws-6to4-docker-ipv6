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

The generated instance has docker on it as well, with ipv6 support.

If you ssh as shown above, you can run docker commands directly on the instance and the containers will have IPV6 support.

## Docker-Machine

To add this remote instance to your local docker-machine config:

	$ make docker-machine

Now your docker daemon is running with IPV6 enabled.

After running docker-machine create, you will end up with a docker-machine host entry:

	$ docker-machine ls
	NAME                 ACTIVE   DRIVER         STATE     URL                        SWARM   ERRORS
	ianblenke-dev-6to4   -        generic        Running   tcp://52.91.201.237:2376

From here, you can source it and run docker commands locally:

	$ eval $(docker-machine env ianblenke-dev-6to4)
	$ docker ps -a

Have fun with your new AWS hosted IPV6 enabled docker host.

## Notes

This really isn't something to use in production.

- The 192.88.99.1 gateway is not provided by AWS, though it is _very_ close at us-east-1 through Hurricane Electric.
- There are MTU issues to be concerned with, of course.
- DNS requires some effort to handle ipv6 and retain the public/private IPV4 AWS split-horizon.

The radvd mentioned in the `user-env.sh` script is currently not used. No route advertisement is done.
The idea behind that was to announce IPV6 on a tinc mesh (a separate project).

