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

  user_data = "${file("../user-env.sh")}"
}
