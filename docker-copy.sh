#!/bin/bash

srcRepo=<src repo url>
dstRepo=<dst repo url>

services=$(curl -s https://raw.githubusercontent.com/root-voicenet/public/main/main.env | awk -F'=' '{gsub("_", "-", $1); print tolower($1)":"$2}')

IFS='
'

for n in $services; do
  docker manifest inspect $dstRepo/$n > /dev/null
  if [[ $? -eq 0 ]]; then
          echo "Image $n already exist"
          continue;
  fi
  echo "Copy image $n"
  docker pull $srcRepo/$n
  docker tag $srcRepo/$n $dstRepo/$n
  docker push $dstRepo/$n
  docker rmi $dstRepo/$n
  docker rmi $srcRepo/$n
done;
