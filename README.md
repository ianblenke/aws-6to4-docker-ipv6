# aws-ec2-ipv6-6to4

This is a self-contained example of how to spin up an AWS EC2 instance supporting IPV6 using 6to4.

Prerequisites:

- terraform
- make
- AWS Credentials configured (aws configure, or environment variables)

To create the 6to4 testbed:

	make apply

## Notes

This really isn't something to use in production.

- The 192.88.99.1 gateway is not provided by AWS.
- DNS requires some effort to handle ipv6 and retain the public/private IPV4 AWS split-horizon.

