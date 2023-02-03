# tfediags

A shell script that collects helpful product information from Terraform Enterprise. This script will read non-sensitive data such as Terraform version usage from the host Admin API, and pack it into a diagnostic bundle.

Usage:

`$ bash tfediags.sh <hostname>`

or

`$ curl https://raw.githubusercontent.com/brandonc/tfediags/v0.2.0/tfediags.sh | bash -s -- <hostname>`

The script will write a file named something like `tfe-diags-20230203_105511Z.tar.gz` to the current directory which you can send to your Terraform Enterprise account or support representative.

## Troubleshooting

`tfediags.sh` relies on the default `terraform login` credentials file, so be sure to `terraform login <hostname>` using a site admin account before running this script.

Debug logging output can help us troubleshoot additional problems: `LOG=DEBUG ./tfediags.sh <hostname>`

## Prerequisites

- jq (1.4+, tested using 1.6)
- curl
