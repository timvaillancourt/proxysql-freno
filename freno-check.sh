#!/bin/bash

curl -s http://localhost:8111/check/freno-check/mysql/testbed | jq .
