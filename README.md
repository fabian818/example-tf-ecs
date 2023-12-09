<a name="readme-top"></a>
<!-- ABOUT THE PROJECT -->
## About The Project

This a project which contains the terraform template to deploy ecs infrastructure. Please, clone and modify as needed.

### Built With

* [![Terraform][Terraform]][Terraform-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

We need to install terraform in our client pc, preferently using [https://github.com/tfutils/tfenv](tfenv)

### Installation

1. Clone the repo
   ```sh
   git clone git@github.com:Juried/juried-infra-tf.git
   ```
3. Configure aws profile in the config aws file.
4. Run the init command.
   ```sh
   terraform -chdir=01-Shared-Resources init
   ```
   or
   ```sh
   yarn init-01
   ```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Structure

This is a terraform monorepo, where we can find at this moment four projects:
- 01-Shared-Resources -> Miscellaneous resources, (e.g. Docker repositories)
- 02-Pipelines -> Pipeline's components, CI/CD.
- 03-Apps-Dev -> Development infrastructure components
- 04-Apps-Staging -> Staging infrastructure components
- 05-Apps-Prod -> Production infrastructure components

Each name should be descriptive about the folder's purpose.
There is also an extra folder called `modules` which contains the local modules used for the main projects.

All the modules use the standard terraform project structure [https://developer.hashicorp.com/terraform/language/modules/develop/structure](Check here).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

1. First we need to plan the actual infrastructure we want to implement.
2. check if there is a local module (or in the marketplace) that can perform this operation, to keep the project more dry as possible.
3. If necessary, create a new module inside the modules folder.
4. Then we will need to implement a new file inside the respective main project folder. This file should be very descriptive about the kind of infrastructure we want to implement (e.g. rds.tf).
5. Put the parameters for this module inside the locals.tf file, because we want to keep the project configuration in this single file, then, the file created in the previous step should consume the parameters in the locals.tf file.
6. Run the plan 
   ```sh
   terraform -chdir=01-Shared-Resources plan
   ```
   or
   ```sh
   yarn plan-01
   ```
7. Run the apply
   ```sh
   terraform -chdir=01-Shared-Resources apply -auto-approve
   ```
   or
   ```sh
   yarn apply-01
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- The pipelines are temporary in CodePipeline, but we are planing to move this to Github actions 🥳.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[Terraform]: https://img.shields.io/static/v1?label=&message=Terraform&color=blueviolet
[Terraform-url]: https://www.terraform.io/