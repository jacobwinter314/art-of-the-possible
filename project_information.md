# Sample Code Project

## Problem Statement

- client currently on premise and an infrastructure shop
- developer issues with:
  - kickstarting/creating new environments
  - long lead times and cycles for developing the infrastructure
  - environments not consistent
- management issues with:
  - deployments causing downtime
  - long lead times
- client interested in containerization
  - maybe k8s?

## Helping Information

- create demo application with simple REST endpoint that display static message with current timestamp
  - timestamp is in seconds since epoch, not milliseconds
- deploy to K8s cluster on cloud provider of choice
- provisioning through code - Terraform
  - keep an eye on costs and running services
  - reach out to the Slack channel with questions about specific costs

## Requirements

- Commit all code to a public git repository.
- Include a README.md containing detailed directions on how to run, what is running, and
  how to cleanup.
- Provide a single command to launch the environment and deploy the application.
  - Some prerequisites are OK as long as they are properly documented.
  - We should be able to deploy and run the application in our own public cloud accounts.
  - Include some form of automated tests to validate the environment.
- Presentation (deck or medium of your choice)
- Demo prep call with one of the Liatrio engineers
  - recommendations
    - Create a 3-6 slide presentation
      - important: objectives, why you chose certain tech, and lessons learned
      - Make it interesting, assume your audience is a mix of engineers and
        leadership that have different levels of technical background
    - Prepare a live demo

## Answered Questions

- "Is ... Azure is okay for an environment?"
  - per Alice: "The cloud provider is totally your choice, Azure would be fine."
- "A number of people at work know my personal GitHub account, and if I create this
  project there, it will look suspicious.  Would it be possible to keep it private
  and make you guys collaborators?"
  - per Alice: "... I imagine that'd be okay as long as we can see the project. Some
    people create a new GitHub account too, that could be an option as well, which
    might be simpler."

## Open Questions

- Based on the problem statement, would it be sufficient to deploy to Azure AppService
  with deployment slots instead of Kubernetes?
  - from the problem statement, it sounds like the client is not sure if they want
    to go to Kubernetes
  - it is clear that they want containerization, but it is left ambiguous as to
    whether that journey should involve K8s
  - from my experience, Kubernetes is most valuable if you have multiple services
    that need to run togethers OR a single service that needs to autoscale a lot
  - the current problem meets neither of those criteria
  - I would still provide information about K8s, why it was not chosen, why it would
    become a choice in the future
  - i.e. based on the above reasoning, if I am being asked to address the problem
    on behalf of the client, I would feel that K8s would be too large of a leap
    for them to make all at once
  - Note: totally open to collaborating on deciding either option, just wanting to
    put my best foot forward by mentioning it
- No mention is made of Linux/Darwin vs Windows.  Is there a preference?
  - I am conversant in Batch and Bash, able to produce simple scripts in both
- "Provide a single command to launch the environment and deploy the application."
  Does this mean I am restricted to a single script?
  - I am a big fan of providing automated scripts in a project for simple tasks.
  - I would prefer to have a "run_me" script for the main demo, and ancillary
    scripts to show the steps required to get to that point.
  - I would provide documentation on how each script should be used in the
    README.md
