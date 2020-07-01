#!/bin/bash

curl -s http://localhost:8111/check/local/mysql/local | jq .
