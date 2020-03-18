provider "tls" {
  version = "~> 2.1"
}

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.key_pair.private_key_pem
  filename = pathexpand("~/.ssh/${var.name}.key")
}
