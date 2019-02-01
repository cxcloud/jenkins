#!/bin/bin

# Disable echoing used for debugging
function assumeRole() {
    set +x
    echo "Assuming role: $1"

    CREDTUPLE=($(aws sts assume-role --role-arn $1 --role-session-name $(date +"%s")  --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' --output text))

    AWS_ACCESS_KEY_ID=${CREDTUPLE[0]}
    AWS_SECRET_ACCESS_KEY=${CREDTUPLE[1]}
    AWS_SESSION_TOKEN=${CREDTUPLE[2]}

    echo "Exported"
    echo "========"
    echo "AWS_ACCESS_KEY_ID:******"
    echo "AWS_SECRET_ACCESS_KEY:****"
    echo "AWS_SESSION_TOKEN:****"
}
