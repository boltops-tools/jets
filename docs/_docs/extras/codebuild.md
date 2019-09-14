---
title: 'Continuous Integration: Jets and CodeBuild'
nav_order: 84
---

This page discusses setting up Continuous Integration.  We'll use [CodeBuild](https://aws.amazon.com/codebuild/), a fully managed build service from AWS.  It is similar to other services like: [circleci](https://circleci.com/), [travis-ci](https://travis-ci.org/), [semaphoreci](https://semaphoreci.com/), etc.

An advantage of using CodeBuild is that you can use IAM roles.  The IAM role associated with the CodeBuild machine is the only thing that requires IAM permission to deploy and create AWS resources.

This security posture is considered better than deploying from a development machine. The only IAM permission required on a development machine is access to start a build.  This reduces the potential blast radius. Additionally, it helps scale the deployment process so additional team members can deploy without setting everything up.

## Examples

The Jets Examples uses the [codebuild.cloud](https://codebuild.cloud/) tool to simplify creating and managing the CodeBuild project. The codebuild tool is essentially a DSL wrapper that creates the CodeBuild project and IAM role with CloudFormation.

The [Jets Example](https://codebuild.cloud/docs/examples/jets/) shows how to set up 1 simple CodeBuild project that will run specs and then deploy the Jets application.

There's also an additional example in the [separate-unit-and-deploy](https://github.com/tongueroo/jets-codebuild/tree/separate-unit-and-deploy) branch in the GitHub repo that shows how to create 2 separate CodeBuild projects for unit tests and deployment. Some advantages:

* The projects are decoupled and you can run them separately.
* Only the deploy project requires IAM access to create the AWS resources.

Refer to the [codebuild.cloud jets examples](https://codebuild.cloud/docs/examples/jets/) docs for the details.

{% include prev_next.md %}