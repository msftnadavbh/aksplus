---
page_type: sample
languages:
- csharp
products:
- dotnet
description: "Add 150 character max description"
urlFragment: "update-this-to-unique-url-stub"
---

# aksplus 

<!-- 
Guidelines on README format: https://review.docs.microsoft.com/help/onboard/admin/samples/concepts/readme-template?branch=master

Guidance on onboarding samples to docs.microsoft.com/samples: https://review.docs.microsoft.com/help/onboard/admin/samples/process/onboarding?branch=master

Taxonomies for products and languages: https://review.docs.microsoft.com/new-hope/information-architecture/metadata/taxonomies?branch=master
-->

 aksplus contains terraform deployment scripts focus on using Azure kubernetes services with other Azure services to provide a quick POC environment 

## Contents

The main terraform deployment scripts are in below two folders
aksplus and aksplus_kubernetes

| File/folder       | Description                                |
|-------------------|--------------------------------------------|
| `aksplus`             | Terraform deployment scripts.                        |
| `aksplus_kubernetes`             | Kubernetes related deployment scripts for demo purpose.                        |
| `.gitignore`      | Define what to ignore at commit time.      |
| `CHANGELOG.md`    | List of changes to the sample.             |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md`       | This README file.                          |
| `LICENSE`         | The license for the sample.                |

## Prerequisites

To deploy, make sure below prerequisites software are installed in your system
- terraform
- kubectl
- az cli

## Deployment

### Deploy AKS + other Azure related services
- Change directory aksplus
- Open aksplus.auto.tfvars and modify eable_* flags
- Run "terraform init"
- Run "terraform apply", enter "Yes" if everything is acceptable

### Deploy kubernetes related workload
- Once finished above steps, change directory to aksplus_kubernetes
- Run "terraform init"
- Run "terraform apply", enter "Yes" if everything is acceptable

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
