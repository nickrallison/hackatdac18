yosys -p "\
  verific -vlog-incdir rtl/includes; \
  verific -sv -DSYNTHESIS \
    rtl/includes/periph_bus_defines.sv \
    rtl/includes/soc_bus_defines.sv \
    rtl/includes/pulp_soc_defines.sv \
    ips/riscv/include/riscv_defines.sv \
    ips/riscv/include/riscv_config.sv \
    ips/zero-riscy/include/zeroriscy_defines.sv \
    ips/zero-riscy/include/zeroriscy_config.sv \
    ips/riscv/include/apu_core_package.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_defs.sv \
    ips/fpu/hdl/fpu_v0.1/defines_fpu.sv \
    ips/hwpe-stream/rtl/hwpe_stream_package.sv \
    ips/hwpe-mac-engine/rtl/mac_package.sv \
    ips/hwpe-ctrl/rtl/hwpe_ctrl_package.sv; \
  verific -sv -DSYNTHESIS \
    $(find rtl/pulpissimo ips/common_cells ips/tech_cells_generic ips/scm -name '*.sv' -o -name '*.v' | grep -v '/tb/' | sort | tr '\n' ' '); \
  verific -sv -DSYNTHESIS \
    ips/fpu/hdl/fpu_v0.1/fpu_defs.sv \
    ips/fpu/hdl/fpu_v0.1/defines_fpu.sv \
    ips/fpu/hdl/fpu_utils/fpu_ff.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_shared.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_private.sv \
    ips/fpu/hdl/fpu_v0.1/fpexc.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_add.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_mult.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_norm.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_ftoi.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_itof.sv \
    ips/fpu/hdl/fpu_v0.1/fpu_core.sv \
    ips/fpu/hdl/fpu_v0.1/fp_fma_wrapper.sv \
    ips/fpu/hdl/fpu_v0.1/riscv_fpu.sv \
    ips/fpu/hdl/fpu_v0.1/fpu.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/fpu_defs_div_sqrt_tp.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/preprocess.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/fpu_ff.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/fpu_norm_div_sqrt.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/iteration_div_sqrt_first.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/iteration_div_sqrt.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/nrbd_nrsc_tp.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/control_tp.sv \
    ips/fpu/hdl/fpu_div_sqrt_tp_nlp/div_sqrt_top_tp.sv; \
  verific -sv -DSYNTHESIS \
    ips/fpu/hdl/fpu_fmac/fpu_defs_fmac.sv \
    $(find ips/fpu/hdl/fpu_fmac -name '*.sv' -o -name '*.v' | grep -v '/tb/' | grep -v 'fpu_defs_fmac.sv' | sort | tr '\n' ' '); \
  verific -sv -DSYNTHESIS \
    $(find ips -path '*/rtl/*.sv' -o -path '*/rtl/*.v' | grep -E '(hwpe|axi|L2_tcdm_hybrid_interco|udma|apb|jtag_pulp|zero-riscy|pulp_soc|adv_dbg_if|riscv)/' | grep -v -E '(vip|tb|testbench|verilator-model|wrap)' | sort | tr '\n' ' '); \
  hierarchy -top pulpissimo; \
  flatten; \
  write_verilog flattened.v"