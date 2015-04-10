action = "simulation"
sim_tool = "modelsim"
top_module = "position_tb"

target = "xilinx"
syn_device = "xc7a200t"

modules = {"local" : ["../../",
                        "../../ip_cores/general-cores/"]}

files = ["position_tb.vhd", "blk_mem_gen_v8_2.vhd"]
