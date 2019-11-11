---
title: Quick Start
nav_order: 1
---

In a hurry? No problem!  Here's a quick start to get going.

## Local Testing

    gem install jets
    jets new demo
    cd demo
    jets generate scaffold post title:string
    vim .env.development # edit with local db settings
    jets db:create db:migrate
    jets server

The `jets server` command starts a server that mimics API Gateway so you can test locally.  Open [http://localhost:8888/posts](http://localhost:8888/posts) and check out the site. Note, the `DATABASE_URL` format looks like this: `mysql2://dbuser:dbpass@localhost/demo_dev?pool=5`

### Choosing your database type
* `jets new demo --database=postgresql` If you want to create a project backed by postgres
* `jets new demo --database=mysql` If you want to create a project backed by mysql (default)

Create some posts records. The posts page should look something like this:

![Screenshot of the posts UI in a web browser](/img/quick-start/posts-index.png)

## Deploy to AWS Lambda

Once you're ready, edit the `.env.development.remote` with your remote database settings and deploy to AWS.

    $ vim .env.development.remote # adjust with remote db settings
    $ jets deploy
    API Gateway Endpoint: https://puc3xyk4cj.execute-api.us-west-2.amazonaws.com/dev/

Jets deploy creates the corresponding AWS Lambda Functions and API Gateway resources.

Lambda Functions:

![Screenshot of the newly created Lambda functions in the AWS Console](/img/quick-start/demo-lambda-functions.png)

API Gateway:

![Screenshot of the new created API Gateway resources in the AWS Console](/img/quick-start/demo-api-gateway.png)

Congratulations!  You have successfully deployed your serverless ruby application. It's that simple. 😁

{% include prev_next.md %}
