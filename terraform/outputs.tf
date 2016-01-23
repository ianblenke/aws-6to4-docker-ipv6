output "project" {
  value = "${var.Project}"
}

output "environment" {
  value = "${var.Environment}"
}

output "vpc" {
  value = "${aws_vpc.vpc.id}"
}

output "iam_instance_profile_6to4" {
  value = "${aws_iam_instance_profile.iam_instance_profile_6to4.id}"
}

output "sg_6to4" {
  value = "${aws_security_group.sg_6to4.id}"
}

output "sg_6to4_name" {
  value = "${aws_security_group.sg_6to4.name}"
}

output "aws_instance_6to4_0_public_dns" {
  value = "${aws_instance.aws_instance_6to4.0.public_dns}"
}

output "ssh_6to4" {
  value = "ssh -i terraform/${var.ssh_key_path_6to4} ubuntu@${aws_instance.aws_instance_6to4.0.public_dns}"
}

