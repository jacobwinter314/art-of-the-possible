# Art of the Possible Demonstration

The purpose of this repository is to provide for a sample Python REST service,
showing how it can be deployed seamlessly into multiple environments.

## Goals

This solution has been narrowly targetted to meet the stated goals of:

- addressing clients concerns with long lead times and cycles for development
- ensuring consistency between deployed environments
- addressing code quality concerns from client's business owners
- any downtime during deployments

## Where To Start

This project deploys the solution to the Azure environment using as few dependencies
as possible.

- Ubuntu 20.04
- Python 3.X (installed on Ubuntu)
- Docker
- Azure Command Line (instructions below)

Please note that for command line scripts and for the GitHub workflows to work
properly, the setup specified in the following sections is required.

Note that to test out any pipeline related actions, you will need to create a fork
of this repository, so that you can specify your own secrets to point to your own
Azure resources.  While changes to the scripts can be done with a cloned copy of
the repository, an actual fork is required to run your own pipelines.
To keep this documentation susinct, we assume that any forks made of this repository
are also created within GitHub.

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

To allow the resources to have the ability to modify Azure resources within Terraform,
we need to set up a service principal.  This service principal is essentially a
mechanism for exposing a specific "client" that can then be given permissions that
can be changed without affecting everyone using the subscription.  More information
on this [can be found here](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash).

To create a service principal to allow the resource to be deployed, the following
command needs to be executed:

```bash
export MSYS_NO_PATHCONV=1
az ad sp create-for-rbac --name tf-provider --role="Owner" --scopes="/subscriptions/00000002-0002-0002-0002-000000000002
```

The first thing is that the role has to be `Owner`.  If it is `Contributor`, like
some of the online instructions suggest, the service principal will not have the
correct permissions to adjust the roles necessary for the resources to work together.
Secondly, the `--scopes` specifies the scope that the service principal can work
with.  In the example, the text `00000002-0002-0002-0002-000000000002` should be
replaced with the `SubscriptionId` field from the above section.

Once executed, the command line should issue output that looks somewhat like:

```json
{
  "appId": "00000003-0003-0003-0003-000000000003",
  "displayName": "terraform-sp",
  "password": "string",                     # pragma: allowlist-secret
  "tenant": "00000001-0001-0001-0001-000000000001"
}
```

First off, to make sure our documentation and project code is secure, we use a
tool that looks for secrets in project files.  The text `# pragma: allowlist-secret`
is only there to appease that scanner and will not appear in the output. The
`appId` field in the output is the `ClientId`, and is `00000003-0003-0003-0003-000000000003`
in the sample output.  Similarly, the `password` field in the output is the `ClientSecret`,
and is `string` in the sample output.

### Saving This Information For Terraform - Scripts

For Terraform to be able to use this information, we need to put it somewhere where
it can be picked up and used.  The four pieces of information that we need to provide
Terraform with are:

- `SubscriptionId`
- `TenantId`
- `ClientId`
- `ClientSecret`

To place this information where the scripts can access it, edit the `./terraform/init_tfvars.sh`
file.  Each piece of information above has a corresponding environment variable
that is prefixed with `TF_VAR_arm_`.  Simply replace the `""` with the value that
was produced, including the `"` character.  While that character is not explicitly
necessary, it keeps thing consistent.

When completed, that part of the file should look something like:

```bash
export TF_VAR_arm_client_id="00000003-0003-0003-0003-000000000003"
export TF_VAR_arm_client_secret="string"                     # pragma: allowlist-secret
export TF_VAR_arm_subscription_id="00000002-0002-0002-0002-000000000002"
export TF_VAR_arm_tenant_id="00000001-0001-0001-0001-000000000001"
```

NEVER commit this file.  This file contains secrets which you do not want to share
with the rest of the the internet.  This is why the file starts with the comment:

```bash
# !!! This should NEVER be committed to a repository with any values filled in !!!
```

This file is automatically sourced by scripts such as the `./run_me.sh` script.
If you need to source it yourself, the easiest way to do it is to use the following
command line:

```bash
source ./terraform/init_tfvars.sh
```

### Saving This Information For Terraform - Pipelines

To ensure that the pipeline have the same ability to provision resources as the
scripts do, we have to provide them with the same four pieces of information. In
your own fork of the repository, click on the repository's `Settings` button
at the top, the `Secrets and Variables`, then `Actions`.  Similar to how the
scripts required a `TF_VAR_arm_` prefix, create new secrets for the repository
with the `ARM_` prefix and the entire word capitalized and with underscores in
it.  Therefore, `ClientId` should becomes `ARM_CLIENT_ID`.

When completed, under the `Repository Secrets` part of the page, there should
be (at least) four secrets:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

Note that this secrets are all read-only.  Once you have entered them, you can
replace them with new secrets or delete them, but you cannot see them again.

### Double Check Before Going Forward

Before proceeding, you probably want to double check all these values to ensure
that you did not miss anything.

In addition, you probably want to execute the `./terraform/create-state/init_backend_storage.sh`
script before proceeding further, especially if you plan on checking out the pipeline.
Mostly for safety reasons, the pipeline itself does not have the functionality for
creating the backend storage.  While the local `./run_me.sh` script does call this
script to set up the backend storage, I personally like to make sure that is taken
care of before proceeding with the rest of the script.  It just make me feel more
confident knowing that the shared storage mechanism is working properly.

Each Terraform set of files has `terraform.tf` file that contains a section like
this near the top of the file:

```text
  backend "azurerm" {
    resource_group_name  = "rg-artpossiblest-dev-westus"
    storage_account_name = "startpossiblestdevwestus"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
```

Note that the `terraform/deploy` set of files specifies a key of `terraform-deploy.tfstate`
instead of `terraform.tfstate` as that set of files contains a seperate set of
resources that have to be mainted.  Just before the script is completed, it outputs
values for the three fields other than the `key` field.

```text
container_name = "tfstate"
resource_group = "rg-artpossiblest-dev-westus"
storage_account_name = "startpossiblestdevwestus"
```

If these values to not match, the other Terraform actions will fail as they cannot
store the state in a secure location.  These values should always line up, but as
they are foundational to the rest of the process, it does not hurt to verify it.

## Executing the Project

This project was created with parity between the local development environment
and the pipeline production environment in mind.  To that end, the pipeline `main.yml`
and the script `./run_me.sh` have been orchestrated to closely mirror one another.
But as with [JW: ??]

### Pipeline

The pipeline is currently set with the following triggers:

- `push` to the `master` branch
- `pull_request` to the `master` branch
- on demand through the `workflow_dispatch` trigger

Therefore, the pipeline can be triggered manually through the repository's `Actions`
tab, selecting the `Main` workflow, and using the `Run workflow` dropdown. In
addition, any pull request created for the project will do a partial build of the
project, as will any successful pull request that is merged into main.

For demonstration purposes, that code has been commented out.  This can be done
to allow for rapid development of a given deployment using Pull Requests. While
that debugging can also be done locally, sometimes there is no replacing debugging
a process in its natural environment.  Those commented out locations can be found
in the `main.yml` file by looking for the `[jw': ???]`.

### Command Line

The command line version of the deployment can be started by executing the
`./run_me.sh` script.  This script will, in order:

- scan the project for any easy to find issues
  - `./run_scan_local.sh`
- load the values needed for Terraform to talk to Azure as mentioned in
  [this section](#saving-this-information-for-terraform---scripts)
  - `source ./terraform/init_tfvars.sh`
- create an Azure storage object to store the Terraform state file in
  - `./terraform/create-state/init_backend_storage.sh`
- deploy any required resources to Azure
  - `./terraform/deploy_resources.sh`
- build an image containing the Flask server and publish it to the newly deployed
  Container Registry in Azure
  - `./run_publish_docker.sh`
- deploy the K8s manifests to deploy Flask server image to the cluster
  - `./terraform/deploy/deploy_to_cluster.sh`

During this process two points of human interaction may be required.  When the
`./terraform/create-state/init_backend_storage.sh` script is executed, one of the
validations that it performs is to check that the Azure CLI is currently logged
in.  If it detects that the Azure CLI is not logged in, it will present you with
the typical Azure CLI experience.  Failing to login will terminate the script.

The second set of interaction points are on the third, fourth, and sixth steps where
Terraform is deploying resource to Azure.  When Terraform notices any meaningful
changes in the resources, it will display a difference between the current state
and the desired state.  For brand new deployments, these changes should all be
highlighted in green as these are additions to the resources.  However, before
the resource can be deployed, they requires [JW: ??]

Once the entire deployment completes successfully, you should see a message that
looks similar to:

```text
Flask image was deployed to cluster at IP address 000.000.000.000.
```

By entering that address in a browser, either as `000.000.000.000` or as `https://000.000.000.000`,
you should get output like the following:

{
    "message": "Automate all the things!",
    "timestamp": 1695608251
}

This means everything deployed and Azure is host a K8s cluster with the Flask server
running on it!

## How Did We Get From Zero To Cluster?

To be honest, a project like this is best taken a step at a time. Get one piece
of the puzzle working, then move on to the next.  Even if things are not perfect,
if they are good enough for now, you wrap it up and move on.

For this project, here are the steps that were taken:

- [create demo application in Python](https://github.com/jacobwinter314/art-of-the-possible/issues/1)
- [provide localized tests for demo application](https://github.com/jacobwinter314/art-of-the-possible/issues/3)
- [add static project analysis](https://github.com/jacobwinter314/art-of-the-possible/issues/5)
- [create starter pipeline with scan and test jobs](https://github.com/jacobwinter314/art-of-the-possible/issues/7)
- [create local deployment artifacts in Terraform](https://github.com/jacobwinter314/art-of-the-possible/issues/10)
- [add support for build and publish image, including pipeline](https://github.com/jacobwinter314/art-of-the-possible/issues/12)
- [create deploy to kubernetes artifacts in Terraform](https://github.com/jacobwinter314/art-of-the-possible/issues/14)
- [add local deployment of kubernetes manifests](https://github.com/jacobwinter314/art-of-the-possible/issues/16)
- [add support for manifest deployment to pipeline](https://github.com/jacobwinter314/art-of-the-possible/issues/18)
- [uplift local scripts to same as pipelines](https://github.com/jacobwinter314/art-of-the-possible/issues/20)
- [adding better documentation](https://github.com/jacobwinter314/art-of-the-possible/issues/22)

It was not done all at once.  It was deliberately done step by step.

### Taking It Slower - Local Parity

To make this progress go as quickly as it did required some handy tools and the
ability to develop things locally and test them out before having them running
as part of the pipeline.

The first three tasks that were completed were 100% local.  This was the initial
development of the Python server using the `./run_local.sh` script and the testing
of that server using the `./run_tests_local.sh` script.  While everything is very
simple with the server and these scripts, they remain in the project as a quick
way to evaluate if things are still behaving properly.
Even the use of the `./run_scan_local.sh` script is local, and very useful in making
sure that I was not making any mistakes.

A few tasks later, the `./run_docker.sh` script was added to that list.  While
this script and its behavior are integral to producing a Docker image to deploy,
its local use was more important to me.  Any time where I thought I might have
done something wrong to the image, I could execute the `./run_local.sh` script
or the `./run_docker.sh` script and make sure things were okay.

This is why I am a big advocate of local-server parity in development approaches.
It was far easier to invoke one of these scripts to look for a given issue than
it was to deploy it and dig through the Azure Portal's kubernetes events.  It
had a ramp-up time that was measured in seconds, not minutes.  And when you are
working towards deadlines, that difference matters.

For example, there are many times that I have done some matter of error with the
`main.yml` file for the GitHub pipeline.  By the time I find out there is an error,
it is usually at least five minutes, if not fifteen minutes. `[jw: more?]`

And for the record, yes I get upset when I forget to run the `./run_scan_local.sh`
script, only to have the `Lint` job in the pipeline fail.  That is on me.  But
that is one of the reasons I have it there.  To catch those issues early on in
the pipeline before they become real problems in more time expensive jobs.

## Looking For More?

The `docs` directory contains two files:

- [Rough Notes](./docs//project_information.md)
  - my take on the requirements for this project
- [My Interesting Experiences](./docs/interesting.md)
  - my journey to get here with this project

## Meeting The Stated Goals

In the section [Goals](#goals), we provided four primary goals that we wanted
to achieve by working on this project:

### Addressing Concerns with Long Lead Times/Deployment Cycles

Sometimes lead times are just something you have to deal with.  However, there are
things you can do to make your teams more efficient and reduce fragments of that
time.  We believe this goal is not about reducing them to bare minimum, but by
making smart choice to reduce the duration where it makes sense.

Providing [local options](#taking-it-slower---local-parity) helps developers to
evaluate the image, run tests, and scan for common errors, we reduce the time to
get something polished enough to show a colleague.  And by having a [command line](#command-line)
that has parity with the deployment pipeline, it provide the developer with a more
efficient development process.  `[jw: more?]`

By providing these options to make the development cycles more efficient, we believe
that we have shown that we can meet this goal.

### Consistency Between Deployed Environments

By using Terraform, we ready the project for the ability to use
[Terraform Workspace](https://developer.hashicorp.com/terraform/cli/workspaces).
Along with a solid resource naming strategy that includes the environment that the
resource is deployed to, such as `aks-artpossible-dev-westus`, we can easy enable
multiple environment support with a couple of lines of Terraform.

By chosing a smart tool and leaning into that tool, we believe that we have shown
that we can meet this goal.

### Addressing Code Quality Concerns

While any kind of quantification required to meet this goal is difficult, we can
provide decent amounts of anecdotal evidence.

By having a `./run_scan_local.sh` script and its correspond `Lint` job, we can
leverage simple tools to scan for well known problems in all manner of files for
this project.  In addition, by presenting this project as a positive case on how
to make every file as consistent as possible will other files of the same type,
we hope that we inspire other developers to do that same.  Does each bash script
file need to follow our "template" for Batch files? No.  But when we do that,
we believe it allows for a more consistent developer experience, as well as providing
for refactoring suggestions in the future.

As for examples of this, we can only provide many tales of the times where we thought
we typed one thing only to have it fail early with either the scan script or the
Lint job.  Those represent catches that the tooling made that would have otherwise
gone unnoticed until they caused an issue. That is a good thing.

So while we cannot point to any concrete numbers, we believe that we have shown
that we can meet this goal.

### Downtime During Deployments

For this goal, we cannot claim much credit.  Most of that credit should go to the
creators of Kubernetes.

By looking at articles like [this one](https://kubernetes.io/blog/2018/04/30/zero-downtime-deployment-kubernetes-jenkins/),
we can see that there are multiple ways to set up kubernetes to allow it to deploy
to an environment with almost no downtime. Various articles that we read in trying
to address this concern suggest that 15-30 second downtimes are inevitable. But
even then, a downtime measured in seconds per deployment is much better than minutes
or hours using traditional methods.

As with Terraform, by the choice of tools in Kubernetes, we believe that we have
shown that we can meet this goal.

## Cleaning Up the Project

As a friend of mine once said "how can I say goodbye unless you decide to leave?"
We hope that you have had a useful time in using, studying and experimenting with
this project, but we understand your time is valuable. And when you decide to stop
paying attention to this project, we want to help you clear valuable real estate
on you local machine and in Azure.

Oh... er... we also needed to have this script to test that we can install from
zero.  So we got something out of it too!

If you forked this repository to experience the project through the GitHub pipelines,
then you can either disable the pipeline itself or delete the fork to stop working
with it.

For the local scripts, we have provided a `./unrun_me.sh` script that does its
best to remove the project from your system.  In order, it tries to:

- remove any pre-commit artifacts in the folder `./.pre-commit`
