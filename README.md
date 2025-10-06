# wesley-institute-of-learning-student-portal
# Terraform command automated 
   #!/bin/bash
set -e

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
