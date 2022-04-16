#!/bin/bash

SOURCE="$1"
BUCKET="$2"

aws s3 cp $SOURCE s3://$BUCKET --recursive --acl public-read
echo "##vso[task.setvariable variable=copyBucket]success"