# Fastly - Terraform Demo<br>Example Repository for Terraform Modules

This repo includes:

- Terraform module for deploying Fastly services
- Terraform module for deploying certificates and adding DNS records to point traffic to Fastly
- GitHub Actions workflows for testing the modules

The example module adds DNS records to Route 53.

## Usage in a local environment

Start by creating a directory and .tf file.

```
mkdir tf && touch tf/main.tf
```

Next add the following code to the main.tf file:

```hcl
provider "aws" {
  region = "ap-northeast-1"
}

locals {
  domain          = "example.hkakehas.tokyo"
  dns_zone        = "hkakehas.tokyo"
  papertrail_addr = "xxx.papertrailapp.com"
  papertrail_port = 12345
}

module "service" {
  source          = "github.com/hkakehashi/tfdemo-modules//service?ref=v1.0.3"
  domain          = local.domain
  papertrail_addr = local.papertrail_addr
  papertrail_port = local.papertrail_port
}

module "cert" {
  source     = "github.com/hkakehashi/tfdemo-modules//cert?ref=v1.0.3"
  domains    = [local.domain]
  dns_zone   = local.dns_zone
}

output "service" {
  value = module.service.service_info.domain
}
```

Then...

```
terraform init
terraform apply
```

## About module versioning

For modules hosted at Github, Terraform will clone and use the default branch by default. You can override this using the `ref` argument to use a specific commit as the source to change the version of the module depending on the environment. In the example above, we use the tag name.

### Supporting multiple environments with module versioning

The two live services hosted in [the demo repository](https://github.com/hkakehashi/tfdemo-live) both use this module, but in different versions. The demo repository is configured to run Terraform with Github Actions on events such as Push/PR.

**Image of the file structure**

```
├── modules                    <------------------ This repository
│   ├── cert
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   └── service
│       ├── main.tf
│       ├── output.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── log_format
│       │   ├── waflogs.json
│       │   └── weblogs.json
│       └── vcl
│           ├── main.vcl
│           ├── snippet_Fastly_WAF_Snippet.vcl
│           └── snippet_fastly_csi_init.vcl
└── live
    ├── prod
    │   ├── main.tf            <------------------ Using v1.0.0 (Minimal configuration)
    │   └── provider.tf
    └── dev
        ├── main.tf            <------------------ Using v1.1.0 (Additional features enabled)
        └── provider.tf
```

## Github Actions workflow

### Triggers and actions

- Pull Requests to the main branch containing changes to `service/*

  - Lint Terraform files by running terraform commands
  - Lint VCL files using [falco](https://github.com/ysugimoto/falco)
  - Spin up Terraform resources defined in `service/example` using [Terratest](https://github.com/gruntwork-io/terratest) and repeatedly send HTTP requests until the expected response is returned.

- Pull Requests to the main branch containing changes to `cert/*

  - Lint Terraform files by running terraform commands
  - Spin up Terraform resources defined in `cert/example` using [Terratest](https://github.com/gruntwork-io/terratest) and repeatedly send HTTPS requests until the expected response is returned.

These actions can also be run with the workflow_dispatch event.

## Credentials

Fastly/AWS credentials need to be given through the environment variables or provider configuration.

**Environment variables**

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- FASTLY_API_KEY

## Modules

This example includes two modules:

### service

This module is responsible for deploying a Fastly VCL service.

**Resources**

| Name                                                                                                                                          | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [fastly_service_vcl.service](https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/service_vcl)                         | resource    |
| [fastly_service_waf_configuration.waf](https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/service_waf_configuration) | resource    |
| [fastly_waf_rules.default](https://registry.terraform.io/providers/fastly/fastly/latest/docs/data-sources/waf_rules)                          | data source |

**Inputs**

| Name            | Description                                                                                    | Type     | Default | Required |
| --------------- | ---------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| domain          | The domain that the service will respond to                                                    | `string` | n/a     |   yes    |
| enable_waf      | Provision a WAF object with pre-determine rules, OWASP config, response, and logging endpoints | `bool`   | `false` |    no    |
| papertrail_addr | The hostname of the logging endpoint                                                           | `string` | n/a     |   yes    |
| papertrail_port | The port number of the logging endpoint                                                        | `number` | n/a     |   yes    |

**Outputs**

| Name         | Subfield Name              |
| ------------ | -------------------------- |
| service_info | id, domain, active_version |

### cert

This module is responsible for issuing and deploying certificates, and adding DNS records. 2 DNS records are created for each domain: one to verify the ownership of the domain, which is necessary for issuing certificates, and the other to point requests to Fastly.

**Resources**

| Name                                                                                                                                                     | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_route53_record.domain_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                       | resource    |
| [aws_route53_record.record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                  | resource    |
| [fastly_tls_subscription.subscription](https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/tls_subscription)                     | resource    |
| [fastly_tls_subscription_validation.validation](https://registry.terraform.io/providers/fastly/fastly/latest/docs/resources/tls_subscription_validation) | resource    |
| [aws_route53_zone.zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                                     | data source |
| [fastly_tls_configuration.configuration](https://registry.terraform.io/providers/fastly/fastly/latest/docs/data-sources/tls_configuration)               | data source |

**Inputs**

| Name       | Description                                   | Type          | Default      | Required |
| ---------- | --------------------------------------------- | ------------- | ------------ | :------: |
| dns_zone   | Name of the hosted zone                       | `string`      | n/a          |   yes    |
| domains    | The set of domains to enable TLS              | `set(string)` | n/a          |   yes    |
| tls_config | TLS configuration to be enabled on the domain | `string`      | `"TLS v1.3"` |    no    |

**Outputs**

| Name      | Subfield Name                                   |
| --------- | ----------------------------------------------- |
| cert_info | domain, created_at, updated_at, tls_config_name |
| dns_info  | n/a                                             |
