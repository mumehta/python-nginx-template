#!/bin/bash -e

aws s3 sync s3://isentia-kube-config/web/ ./templates/
