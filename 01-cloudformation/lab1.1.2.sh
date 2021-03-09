#!/bin/bash

aws cloudformation create-stack \
        --stack-name StelligentULab1n1n1uBrunoBronosky \
        --template-body file://cfn-s3_example.yaml
