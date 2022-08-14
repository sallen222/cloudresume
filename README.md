# Cloud Resume Challenge Frontend

Backend Repo: https://github.com/sallen222/cloudresume-backend

This repo contains the frontend infrastructure of my cloud resume project. 
The frontheand consists of a cloudfront distribution using an S3 static website for the origin. SSL via ACm and Route 53 is configured to allow connections via HTTPS and an origin access identity prevents direct access to the S3 bucket.
These resources are deployed using terraform for infrastructure as code.