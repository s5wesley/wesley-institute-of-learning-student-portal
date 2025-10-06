# wesley-institute-of-learning-student-portal
# Terraform command automated 
   #!/bin/bash
set -e

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve

# Git common command 
 git add -A
git commit -m "Updated student portal with Cameroonian flag and silhouette background"
git push

