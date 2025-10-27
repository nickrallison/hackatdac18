#!/bin/sh

set -e

chmod +x update-ips
chmod +x update-tests
chmod +x generate-scripts

if [ ! -d ips/pulp_soc/.git ]; then
  rm -rf ips/pulp_soc
  git clone --recurse-submodules https://github.com/pulp-platform/pulp_soc ips/pulp_soc
  cd ips/pulp_soc
  bender update
else 
  cd ips/pulp_soc
fi

bender script flist > pulp_soc_filelist.f
cd ../../

if [ ! -f rtl/includes/soc_mem_map.svh ]; then
  wget https://raw.githubusercontent.com/pulp-platform/pulpissimo/refs/heads/master/hw/includes/soc_mem_map.svh -O rtl/includes/soc_mem_map.svh
fi

# if [ ! -f rtl/includes/axi/typedef.svh ]; then
#   mkdir -p rtl/includes/axi
#   wget https://raw.githubusercontent.com/pulp-platform/axi/refs/heads/master/include/axi/typedef.svh -O rtl/includes/axi/typedef.svh
# fi


# if [ ! -f rtl/includes/axi/assign.svh ]; then
#   mkdir -p rtl/includes/axi
#   wget https://raw.githubusercontent.com/pulp-platform/axi/refs/heads/master/include/axi/assign.svh -O rtl/includes/axi/assign.svh
# fi

if [ ! -d venv ]; then
  python3 -m venv venv
  . venv/bin/activate
  python3 -m pip install pyyaml
else
  . venv/bin/activate
fi  
python3 update-ips
# python3 generate-scripts

if [ -f filelist.f ]; then
  rm filelist.f
  touch filelist.f
fi

echo "+incdir+."  >> filelist.f
echo "+incdir+ips"  >> filelist.f
echo "+incdir+ips/axi"  >> filelist.f
echo "+incdir+ips/axi/axi_node"  >> filelist.f
echo "+incdir+ips/axi/rtl/include"  >> filelist.f
echo "+incdir+rtl/includes"  >> filelist.f
echo "+incdir+rtl/includes/axi"  >> filelist.f
echo "+incdir+ips/pulp_soc/rtl/include"  >> filelist.f
echo "+incdir+ips/fpu/hdl"  >> filelist.f
echo "+incdir+ips/adv_dbg_if"  >> filelist.f
echo "+incdir+ips/adv_dbg_if/rtl"  >> filelist.f
echo "+incdir+ips/udma/rtl"  >> filelist.f
echo "+incdir+ips/apb"  >> filelist.f

includes=$(find . -name assign.svh | xargs -I % dirname % | xargs -I % dirname % | printf +incdir+)


find . -name "*.svh" | \
  grep -v "tb_" | \
  grep -v "formal" | \
  grep -v "cov" | \
  grep -v "" | \
  sed 's|^\./||' >> filelist.f
find . -name "*defs*.*v" | sed 's|^\./||' >> filelist.f
find . -name "*define*.*v" | sed 's|^\./||' >> filelist.f
find . -name "*macro*.*v" | sed 's|^\./||' >> filelist.f

# Step 2: Generate the rest (include TB files for now; exclude if synthesis-only)
find . -name "*.*v" | grep -v '.git' | grep -v ".venv" | grep -v "tb_" | sed 's|^\./||' | sort -u >> filelist.f

# Step 3: Run yosys with fixes

yosys -p "verific -set-warning VERI-1245" \
      -p "verific -set-warning VERI-1128" \
      -p "verific -set-warning VERI-1952" \
      -p "verific -set-warning VERI-1188" \
      -p "verific -set-warning VERI-1390" \
      -p "verific -set-warning VERI-1684" \
      -p "verific -set-warning VERI-1158" \
      -p "verific -set-warning VERI-1240" \
      -p "verific -set-warning VERI-1116" \
      -p "verific -vlog-incdir ." \
      -p "verific -vlog-incdir ips" \
      -p "verific -vlog-incdir ips/axi" \
      -p "verific -vlog-incdir ips/axi/axi_node" \
      -p "verific -vlog-incdir ips/axi/rtl/include" \
      -p "verific -vlog-incdir rtl/includes" \
      -p "verific -vlog-incdir ips/pulp_soc/rtl/include" \
      -p "verific -vlog-incdir ips/fpu/hdl" \
      -p "verific -vlog-incdir ips/adv_dbg_if" \
      -p "verific -vlog-incdir ips/adv_dbg_if/rtl" \
      -p "verific -vlog-incdir ips/udma/rtl" \
      -p "verific -vlog-incdir ips/apb" \
      -p "verific -vlog-define DECERR=2'b11" \
      -p "verific -vlog-define SLVERR=2'b10" \
      -p "verific -vlog-define OKAY=2'b00" \
      -p "verific -vlog-define NB_CORES=8" \
      -p "verific -f -sv filelist.f"

      # -p "verific -f -sv ips/pulp_soc/pulp_soc_filelist.f" \
