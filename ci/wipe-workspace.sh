#!/bin/bash

for i in $(ls -A | grep -v .cargo | grep -v .git | grep -v target | grep -v runtime )
do
  echo "Removing $i"
  sudo rm -rf $i
done

echo "Removing runtime (except the runtime/wasm/target directory)"
find runtime/wasm -mindepth 1 -not -path "*runtime/wasm/target*" | sudo xargs rm -rf
find runtime -mindepth 1 -not -path "*runtime/wasm*" | sudo xargs rm -rf