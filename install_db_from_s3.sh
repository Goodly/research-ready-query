#!/bin/bash
# $1 is the name of the database file to copy from S3.
# The Elastic Beanstalk instance has permission to read, but not write,
# to s3://research-ready/db-snapshots/
aws s3 cp s3://research-ready/db-snapshots/${1} database.db
# sudo is needed when logged in as ec2-user.
sudo mkdir -p /var/app/research-ready/
# Use the path specified in config.py
sudo mv database.db /var/app/research-ready/
# Change new directory and database to be owned by webapp user:group
sudo chown -R webapp:webapp /var/app/research-ready/
# Take a look and see if everything is in order.
ls -l /var/app/research-ready/
