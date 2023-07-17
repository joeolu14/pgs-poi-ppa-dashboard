# App Example

This is an example terraform module for placing within an application repository.  This shows how to configure the infrastructure for the application.

## Getting Started

1. Copy this entire module into the `/terraform` directory within your application repository.
2. Populate the `env_vars/nprod.secret.tfvars` and `env_vars/prod.secret.tfvars` files with the secrets for non-prod and prod, respectively.  Use the `env_vars/secret-example.tfvars` file as a starting point.
3. Populate the `project.auto.tfvars` and the `project.tfbackend` files with the appropriate values for your project.
4. Populate `main.tf` with the configuration you need for your application.
5. Execute terraform by following the commands listed below.

### Deploy to Dev

> terraform init --upgrade --reconfigure --backend-config=project.tfbackend --backend-config=backend_vars/dev.tfbackend

> terraform apply --var-file=env_vars/nprod.secret.tfvars --var-file=env_vars/nprod.tfvars --var="environment=dev"

> terraform destroy --var-file=env_vars/nprod.secret.tfvars --var-file=env_vars/nprod.tfvars --var="environment=dev"

### Deploy to Stage

> terraform init --upgrade --reconfigure --backend-config=project.tfbackend --backend-config=backend_vars/stage.tfbackend

> terraform apply --var-file=env_vars/nprod.secret.tfvars --var-file=env_vars/nprod.tfvars --var="environment=stage"

> terraform destroy --var-file=env_vars/nprod.secret.tfvars --var-file=env_vars/nprod.tfvars --var="environment=stage"

### Deploy to QA

> terraform init --upgrade --reconfigure --backend-config=project.tfbackend --backend-config=backend_vars/qa.tfbackend

> terraform apply --var-file=env_vars/nprod.secret.tfvars --var-file=env_vars/nprod.tfvars --var="environment=qa"

> terraform destroy --var-file=env_vars/nprod.secret.tfvars --var-file=env_vars/nprod.tfvars --var="environment=qa"

### Deploy to Production

> terraform init --upgrade --reconfigure --backend-config=project.tfbackend --backend-config=backend_vars/prod.tfbackend

> terraform apply --var-file=env_vars/prod.secret.tfvars --var-file=env_vars/prod.tfvars --var="environment=prod"

> terraform destroy --var-file=env_vars/prod.secret.tfvars --var-file=env_vars/prod.tfvars --var="environment=prod"

## TODO

* Build an example CI/CD pipeline to automatically run this.
