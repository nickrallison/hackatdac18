#!/bin/sh

set -e

chmod +x update-ips
chmod +x update-tests
chmod +x generate-scripts

if [ -d ips/pulp_soc ]; then
  rm -rf ips/pulp_soc
fi

if [ ! -d venv ]; then
  python3 -m venv venv
  . venv/bin/activate
  python3 -m pip install pyyaml
else
  . venv/bin/activate
fi  
which python3
python3 ./update-ips

find . -name "*.*v" > filelist.f
yosys -p "verific -vlog-incdir rtl/includes" \
  -p "verific -sv $(cat filelist.f | grep -v '#' | tr '\n' ' ')"
