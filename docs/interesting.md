# Interesting

This was an interesting experience to go through, and I believe that I have learned
a lot.

## Things to be proud of

- GOT IT DONE!!!
  - there were times during the process where I thought things would do me in
  - kept on pushing, researching, trying, and moving forward
  - permissions suck (did not learn this, but was reminded of this)
- high degree of parity between developing and testing locally and through pipelines
  - allows developers to check before they move stuff up
- love how the "dockerized" terraform is working out
  - a couple of small things, but works without polluting the local environment
- bash trickery
  - getting to really flex my bash skills in orchestrating the bash scripts
- bash "single responsibility" script
  - each script does a single thing, and then is leveraged
  - each script has a "standard" format, making it easy to read (IMHO)
- static project analysis
  - helped avoid at least a dozen small issues here and there.
- using the Microsoft Resource Naming Strategy
  - it was just the naming strategy that I picked, but it makes things look professional
- set up for using Terraform Workspaces for a multiple environment approach

## Learnings

- work to call "dockerized" terraform was worth it
  - not 100% sure, due to env var passing, but close to having it on cmd line
  - flexibility to adapt to different Az Cli and Terraform versions instantly is cool (~5min)
- sometimes its about doing it right, and sometimes it is about getting it done
  - the hard part if finding the balance point that does not feel like you are letting yourself down or your client down
  - incremental progress is better than hyper-focusing on one part of the puzzle
- quality is something that can be sacrificed to meet time goals, but always record debts for later
  - i.e. hardwiring names so can make progress, knowing it will come back to haunt me later

## Future

- along with Terraform Workspaces, dealing with multiple environments
  - workspaces are efficient in dealing with environments
  - can make small changes to the Terraform files to understand which workspace
    it is in
- do better job and pulling common functions out of scripts and into common directory
  - quite a few of the "setup" scripts could just be sourced
- enabled coverage publishing
  - template for publishing coverage artifacts there, but not enabled
- version stamping
  - hard to tell from an API call if the current version was deployed
  - would be nice
- deploy test
  - if version stamping in place, can verify that the given node has been deployed
- add caching support for pre-commit
  - can save time if being run time and time again

- post IP address of node in cluster to PullRequest
  - take the IP address and use (actions/github-script@v6) to publish it
- special values are not encoded between jobs
  - `ACR_PASSWORD` is passed between jobs without being encoded
  - (cloudposse/github-action-secret-outputs@0.1.1) can be used to pass them
- "dockerized" terraform needs to sync up with local user's permissions
  - right now, have to occasionally do `chown -R <user> .`
- "dockerized" terraform image needs to clear up issues with non-root
  - was temporarily disabled to make progress
- reorganize scripts and directories to make more sense
  - not sure if current organization is the correct one
  - current guiding principle is the tooling used i.e. all terraform stuff under `terrraform`
- talk to people to find out right balance of "configurability"
  - tricking out EVERY option of EVERY terraform resource sounds counter-productive
- need to add more "verbiage" with a VERBOSE flag
  - strike a balance between reporting everything (for me), some things (most people), and bare minimum (some people)
- image is ALWAYS built and continues forward
  - need to detect whether the image was changed at all, not pushing if so
- "compound" scripts should have option for filename to store "results" in
  - make it easier to show responsibility, who should clean up, etc.
- `deploy_to_cluster.sh` script could use command line parameter to auto-accept
  - just feels better having the control, but might become painful
- move `k8s` terraform code into module
  - more clean
- move pipeline code into more manageable actions
  - more clean
- optional support for App Insights
  - would need to use special python library to feed into it
- optional tagging of resources
  - not sure how useful would be on small project
- support more options for K8s infra
  - current options are limited and narrow in scope, could easily be expanded
- integration tests
  - spot in the main.yml file for them, but not really much for them to do currently
- add Checkov checks to pre-commit
- add `anchore/scan-action@v3.3.5` to check for image vulnerabilities against
- add TFSec checks to pre-commit
  - spot security bad habits for infra
- add Terradoc checks to pre-commit
  - document what is in the terraform files
