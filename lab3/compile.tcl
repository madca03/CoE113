read_verilog single_cycle_mips.v
read_verilog alu.v
read_verilog rf.v
current_design single_cycle_mips
link
check_design > check_design.log
source timing.con
compile
report_constraint -all_violators > constraint_report.log
report_area > area_report.log
report_timing > timing_report.log
write_sdf -version 1.0 mapped/single_cycle_mips_mapped.sdf
write -f verilog -hier -out mapped/single_cycle_mips_mapped.v
quit
