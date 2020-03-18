output "public_key_openssh" {
  value = tls_private_key.key_pair.public_key_openssh
}