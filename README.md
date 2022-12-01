# Cloud Resume Challenge Frontend

![Alt text](diagram.jpg?raw=true "Title")

[Backend Repo](https://github.com/sallen222/cloudresume-backend)

## Summary
This repo contains the frontend of my cloud resume project inspired by the [Cloud Resume Challenge](https://cloudresumechallenge.dev/docs/the-challenge/aws/).

## Infrastructure
The frontend consists of a static website hosted in S3 and distributed via CloudFront. SSL via ACM is configured to allow connections via HTTPS and an origin access identity prevents direct access to the S3 bucket.

## Deployment
These resources are built and deployed automatically using Terraform and Github Actions. 