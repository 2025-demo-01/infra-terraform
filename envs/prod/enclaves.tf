resource "aws_security_group" "enclave" {
  name   = "${var.name_prefix}-enclave-sg"
  vpc_id = module.vpc.vpc_id
  tags   = local.tags
}

resource "aws_instance" "signer" {
  ami                    = data.aws_ami.al2.id
  instance_type          = "m6i.large"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.enclave.id]

  enclave_options { enabled = true }  # <<< Nitro Enclaves ON
  user_data = <<-EOF
    #!/bin/bash
    yum install -y nitro-cli
    systemctl enable --now nitro-enclaves-allocator.service
  EOF

  tags = merge(local.tags, { role = "signer-enclave" })
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter { name="name", values=["amzn2-ami-hvm-*-x86_64-gp2"] }
}
