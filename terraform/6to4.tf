/******************************************************************************
 *
 * 6to4.tf - IAM profile, security groups, and 6to4 instances
 *
 ******************************************************************************/

resource "aws_security_group" "sg_6to4" {
  name = "${var.Project}-${var.Environment}-6to4"
  description = "Security Group for ${var.Project}-${var.Environment} 6to4 Tunnelling"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
      Name = "sg-${var.Project}-${var.Environment}-6to4"
      Project = "${var.Project}"
      Environment = "${var.Environment}"
  }
}

resource "aws_security_group_rule" "sg_6to4_ingress_ssh" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_6to4.id}"
}

resource "aws_security_group_rule" "sg_6to4_ingress_tunnel" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "41"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_6to4.id}"
}

resource "aws_security_group_rule" "sg_6to4_ingress_all_icmp" {
    type = "ingress"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.sg_6to4.id}"
}

resource "aws_security_group_rule" "sg_6to4_ingress_all_internal" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = "${aws_security_group.sg_6to4.id}"
    source_security_group_id = "${aws_security_group.sg_6to4.id}"
}

resource "aws_security_group_rule" "sg_6to4_egress_all_out" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.sg_6to4.id}"
}

resource "aws_iam_role" "iam_role_6to4" {
    name = "${var.Project}-${var.Environment}-6to4_instance_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_6to4" {
    name = "${var.Project}-${var.Environment}-6to4_instance_policy"
    path = "/"
    description = "Platform IAM Policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
       "Effect": "Allow",
       "Action": [
         "iam:ListInstanceProfiles"
       ],
       "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "iam_policy_attachment_6to4" {
    name = "${var.Project}-${var.Environment}-6to4_policy_attach"
    roles = ["${aws_iam_role.iam_role_6to4.name}"]
    policy_arn = "${aws_iam_policy.iam_policy_6to4.arn}"
}

resource "aws_iam_instance_profile" "iam_instance_profile_6to4" {
    name = "${var.Project}-${var.Environment}-6to4_instance_profile"
    roles = ["${aws_iam_role.iam_role_6to4.name}"]
}

resource "aws_key_pair" "ssh_key_6to4" {
  key_name = "${var.Project}-${var.Environment}-6to4" 
  public_key = "${file("${var.ssh_key_path_6to4}.pub")}"
}

resource "aws_instance" "aws_instance_6to4" {
  count = "${var.aws_instance_count_6to4}"
    
  availability_zone = "${element(split(",",lookup(var.aws_availability_zones, var.aws_region)), count.index % length(split(",",lookup(var.aws_availability_zones, var.aws_region))))}"
  
  instance_type = "${var.aws_instance_type_6to4}"
  ami = "${lookup(var.ami, concat(var.aws_region, "-", var.linux_distro_name_6to4, "-", var.linux_distro_version_6to4))}"
  
  iam_instance_profile = "${aws_iam_instance_profile.iam_instance_profile_6to4.id}"
  vpc_security_group_ids = [ "${aws_security_group.sg_6to4.id}" ]
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  associate_public_ip_address = "true"
  
  key_name = "${aws_key_pair.ssh_key_6to4.key_name}"

  connection {
    user = "ubuntu"
    key_file = "${var.ssh_key_path_6to4}"
  }

  tags {
    Name = "${var.Project}-${var.Environment}-6to4-${count.index}"
    Project = "${var.Project}"
    Environment = "${var.Environment}"
  }
    
  root_block_device = {
    volume_type = "gp2"
    volume_size = "${var.ebs_root_volume_size_6to4}"
  }

  user_data            = <<EOF
#!/bin/bash
PUBLIC_IPV4="$(curl -qs http://169.254.169.254/2014-11-05/meta-data/public-ipv4)"
[ -n "$PUBLIC_IPV4" ] || PUBLIC_IPV4="$(curl -qs ipinfo.io/ip)"
PRIVATE_IPV4="$(curl -qs http://169.254.169.254/2014-11-05/meta-data/local-ipv4)"
[ -n "$PRIVATE_IPV4" ] || PRIVATE_IPV4="$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)"
PUBLIC_IPV6="$(printf '2002:%02x%02x:%02x%02x::1' $(echo $PUBLIC_IPV4 | tr '.' ' '))"
cat <<EOI >> /etc/network/interfaces.d/6to4.cfg
# This way should work, but does not appear to.
#auto 6to4
#iface 6to4 inet6 v4tunnel
#	address $PUBLIC_IPV6
#        netmask 16              
#	gateway ::192.88.99.1
#	endpoint any
#	local $PUBLIC_IPV4

# This is the old way that appears to actually work.
auto sit0
iface sit0 inet6 static
        address $PUBLIC_IPV6
        netmask 16
        gateway ::192.88.99.1
	# This circumvents split-horizon AWS DNS
	#nameserver 2001:4860:4860::8888
EOI
#sudo ifup 6to4
sudo ifup sit0
sudo apt-get update
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get install -y fail2ban radvd dnsmasq
cat << EOR
# AWS Does not allow broadcasts, so NDP isn't going to work
# This needs to be an internal vpn overlay interface
interface vpn0
{
    AdvSendAdvert on;
    prefix 0:0:0:D00D::/64
    {
        AdvOnLink on;
        AdvAutonomous on;
        Base6to4Interface 6to4;
    };
};

# Deal with AWS split-horizon DNS and using both IPV4 and IPV6 DNS servers
resolvconf --disable-updates

domains="$(grep domain-name /var/lib/dhcp/dhclient.eth0.leases | grep -v domain-name-servers | awk '{print $3}' | sed -e 's/[\"\;]//g' | sort | uniq)"
servers="$(grep domain-name /var/lib/dhcp/dhclient.eth0.leases | grep domain-name-servers | awk '{print $3}' | sed -e 's/[\"\;]//g' | sort | uniq)"

ln -sf /var/run/resolvconf/interface/eth0.dhclient /var/run/dnsmasq/resolv.conf

cat <<EOC > /etc/dnsmasq.conf
listen-address=127.0.0.1
port=53
bind-interfaces
user=dnsmasq
group=nogroup
resolv-file=/var/run/dnsmasq/resolv.conf
pid-file=/var/run/dnsmasq/dnsmasq.pid
domain-needed
all-servers
EOC

for domain in $domains ; do
  # Route ec2.internal to AWS servers by default
  for server in $servers; do
    echo 'server=/'"$domain"'/'"$server" >> /etc/dnsmasq.conf
  done
done

# Route all other queries, simultaneously, to both ipv4 and ipv6 DNS servers at Google
for server in 8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844 ; do
  echo 'server=/*/'"$server" >> /etc/dnsmasq.conf
done

cat <<EOR > /etc/resolv.conf
search $domains
nameserver 127.0.0.1
EOR

/etc/init.d/dnsmasq restart

EOR
# /etc/init.d/radvd restart
EOF

}
