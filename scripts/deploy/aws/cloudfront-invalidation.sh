#!/bin/bash

CLOUDFRONT_ALIAS="$1"
CLOUDFRONT_ID=$(aws cloudfront list-distributions | jq -r --arg CLOUDFRONT_ALIAS "$CLOUDFRONT_ALIAS" '.DistributionList.Items | map (select(.Aliases.Items[0]==$CLOUDFRONT_ALIAS)) | .[].Id')
CLOUDFRONT_ID=$(echo $CLOUDFRONT_ID | sed -e 's/"//g')
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths "/*"