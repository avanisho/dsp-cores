action = "simulation"
sim_tool = "modelsim"
vcom_opt = "-2008"
top_module = "position_tb"

target = "xilinx"
syn_device = "xc7a200t"

machine_pkg = "uvx_130M" # uvx_130M sirius_130M

modules = {"local" : ["../../",
                        "../../ip_cores/general-cores/","../../sim/test_pkg/"]}

files = ["position_tb.vhd"]
