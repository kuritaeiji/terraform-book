#!/bin/bash

CMK_ID=$1
AWS_REGION=$2
INPUT_FILE=$3
OUTPUT_FILE=$4

cipertext=$(aws kms encrypt \
    --key-id=$CMK_ID \
    --region=$AWS_REGION \
    --plaintext "fileb://$INPUT_FILE" \
    --output text \
    --query CiphertextBlob)

echo $cipertext > $OUTPUT_FILE
