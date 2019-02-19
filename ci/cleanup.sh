#!/bin/bash

sudo find . -maxdepth 1 \! \( -name .cargo -o -name target \) -exec rm -rf '{}' \;
