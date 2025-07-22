#!/bin/bash

cat /banner.txt
cat /version.txt
cat /nemo/kubernetes/info.txt

echo ""
if [ -f ./k ]; then source k; fi
ls -alh --color=auto

