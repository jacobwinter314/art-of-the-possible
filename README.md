# Art of the Possible Demonstration

The purpose of this repository is to provide for a sample Python REST service,
showing how it can be deployed seamlessly into multiple environments.

## XXXX

This solution has been narrowly targetted to meet the stated goals of:

- xxx

## Where To Start

This project deploys the solution to the Azure environment using as few dependencies
as possible.

- Ubuntu 20.04
- Python 3.X (installed on Ubuntu)
- Docker
- Azure Command Line (instructions below)

### Installing Azure Command Line

To install the Azure Command Line (Azure CLI), please go to
[this link](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
to find the instructions for your particular flavor of Linux.  For Ubuntu 20.04,
those instructions are to execute:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Once installed type the following line:

```bash
az login
```

to verify that you can log into Azure.

### Determining TenantId and SubscriptionId

To determine these two values, you need to execute the followning command:

```bash
az account show
```

Depending on your setup, you may see more than one JSON block returned by this command.
In these blocks, the `id` field is the `SubscriptionId` that you want to use to
create this solution in and is `00000002-0002-0002-0002-000000000002` in the sample
below. The `tenantId` field is the `TenantId` in which the subscription resides
and is `00000001-0001-0001-0001-000000000001` in the sample below.

If you have multiple tenants or multiple subscriptions, verify that you have the
correct tenant and subscription before going forward.

```json
{
  "environmentName": "AzureCloud",
  "homeTenantId": "00000001-0001-0001-0001-000000000001",
  "id": "00000002-0002-0002-0002-000000000002",
  "isDefault": true,
  "managedByTenants": [],
  "name": "Azure subscription",
  "state": "Enabled",
  "tenantId": "00000001-0001-0001-0001-000000000001",
  "user": {
    "name": "someone@somewhere.com",
    "type": "user"
  }
}
```

### Generating a Service Principal - Determining ClientId and ClientSecret

To login to Azure...[jdw: TBD]
[from here](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)

replace `00000002-0002-0002-0002-000000000002` with subscription id from above

```bash
export MSYS_NO_PATHCONV=1
az ad sp create-for-rbac --name terraform-sp --role Contributor --scopes /subscriptions/00000002-0002-0002-0002-000000000002
```

"appId" clientId 00000003-0003-0003-0003-000000000003
"password" clientSecret

{
  "appId": "00000003-0003-0003-0003-000000000003",
  "displayName": "terraform-sp",
  "password": "string", # pragma: allowlist-secret
  "tenant": "00000001-0001-0001-0001-000000000001"
}

### Saving This Information For Terraform

edit terraform/init_tfvars.sh

NEVER commit

4 fields, TF_VAR_arm_

```bash
source terraform/init_tfvars.sh
```

### ?

terraform/create-state/init.sh

init.sh
container_name = "tfstate"
resource_group = "rg-artpossiblest-dev-westus"
storage_account_name = "startpossiblestdevwestus"
