# POI Template for TypeScript

This is a template repository for a basic typescript application, including a react frontend, an expressjs backend, and an adonisjs cli for ETL scripts.

## Directory structure

`backend`: Backend ExpressJS code.  This will be hosted at `/api`.
`frontend`: Frontend React code.  This will be hsoted at `/`.
`etl`: Adonis CLI code.  This will be executed as a Kubernetes Cronjob on a schedule.
`terraform`: Deployment code.  This defines what the application structure looks like within kubernetes.
`.github`: Workflow code.  This defines what GitHub actions exist and run.

## Usage

* Create a new resository in Github, specifying this one as the template.
* Update terraform/project.tfbackend with the appropriate tfstate namespace.
* Update terraform/project.auto.tfvars with the appropriate project name and url_prefix.
* Review and update terraform/main.tf if necessary.
* Rename .github-disabled to .github
* Review the jobs under .github/workflows and edit the url_prefix and any paths as necessary.
