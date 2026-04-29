# TFLint Configuration

# Specify the required plugins
plugin "aws" {
  enabled = true
}

# Enable rules for best practices
rule "aws_instance_type" {
  enabled = true
}
rule "aws_security_group" {
  enabled = true
}
