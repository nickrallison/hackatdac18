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

if [ -d ips/pulp_soc ]; then
  rm -rf ips/pulp_soc
fi

if [ -f filelist.f ]; then
  rm filelist.f
  touch filelist.f
fi

# Generate initial filelist
find . -name "*.svh" -o -name "*_pkg.sv" | sort -u > filelist.f  # Includes and packages first
find . -name "*.*v" | grep -v '.git' | sort -u >> filelist.f  # Everything else

# # Now run Yosys/Verific with more warnings suppressed and additional incdirs
# yosys -p "verific -set-warning VERI-1245" \ 
#       -p "verific -set-warning VERI-1128" \ 
#       -p "verific -set-warning VERI-1952" \ 
#       -p "verific -set-warning VERI-1188" \ 
#       -p "verific -set-warning VERI-1390" \ 
#       -p "verific -set-warning VERI-1684" \ 
#       -p "verific -set-warning VERI-1206" \ 
#       -p "verific -set-warning VERI-1295" \ 
#       -p "verific -set-warning VERI-1137" \ 
#       -p "verific -set-warning VERI-1158" \ 
#       -p "verific -set-warning VERI-1928" \ 
#       -p "verific -set-warning VERI-2142" \ 
#       -p "verific -set-warning VERI-1233" \ 
#       -p "verific -set-warning VERI-2418" \ 
#       -p "verific -set-warning VERI-2561" \ 
#       -p "verific -set-warning VERI-1199" \ 
#       -p "verific -set-warning VERI-1310" \ 
#       -p "verific -set-warning VERI-2418" \ 
#       -p "verific -set-warning VERI-1206" \ 
#       -p "verific -vlog-incdir ." \ 
#       -p "verific -vlog-incdir ips" \ 
#       -p "verific -vlog-incdir ips/axi" \ 
#       -p "verific -vlog-incdir rtl/includes" \ 
#       -p "verific -vlog-incdir ips/pulp_soc/rtl/include" \ 
#       -p "verific -f -sv filelist.f"

# echo "Verific parsing completed (warnings may be present, but all files processed)."

# find . -name "*.svh" | grep -v '.git' >> filelist.f
# find . -name "*.*v" | grep -v '.git' >> filelist.f
yosys -p "verific -set-warning VERI-1245" \
      -p "verific -set-warning VERI-1128" \
      -p "verific -set-warning VERI-1952" \
      -p "verific -set-warning VERI-1188" \
      -p "verific -set-warning VERI-1390" \
      -p "verific -set-warning VERI-1684" \
      -p "verific -vlog-incdir rtl/includes" \
      -p "verific -vlog-incdir ips/pulp_soc/rtl/include" \
      -p "verific -f -sv filelist.f"
