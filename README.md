# AWS CLI Playground

Project contains utility scripts for performing certain tasks using the aws cli.

## Hosting with S3 and CloudFront

### Publish

This directory will contain scripts for helping for helping publish content to 
an existing bucket already configured to host static files for a website and a
matching CloudFront CDN distribution.

### Setup

This directory contains scripts for setting up an S3 bucket with public read
access, and a CloudFront distribution with the created bucket as the source. 
The created distribution will speed up the access to the hosted files and 
enforce access over https.

Once created, the CloudFront distribution will generate a publicly accessible 
URL, which can be obtained by:

1) Visiting the CloudFront in the AWS Console and looking for the distribution 
with the bucket created by this script as the source.
Or
2) Issuing the `aws cloudfront list-distributions` command and examining the 
output. The command's output contains a DistributionsList object with the Items
 array. Each array entry represents one distribution. The top level DomainName 
 for the distribution is the public URL.
