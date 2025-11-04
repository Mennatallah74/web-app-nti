resource "aws_default_security_group" "default-sg"{

vpc_id = var.vpc_id
ingress{
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress{
    from_port = 8080
    to_port = 8080
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress{
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress{
    from_port = 50000
    to_port = 50000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress{
    from_port = 9000
    to_port = 9000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
ingress{
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
}
tags = {
    Name: "${var.env_prefix}-default-sg"
}
}
/*data "aws_ami" "latest-amazon-linux-image"{
most_recent = true
owners = ["amazon"]
filter{
    name = "name"
    values = [var.image_name]
}
filter{
    name = "virtualization-type"
    values = ["hvm"]
}
}*/



resource "aws_key_pair" "ssh-key"{
    key_name = "menna-key"
    public_key = file(var.public_key_location)
}
resource "aws_instance" "myapp-server"{
 ami = "ami-004e960cde33f9146"
 instance_type = var.instance_type
 root_block_device {
    volume_size = 20  # change from e.g., 8 -> 40 (GiB)
    volume_type = "gp3"
  }
 subnet_id = var.subnet_id
 vpc_security_group_ids = [aws_default_security_group.default-sg.id]
 availability_zone = var.avail_zone
 associate_public_ip_address = true
 key_name = aws_key_pair.ssh-key.key_name
user_data_replace_on_change = true
connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = file(var.private_key_location)
}

/*provisioner "file"{
    source = "entry-script.sh"
    destination = "/home/ec2-user/entry-script-on-ec2.sh"
}

provisioner "remote-exec"{
inline = [ "chmod +x /home/ec2-user/entry-script-on-ec2.sh",
    "/home/ec2-user/entry-script-on-ec2.sh"]
}*/
provisioner "local-exec"{
command = "echo ${self.public_ip} > output.txt"
}
 tags = {
    Name: "${var.env_prefix}-server"
}
}




