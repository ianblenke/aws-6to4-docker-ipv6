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

output "docker-machine_create_6to4" {
  value = "docker-machine create -d generic --generic-ip-address ${aws_instance.aws_instance_6to4.0.public_ip} --generic-ssh-key terraform/${var.ssh_key_path_6to4} --generic-ssh-user ubuntu ${var.Project}-${var.Environment}-6to4"
}

output "docker-machine_env_6to4" {
  value = "docker-machine env ${var.Project}-${var.Environment}-6to4"
}

output "docker-machine_ssh_6to4" {
  value = "docker-machine ssh ${var.Project}-${var.Environment}-6to4"
}

output "docker-machine_rm_6to4" {
  value = "docker-machine rm ${var.Project}-${var.Environment}-6to4"
}

output "docker-machine_scp_6to4" {
  value = "docker-machine scp % ${var.Project}-${var.Environment}-6to4:/tmp/%"
}

output "ssh_6to4" {
  value = "ssh -i terraform/${var.ssh_key_path_6to4} -o StrictHostKeyChecking=no ${var.linux_distro_name_6to4}@${aws_instance.aws_instance_6to4.0.public_dns}"
}

