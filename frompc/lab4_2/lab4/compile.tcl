read_verilog pipelined_mips.v
current_design pipelined_mips
link
check_design > check_design.log
source timing.con
compile
report_constraint -all_violators > constraint_report.log
report_area > area_report.log
report_timing > timing_report.log
write_sdf -version 1.0 mapped/pipelined_mips_mapped.sdf
write -f verilog -hier -out mapped/pipelined_mips_mapped.v
quit
