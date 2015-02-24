#!/bin/bash

./das_client.py --query="file dataset= $1" | grep "^/store"
