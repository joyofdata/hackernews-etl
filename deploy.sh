#!/usr/bin/env bash

hn_etl_root_dir=$(pwd)

cd ../hackernews-api

poetry export -f requirements.txt > /tmp/requirements.txt
pip install ../hackernews-api -t /tmp/hackernews-etl/python/

cd /tmp/hackernews-etl

zip -r /tmp/lambda_layer_hackernews_etl.zip python

cd $hn_etl_root_dir

mv /tmp/lambda_layer_hackernews_etl.zip $hn_etl_root_dir/dist

zip --junk-paths dist/lambda_hackernews_etl.zip lambdas/lambda_import_main_stories_by_day.py

terraform apply --auto-approve