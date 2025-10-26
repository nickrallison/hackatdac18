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

# if [ -d ips/pulp_soc ]; then
#   rm -rf ips/pulp_soc
# fi

if [ -f filelist.f ]; then
  rm filelist.f
  touch filelist.f
fi

# Generate initial filelist
find . -name "*.svh" -o -name "*_pkg.sv" | sed 's|^\./||' | sort -u > filelist.f
find . -name "*.*v" | grep -v '.git' | grep -v ".venv" | sed 's|^\./||' | sort -u >> filelist.f


yosys -p "verific -set-warning VERI-1245" \
      -p "verific -set-warning VERI-1128" \
      -p "verific -set-warning VERI-1952" \
      -p "verific -set-warning VERI-1188" \
      -p "verific -set-warning VERI-1390" \
      -p "verific -set-warning VERI-1684" \
      -p "verific -vlog-incdir ." \
      -p "verific -vlog-incdir ips" \
      -p "verific -vlog-incdir ips/axi" \
      -p "verific -vlog-incdir ips/axi/axi_node" \
      -p "verific -vlog-incdir rtl/includes" \
      -p "verific -vlog-incdir ips/pulp_soc/rtl/include" \
      -p "verific -vlog-define DECERR=2'b11" \
      -p "verific -vlog-define SLVERR=2'b10" \
      -p "verific -vlog-define OKAY=2'b00" \
      -p "verific -f -sv filelist.f"
