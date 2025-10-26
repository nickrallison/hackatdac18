#!/bin/sh

set -e

# chmod +x update-ips
# chmod +x update-tests
# chmod +x generate-scripts

# if [ -d ips/pulp_soc ]; then
#   rm -rf ips/pulp_soc
# fi

# if [ ! -d venv ]; then
#   python3 -m venv venv
#   . venv/bin/activate
#   python3 -m pip install pyyaml
# else
#   . venv/bin/activate
# fi  
# which python3
# python3 ./update-ips

if [ -f filelist.f ]; then
  rm filelist.f
  touch filelist.f
fi

find . -name "*.svh" | grep -v '.git' >> filelist.f
find . -name "*.*v" | grep -v '.git' >> filelist.f
yosys -p "verific -set-warning VERI-1245" \
      -p "verific -set-warning VERI-1128" \
      -p "verific -set-warning VERI-1952" \
      -p "verific -set-warning VERI-1188" \
      -p "verific -set-warning VERI-1390" \
      -p "verific -set-warning VERI-1684" \
      -p "verific -vlog-incdir rtl/includes" \
      -p "verific -vlog-incdir ips/pulp_soc/rtl/include" \
      -p "verific -f -sv filelist.f"
