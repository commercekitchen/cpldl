resource "aws_key_pair" "bastian_key" {
  key_name   = "bastian-key-${var.environment_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDVvwwWqcBYrB5B/PEUv6cOgKUz+4JSTNPJP/LVnRUSZOLgDuXIeUME6vdYp5lTi+SaKIADMyFPXbMwYelNyLjQX4DCjfnRVUW7UzBDo4DMo1t/gSa/WJh1etByhol+PEnHK+uBO78UQavyw2Yr+yi8UqhUFXSbZoRDklpdaY9gQLXxnDFHOlW3EUZAA9YGgqHWeAkJd4M6+s487k1PqODfNyPAfihckG57tLEkoFHp3IXYFmJoeppEidPGouwoHfyBDyI/VpIX3ofs98y4iPdMhcA5RiuoXEIjVfuOiRSiHEtXxWGPb0fTL5FrBdAdXIJT+AoaPg8ycVEhlVcXdOA1"
}

resource "aws_instance" "bastian_instance" {
  ami                         = "ami-03d5c68bab01f3496"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [var.default_security_group_id, aws_security_group.bastian_sg.id]
  subnet_id                   = element(var.public_subnet_ids, 0)
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastian_key.key_name

  tags = {
    Name = "${var.project_name} Bastian (${var.environment_name})"
  }
}
