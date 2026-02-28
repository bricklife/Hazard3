# project.tcl -- Gowin EDA project script for Hazard3 Tang Nano 9K target
#
# Usage (called from TangNano9K.mk):
#   gw_sh project.tcl <device_family> <device_part> <project_name> \
#                     <cst_abs> <sdc_abs> <filelist_abs>
#
# The Makefile generates <filelist_abs> containing:
#   set SRCS    { ... absolute Verilog source paths ... }
#   set INCDIRS { ... absolute include directory paths ... }

set device_family [lindex $argv 0]   ;# e.g. GW1NR-9C
set device_part   [lindex $argv 1]   ;# e.g. GW1NR-LV9QN88PC6/I5
set project_name  [lindex $argv 2]   ;# e.g. fpga_tangnano9k
set cst_file      [lindex $argv 3]   ;# absolute path to .cst
set sdc_file      [lindex $argv 4]   ;# absolute path to .sdc
set filelist      [lindex $argv 5]   ;# absolute path to filelist.tcl

source $filelist   ;# defines $SRCS and $INCDIRS

set_option -output_base_name ${project_name}
set_device -name ${device_family} ${device_part}

set_option -verilog_std sysv2017
set_option -print_all_synthesis_warning 1
set_option -place_option 2
set_option -route_option 2

foreach d $INCDIRS {
    if {$d ne ""} { set_option -include_path $d }
}

foreach f $SRCS {
    if {$f ne ""} { add_file -type verilog $f }
}

add_file -type cst $cst_file
add_file -type sdc $sdc_file

set_option -top_module ${project_name}

run all
