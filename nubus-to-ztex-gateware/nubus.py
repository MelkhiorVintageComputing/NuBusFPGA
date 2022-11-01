from migen import *
from migen.genlib.fifo import *

import litex

class NuBus(Module):
    def __init__(self, platform, cd_nubus="nubus", cd_nubus90="nubus90"):
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
        self.cpu_valid = Signal(reset = 0)
        self.cpu_addr = Signal(32)
        self.cpu_wdata = Signal(32)
        self.cpu_ready = Signal()
        self.cpu_write = Signal(4)
        self.cpu_rdata = Signal(32)
        self.cpu_lock = Signal()
        self.cpu_eclr = Signal()
        self.cpu_errors = Signal(4)

        # utilities (unused)
        self.mem_stdslot = Signal()
        self.mem_super = Signal()
        self.mem_local = Signal()

        self.add_sources(platform)

        #arbcy_n = platform.request("arbcy_n")
        #grant = platform.request("grant")
        #pad_user_led_0 = platform.request("user_led", 0)
        #pad_user_led_1 = platform.request("user_led", 1)
        #arbcy_n_mem = Signal()
        #grant_mem = Signal()
        #self.sync.nubus += [ arbcy_n_mem.eq(~arbcy_n | arbcy_n_mem) ]
        #self.sync.nubus += [ grant_mem.eq(grant | grant_mem) ]
        #self.comb += pad_user_led_0.eq(arbcy_n_mem)
        #self.comb += pad_user_led_1.eq(grant_mem)

        # FPGA<->CPLD only, now internal signal
        nubus_master_dir = Signal()
        rqst_oe_n = Signal()
        arbcy_n = Signal()
        grant = Signal()
        tmoen = Signal()
        
        # those are needed in both Nubus and cpld integrated part now
        broadcast_id_3v3_n = plaform.request("id_3v3_n")
        # those are 'return' signals (O part of IO separated in I and O)
        # the 3v3 signals 'see' the 5V signals from the external drivers
        internal_start_3v3_n = Signal()
        internal_tm0_3v3_n = Signal()
        internal_tm1_3v3_n = Signal()
        internal_tm2_3v3_n = Signal()
        internal_ack_3v3_n = Signal()
        internal_rqst_3v3_n = Signal()
        
        self.specials += Instance(self.get_netlist_name(),
                                  # master side
                                  #p_SIMPLE_MAP = 0x0,
                                  p_SLOTS_ADDRESS = 0xf,
                                  p_SUPERSLOTS_ADDRESS = 0x9,
                                  p_WDT_W = 0x8,
                                  p_LOCAL_SPACE_EXPOSED_TO_NUBUS = 0,
                                  i_nub_clkn = ClockSignal(cd_nubus),
                                  i_nub_resetn = ~ResetSignal(cd_nubus),
                                  i_nub_idn = broadcast_id_3v3_n, # internal now
                                  # io_nub_pfwn = self.nubus_pwf_n,
                                  io_nub_adn = platform.request("ad_3v3_n"),
                                  i_nub_tm0n = platform.request("tm0_3v3_n"),
                                  i_nub_tm1n = platform.request("tm1_3v3_n"),
                                  i_nub_startn = platform.request("start_3v3_n"),
                                  i_nub_rqstn = platform.request("rqst_3v3_n"),
                                  i_nub_ackn = platform.request("ack_3v3_n"),
                                  o_nub_tm0n = internal_tm0_3v3_n,
                                  o_nub_tm1n = internal_tm1_3v3_n,
                                  o_nub_startn = internal_start_3v3_n,
                                  o_nub_rqstn = internal_rqst_3v3_n,
                                  o_nub_ackn = internal_ack_3v3_n,
                                  # io_nub_arbn = platform.request("nubus_arb_n"),
                                  o_arbcy_n = arbcy_n, # internal now
                                  i_grant = grant, # internal now
                                  o_tmoen = tmoen, # internal now
                                  o_NUBUS_AD_DIR = platform.request("nubus_ad_dir"),
                                  o_nubus_master_dir = nubus_master_dir, # internal now
                                  # io_nub_nmrqn = platform.request("nmrq_3v3_n"),
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
                                  i_cpu_valid = self.cpu_valid,
                                  i_cpu_addr = self.cpu_addr,
                                  i_cpu_wdata = self.cpu_wdata,
                                  o_cpu_ready = self.cpu_ready,
                                  i_cpu_write = self.cpu_write,
                                  o_cpu_rdata = self.cpu_rdata,
                                  i_cpu_lock = self.cpu_lock,
                                  i_cpu_eclr = self.cpu_eclr,
                                  o_cpu_errors = self.cpu_errors,
                                  o_mem_stdslot = self.mem_stdslot,
                                  o_mem_super = self.mem_super,
                                  o_mem_local = self.mem_local,

                                  o_fpga_to_cpld_signal = rqst_oe_n, # internal now

                                  i_nub_clk2xn = ClockSignal(cd_nubus90),
                                  i_nub_tm2n = platform.request("tm2_3v3_n"),
                                  o_nub_tm2n = internal_tm2_3v3_n,
        )
        self.specials += Instance("nubus_cpldinfpga",
                                  i_nubus_oe = nubus_oe, # FIXME: handled in soc
                                  i_tmoen = tmoen,
                                  i_nubus_master_dir = nubus_master_dir,
                                  i_rqst_oe_n = rqst_oe_n,
                            
                                  i_id_n_3v3 = broadcast_id_3v3_n, # input only
                        
                                  i_arbcy_n = arbcy_n,
                                  i_arb_n_3v3 = platform.request("arb_3v3_n"), # arb only seen by cpld
                                  o_arb_o_n = platform.request("arb_o_n"),
                                  o_grant = grant,
                            
                                  i_tm0_n_3v3 = internal_tm0_3v3_n, # tm0 driving controlled by tmoen
                                  o_tm0_o_n = platform.request("tm_o_n"),
                            
                                  i_tm1_n_3v3 = internal_tm1_3v3_n, # tm1 driving controlled by tmoen
                                  o_tm1_o_n = platform_request("tm1_o_n"),
                                  o_tmx_oe_n = platform_request("tmx_oe_n"),
                            
                                  i_tm2_n_3v3 = internal_tm2_3v3_n, # tm2 currently never driven
                                  o_tm2_o_n = platform_request("tm2_o_n"),
                                  o_tm2_oe_n = platform_request("tm2_oe_n"),
   
                                  i_start_n_3v3 = internal_start_3v3_n, # start driving enabled by nubus_master_dir
                                  o_start_o_n = platform_request("start_o_n"),
                                  o_start_oe_n = platform_request("start_oe_n"),
                                  
                                  i_ack_n_3v3 = internal_ack_3v3_n, # ack driving controlled by tmoen
                                  o_ack_o_n = platform_request("ack_o_n"),
                                  o_ack_oe_n = platform_request("ack_oe_n"),
                                  
                                  i_rqst_n_3v3 = internal_rqst_3v3_n, # rqst driving ocntroller by rqst_oe_n
                                  o_rqst_o_n = platform_request("rqst_o_n")
    )

                
    def get_netlist_name(self):
        return "nubus"

    def add_sources(self, platform):
        platform.add_source("nubus.v", "verilog")
        # XiBus is from my github, branch 'more_fixes'
        platform.add_source("XiBus/nubus.svh", "verilog")
        #platform.add_source("XiBus/nubus_arbiter.v", "verilog") # in the CPLDinfpga
        platform.add_source("XiBus/nubus_cpubus.v", "verilog")
        platform.add_source("XiBus/nubus_driver.v", "verilog")
        #platform.add_source("XiBus/nubus_errors.v", "verilog") # unused
        platform.add_source("XiBus/nubus_membus.v", "verilog")
        platform.add_source("XiBus/nubus_master.v", "verilog")
        platform.add_source("XiBus/nubus_slave.v", "verilog")
        platform.add_source("nubus_cpldinfpga.v", "verilog") # internal now
