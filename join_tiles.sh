#!/usr/bin/env bash

for A in $(find mapas/ -name '*.yml'); do
  if [ ! -e "mapas/full/$(basename $A)" ]; then
    echo "mapas/full/$(basename $A)"
    ruby join_tiles.rb $A
  fi
done
