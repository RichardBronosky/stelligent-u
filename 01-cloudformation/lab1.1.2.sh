#!/bin/bash

parameters="parameters.json"
template="cfn-s3_example.yaml"
log_file="$(basename "$0" .sh).output.$(date '+%Y-%m-%d_%H.%M.%S').txt"

generate_stack_name="$(cat <<'JQ'
# First I wrote this on the shell
#   jq '.[]|select(.ParameterKey=="BucketNameParameter").ParameterValue | gsub("[^A-Za-z0-9]"; "-")' parameters.json
# Then I made Clean Code

def value_of(name): name as $name |
    .[]|select(.ParameterKey==$name).ParameterValue
;

def fix_stack_name:
    gsub("[^A-Za-z0-9]"; "-")
;

def generate_stack_name_from(name): name as $name |
    value_of($name) | fix_stack_name
;

generate_stack_name_from("BucketNameParameter")
JQ
)"

stack_name="$(jq -r "$generate_stack_name" "$parameters")"

aws cloudformation create-stack \
        --stack-name "$stack_name" \
        --template-body file://$template \
        --parameters    file://$parameters \
    | tee "$log_file"

