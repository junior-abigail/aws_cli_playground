# AWS CLI Playground

Project contains utility scripts for performing certain tasks using the aws cli.

## Hosting with S3 and CloudFront

This directory contains the create_s3_bucket script for setting up an S3 bucket
 with public read access, and a CloudFront distribution with the created bucket
 as the source. The created distribution will speed up the access to the hosted 
 files and enforce access over https.

The script will also generate a helper script for publishing your site's static
 files to the s3 bucket and starting the process of invalidating the cloudfront
 distribution, which will trigger the update to the edge locations hosting the
 files.

The CloudFront distribution created will generate a publicly accessible
 URL, which can be obtained by:

1) Visiting the CloudFront in the AWS Console and looking for the distribution
 with the bucket created by this script as the source.

Or

2) Issuing the `aws cloudfront list-distributions` command and examining the
 output. The command's output contains a DistributionsList object with the
 Items array. Each array entry represents one distribution. The top level
 DomainName for the distribution is the public URL.

### Example

Running the script issuing the command `create_s3_bucket.sh <bucket_name>` will
 create an s3 bucket called <bucket_name>, and a cloudfront distribution for
 it. It will generate a script called publish_to_<bucket_name>.sh, which can
 then be ran by issuing the command `publish_to_<bucket_name>.sh <directory>
 to sync the contents of <directory> with the s3 bucket, and trigger the cache
 refresh.
 