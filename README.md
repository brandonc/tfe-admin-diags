# tfediags

A shell script that collects helpful diagnostics from Terraform Enterprise. This script will read non-sensitive data such as Terraform version usage from the host Admin API, and pack it into a tar.gz.

Usage:

`$ bash tfediags.sh <hostname>`

or

`$ curl https://raw.githubusercontent.com/brandonc/tfediags/v0.2.0/tfediags.sh | bash -s -- <hostname>`

The script will write a file named `tfe-diags-20230203_105511Z.tar.gz` to the current directory which you can send to Terraform Enterprise account or support representative.

## Troubleshooting

tfediags.sh relies on the default `terraform login` credentials file, so be sure to `terraform login <hostname>` using a site admin account before running this script.

Send us debug output: `LOG=DEBUG ./tfediags <hostname>`

## Prerequisites

- jq (1.4+, tested using 1.6)
- curl
