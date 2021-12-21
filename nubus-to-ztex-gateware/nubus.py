from migen import *
from migen.genlib.fifo import *

import litex

class NuBus(Module):
    def __init__(self, platform, cd_nubus="nubus"):
        # unused & unconnected
        # self.nubus_pwf_n = Signal(reset = 1)
        # self.nubus_sp_n = Signal(reset = 1)
        # self.nubus_spv_n = Signal(reset = 1)
        # self.nubus_tm2_n = platform.request("nubus_tm2_n"),

        # memory
        self.mem_valid = Signal()
        self.mem_addr = Signal(32)
        self.mem_wdata = Signal(32)
        self.mem_write = Signal(4)
        self.mem_ready = Signal()
        self.mem_rdata = Signal(32)
        self.mem_error = Signal()
        self.mem_tryagain = Signal()

        # cpu
        #self.cpu_valid = Signal(reset = 0)
        #self.cpu_addr = Signal(32)
        #self.cpu_wdata = Signal(32)
        #self.cpu_ready = Signal()
        #self.cpu_write = Signal(4)
        #self.cpu_rdata = Signal(32)
        #self.cpu_lock = Signal()
        #self.cpu_eclr = Signal()
        #self.cpu_errors = Signal(4)

        # utilities
        self.tmoen = Signal()
        self.mem_stdslot = Signal()
        self.mem_super = Signal()
        self.mem_local = Signal()

        self.add_sources(platform)
        
        #fixme: parameters
        self.specials += Instance(self.get_netlist_name(),
                                  # master side
                                  #p_SIMPLE_MAP = 0x0,
                                  p_SLOTS_ADDRESS = 0xf,
                                  p_SUPERSLOTS_ADDRESS = 0x9,
                                  p_WDT_W = 0x8,
                                  p_LOCAL_SPACE_EXPOSED_TO_NUBUS = 0,
                                  p_NON_ECC_PARITY = 0,
                                  i_nub_clkn = ClockSignal(cd_nubus),
                                  i_nub_resetn = ~ResetSignal(cd_nubus),
                                  i_nub_idn = platform.request("id_3v3_n"),
                                  # io_nub_pfwn = self.nubus_pwf_n,
                                  io_nub_adn = platform.request("ad_3v3_n"),
                                  io_nub_tm0n = platform.request("tm0_3v3_n"),
                                  io_nub_tm1n = platform.request("tm1_3v3_n"),
                                  io_nub_startn = platform.request("start_3v3_n"),
                                  io_nub_rqstn = platform.request("rqst_3v3_n"),
                                  io_nub_ackn = platform.request("ack_3v3_n"),
                                  # io_nub_arbn = platform.request("nubus_arb_n"),
                                  o_arb = platform.request("arb"),
                                  i_grant = platform.request("grant"),
                                  o_tmoen = platform.request("tmoen"),
                                  o_NUBUS_AD_DIR = platform.request("nubus_ad_dir"),
                                  io_nub_nmrqn = platform.request("nmrq_3v3_n"),
                                  # io_nub_spn = self.nubus_sp_n,
                                  # io_nub_spvn = self.nubus_spv_n,
                                  o_mem_valid = self.mem_valid,
                                  o_mem_addr = self.mem_addr,
                                  o_mem_wdata = self.mem_wdata,
                                  o_mem_write = self.mem_write,
                                  i_mem_ready = self.mem_ready,
                                  i_mem_rdata = self.mem_rdata,
                                  i_mem_error = self.mem_error,
                                  i_mem_tryagain = self.mem_tryagain,
                                  #i_cpu_valid = self.cpu_valid,
                                  #i_cpu_addr = self.cpu_addr,
                                  #i_cpu_wdata = self.cpu_wdata,
                                  #o_cpu_ready = self.cpu_ready,
                                  #i_cpu_write = self.cpu_write,
                                  #o_cpu_rdata = self.cpu_rdata,
                                  #i_cpu_lock = self.cpu_lock,
                                  #i_cpu_eclr = self.cpu_eclr,
                                  #o_cpu_errors = self.cpu_errors,
                                  o_mem_stdslot = self.mem_stdslot,
                                  o_mem_super = self.mem_super,
                                  o_mem_local = self.mem_local)
                
    def get_netlist_name(self):
        return "nubus"

    def add_sources(self, platform):
        platform.add_source("nubus.v", "verilog")
        platform.add_source("/home/dolbeau/XiBus/nubus.svh", "verilog")
        #platform.add_source("/home/dolbeau/XiBus/nubus_arbiter.v", "verilog")
        #platform.add_source("/home/dolbeau/XiBus/nubus_cpubus.v", "verilog")
        platform.add_source("/home/dolbeau/XiBus/nubus_driver.v", "verilog")
        #platform.add_source("/home/dolbeau/XiBus/nubus_errors.v", "verilog")
        platform.add_source("/home/dolbeau/XiBus/nubus_membus.v", "verilog")
        #platform.add_source("/home/dolbeau/XiBus/nubus_master.v", "verilog")
        platform.add_source("/home/dolbeau/XiBus/nubus_slave.v", "verilog")
