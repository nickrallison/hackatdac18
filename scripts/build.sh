yosys -p "\
  verific -vlog-incdir rtl/includes; \
  verific -sv $(find rtl ips hdl -name "*.sv" -o -name "*.v" | grep -v '^rtl/tb/' | tr '\n' ' '); \
  hierarchy -top pulpissimo; \
  flatten; \
  write_verilog flattened.v"