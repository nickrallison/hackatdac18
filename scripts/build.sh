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

if [ -f filelist.f ]; then
  rm filelist.f
  touch filelist.f
fi

# Step 1: Collect and prepend critical files FIRST (defines, packages, includes)
# echo "rtl/includes/pulp_soc_defines.sv" >> filelist.f
# echo "rtl/includes/soc_bus_defines.sv" >> filelist.f
# echo "rtl/includes/periph_bus_defines.sv" >> filelist.f
# echo "ips/pulp_soc/rtl/include/tcdm_macros.svh" >> filelist.f

# # Add FPU packages explicitly before their users
# echo "ips/fpu/hdl/fpu_v0.1/fpu_defs.sv" >> filelist.f
# echo "ips/fpu/hdl/fpu_fmac/fpu_defs_fmac.sv" >> filelist.f
# echo "ips/fpu/hdl/fpu_div_sqrt_tp_nlp/fpu_defs_div_sqrt_tp.sv" >> filelist.f

# # Add ALL adv_dbg_if defines explicitly (to fix includes)
# echo "ips/adv_dbg_if/rtl/adbg_defines.v" >> filelist.f
# echo "ips/adv_dbg_if/rtl/adbg_axi_defines.v" >> filelist.f
# echo "ips/adv_dbg_if/rtl/adbg_lint_defines.v" >> filelist.f  # <-- MISSING BEFORE; CRITICAL FOR lint_module.sv
# echo "ips/axi/axi_node/defines.v" >> filelist.f

find . -name "*defs*.*v" | sed 's|^\./||' | grep -v -E "(pulp_soc_defines\.sv|soc_bus_defines\.sv|periph_bus_defines\.sv|tcdm_macros\.svh|fpu_defs|adbg_defines\.v|adbg_lint_defines\.v|defines\.v)" | sort -u >> filelist.f
find . -name "*define*.*v" | sed 's|^\./||' | grep -v -E "(pulp_soc_defines\.sv|soc_bus_defines\.sv|periph_bus_defines\.sv|tcdm_macros\.svh|fpu_defs|adbg_defines\.v|adbg_lint_defines\.v|defines\.v)" | sort -u >> filelist.f
find . -name "*macro*.*v" | sed 's|^\./||' | grep -v -E "(pulp_soc_defines\.sv|soc_bus_defines\.sv|periph_bus_defines\.sv|tcdm_macros\.svh|fpu_defs|adbg_defines\.v|adbg_lint_defines\.v|defines\.v)" | sort -u >> filelist.f

# Step 2: Generate the rest (include TB files for now; exclude if synthesis-only)
find . -name "*.svh" -o -name "*_pkg.sv" | sed 's|^\./||' | sort -u >> filelist.f
find . -name "*.*v" | grep -v '.git' | grep -v ".venv" | grep -v "tb_" | sed 's|^\./||' | sort -u >> filelist.f

# Step 3: Run yosys with fixes
yosys -p "verific -set-warning VERI-1245" \
      -p "verific -set-warning VERI-1128" \
      -p "verific -set-warning VERI-1952" \
      -p "verific -set-warning VERI-1188" \
      -p "verific -set-warning VERI-1390" \
      -p "verific -set-warning VERI-1684" \
      -p "verific -set-warning VERI-1158" \
      -p "verific -vlog-incdir ." \
      -p "verific -vlog-incdir ips" \
      -p "verific -vlog-incdir ips/axi" \
      -p "verific -vlog-incdir ips/axi/axi_node" \
      -p "verific -vlog-incdir rtl/includes" \
      -p "verific -vlog-incdir ips/pulp_soc/rtl/include" \
      -p "verific -vlog-incdir ips/fpu/hdl" \
      -p "verific -vlog-incdir ips/adv_dbg_if" \
      -p "verific -vlog-incdir ips/adv_dbg_if/rtl" \
      -p "verific -vlog-define DECERR=2'b11" \
      -p "verific -vlog-define SLVERR=2'b10" \
      -p "verific -vlog-define OKAY=2'b00" \
      -p "verific -vlog-define NB_CORES=8" \
      -p "verific -vlog-define DBG_LINT_REGSELECT_SIZE=4" \
      -p "verific -vlog-define DBG_LINT_CMD_IREG_WR=4'h0" \
      -p "verific -vlog-define DBG_LINT_CMD_IREG_SEL=4'h1" \
      -p "verific -vlog-define DBG_LINT_CMD_BWRITE8=4'h2" \
      -p "verific -vlog-define DBG_LINT_CMD_BWRITE16=4'h3" \
      -p "verific -vlog-define DBG_LINT_CMD_BWRITE32=4'h4" \
      -p "verific -vlog-define DBG_LINT_CMD_BWRITE64=4'h5" \
      -p "verific -vlog-define DBG_LINT_CMD_BREAD8=4'h6" \
      -p "verific -vlog-define DBG_LINT_CMD_BREAD16=4'h7" \
      -p "verific -vlog-define DBG_LINT_CMD_BREAD32=4'h8" \
      -p "verific -vlog-define DBG_LINT_CMD_BREAD64=4'h9" \
      -p "verific -f -sv filelist.f"
