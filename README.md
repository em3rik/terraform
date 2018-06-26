# Terraform #

This terraform directory includes multiple terraform modules:

* vpc
* security_groups
* peering
* ec2

### Remote tfstate ###

This setup uses **S3 bucket** for the the remote state. It is recommended to enable versioning on this b
ucket.

### AWS env variable  ###

Two env variables need to be exported or placed at the end of the .bashrc file

export AWS_ACCESS_KEY_ID=<your_key_id>    
export AWS_SECRET_ACCESS_KEY=<your_access_key>
