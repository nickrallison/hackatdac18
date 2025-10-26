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

# Step 1: Collect and prepend critical files FIRST (defines, packages, includes)
# This ensures macros/packages are defined before use, avoiding alphabetical sorting issues
echo "rtl/includes/pulp_soc_defines.sv" >> filelist.f
echo "rtl/includes/soc_bus_defines.sv" >> filelist.f
echo "rtl/includes/periph_bus_defines.sv" >> filelist.f
echo "ips/pulp_soc/rtl/include/tcdm_macros.svh" >> filelist.f

# Add FPU packages explicitly before their users
echo "ips/fpu/hdl/fpu_v0.1/fpu_defs.sv" >> filelist.f
echo "ips/fpu/hdl/fpu_fmac/fpu_defs_fmac.sv" >> filelist.f
echo "ips/fpu/hdl/fpu_div_sqrt_tp_nlp/fpu_defs_div_sqrt_tp.sv" >> filelist.f
echo "ips/adv_dbg_if/rtl/adbg_defines.v" >> filelist.f
echo "ips/adv_dbg_if/rtl/adbg_axi_defines.v" >> filelist.f 
echo "ips/axi/axi_node/defines.v" >> filelist.f

# Step 2: Generate the rest as before, but append without sorting (or sort after prepending)
# Use unsorted to preserve some dependency order, or sort but prepend overrides it
find . -name "*.svh" -o -name "*_pkg.sv" | sed 's|^\./||' | grep -v -E "(pulp_soc_defines\.sv|soc_bus_defines\.sv|periph_bus_defines\.sv|tcdm_macros\.svh|fpu_defs|adbg_defines\.v|defines\.v)" | sort -u >> filelist.f
find . -name "*.*v" | grep -v '.git' | grep -v ".venv" | grep -v "tb_" | sed 's|^\./||' | grep -v -E "(pulp_soc_defines\.sv|soc_bus_defines\.sv|periph_bus_defines\.sv|tcdm_macros\.svh|fpu_defs|adbg_defines\.v|defines\.v)" | sort -u >> filelist.f

# Remove duplicates (from prepending)
sort -u filelist.f -o filelist.f

# Now run yosys with additional -vlog-define for key macros (fallback for any missed defines)
# NB_CORES=8 from pulp_soc_defines.sv (use 8 for full design; override to 1 for TB if needed)
# Add other common ones from logs (e.g., FPU params if packages still fail; but reordering should fix most)
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
      -p "verific -vlog-incdir ips/fpu/hdl" \
      -p "verific -vlog-incdir ips/adv_dbg_if/rtl" \
      -p "verific -vlog-define DECERR=2'b11" \
      -p "verific -vlog-define SLVERR=2'b10" \
      -p "verific -vlog-define OKAY=2'b00" \
      -p "verific -vlog-define NB_CORES=8" \
      -p "verific -f -sv filelist.f"
