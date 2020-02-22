# AWS CLI Playground

Project contains utility scripts for performing certain tasks using the aws
 cli. Each task may involve issuing multiple commands available trough the
 aws cli, and make use of other tools for assisting in the process of chaining
 all the required commands together to complete the task, as is the case when
 one aws cli command requires as input part of the output of another aws cli
 command.

## Project Structure

Each directory in the repository will contain the script for completing the
 task and all supporting files needed.

## Dependencies

### Tools

The following tools must be installed in your system in order to run these 
 scripts:
 - aws cli
 - envsubst
 - jq

### Permissions

You must configure the aws cli with the credentials of an user account that has
 been granted the permissions needed to perform the tasks that you are trying
 to complete. These permissions will be listed for each task in the 
 [Tasks](#Tasks) section.

## Tasks

### Hosting with S3 and CloudFront

Required permissions: ( TODO: Update this section )

This directory contains the create_s3_bucket script for setting up an S3 bucket
 with public read access, and a CloudFront (CDN) distribution with the created
 bucket as the source. The created distribution will speed up the access to the
 hosted files and enforce access over https.

The script will also generate a helper script for publishing your site's static
 files to the s3 bucket and starting the process of invalidating the cloudfront
 distribution, which will trigger the update to the edge locations hosting the
 files.

The CloudFront distribution created will generate a publicly accessible
 URL, which can be obtained by one of the following:

1) Visiting the CloudFront in the AWS Console and looking for the distribution
 with the bucket created by this script as the source.

2) Issuing the `aws cloudfront list-distributions` command and examining the
 output. The command's output contains a DistributionsList object with the
 Items array. Each array entry represents one distribution. The top level
 DomainName for the distribution is the public URL.

