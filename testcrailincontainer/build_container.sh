#!/bin/bash

(cd . && docker build -t crailk8stest -f Dockerfile .)
docker tag crailk8stest asqasq/crailk8stest
docker push asqasq/crailk8stest



