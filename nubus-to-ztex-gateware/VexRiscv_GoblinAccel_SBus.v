// Generator : SpinalHDL v1.7.0a    git head : 150a9b9067020722818dfb17df4a23ac712a7af8
// Component : VexRiscv
// Git hash  : 8c9efb1630fc025ce4b59bd93d0e7a86da506073

`timescale 1ns/1ps

module VexRiscv (
  output reg          iBusWishbone_CYC,
  output reg          iBusWishbone_STB,
  input               iBusWishbone_ACK,
  output              iBusWishbone_WE,
  output     [29:0]   iBusWishbone_ADR,
  input      [31:0]   iBusWishbone_DAT_MISO,
  output     [31:0]   iBusWishbone_DAT_MOSI,
  output     [3:0]    iBusWishbone_SEL,
  input               iBusWishbone_ERR,
  output     [2:0]    iBusWishbone_CTI,
  output     [1:0]    iBusWishbone_BTE,
  output              dBusWishbone_CYC,
  output              dBusWishbone_STB,
  input               dBusWishbone_ACK,
  output              dBusWishbone_WE,
  output     [27:0]   dBusWishbone_ADR,
  input      [127:0]  dBusWishbone_DAT_MISO,
  output     [127:0]  dBusWishbone_DAT_MOSI,
  output     [15:0]   dBusWishbone_SEL,
  input               dBusWishbone_ERR,
  output     [2:0]    dBusWishbone_CTI,
  output     [1:0]    dBusWishbone_BTE,
  input               clk,
  input               reset
);
  localparam ShiftCtrlEnum_DISABLE_1 = 2'd0;
  localparam ShiftCtrlEnum_SLL_1 = 2'd1;
  localparam ShiftCtrlEnum_SRL_1 = 2'd2;
  localparam ShiftCtrlEnum_SRA_1 = 2'd3;
  localparam BranchCtrlEnum_INC = 2'd0;
  localparam BranchCtrlEnum_B = 2'd1;
  localparam BranchCtrlEnum_JAL = 2'd2;
  localparam BranchCtrlEnum_JALR = 2'd3;
  localparam GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 = 1'd0;
  localparam GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 = 1'd1;
  localparam CG6CtrlternaryEnum_CTRL_CMIX = 2'd0;
  localparam CG6CtrlternaryEnum_CTRL_CMOV = 2'd1;
  localparam CG6CtrlternaryEnum_CTRL_FSR = 2'd2;
  localparam CG6CtrlsignextendEnum_CTRL_SEXTdotB = 1'd0;
  localparam CG6CtrlsignextendEnum_CTRL_ZEXTdotH = 1'd1;
  localparam CG6CtrlminmaxEnum_CTRL_MAXU = 1'd0;
  localparam CG6CtrlminmaxEnum_CTRL_MINU = 1'd1;
  localparam CG6CtrlEnum_CTRL_SH2ADD = 3'd0;
  localparam CG6CtrlEnum_CTRL_minmax = 3'd1;
  localparam CG6CtrlEnum_CTRL_signextend = 3'd2;
  localparam CG6CtrlEnum_CTRL_ternary = 3'd3;
  localparam CG6CtrlEnum_CTRL_REV8 = 3'd4;
  localparam AluBitwiseCtrlEnum_XOR_1 = 2'd0;
  localparam AluBitwiseCtrlEnum_OR_1 = 2'd1;
  localparam AluBitwiseCtrlEnum_AND_1 = 2'd2;
  localparam Src3CtrlEnum_RS = 1'd0;
  localparam Src3CtrlEnum_IMI = 1'd1;
  localparam Src2CtrlEnum_RS = 2'd0;
  localparam Src2CtrlEnum_IMI = 2'd1;
  localparam Src2CtrlEnum_IMS = 2'd2;
  localparam Src2CtrlEnum_PC = 2'd3;
  localparam AluCtrlEnum_ADD_SUB = 2'd0;
  localparam AluCtrlEnum_SLT_SLTU = 2'd1;
  localparam AluCtrlEnum_BITWISE = 2'd2;
  localparam Src1CtrlEnum_RS = 2'd0;
  localparam Src1CtrlEnum_IMU = 2'd1;
  localparam Src1CtrlEnum_PC_INCREMENT = 2'd2;
  localparam Src1CtrlEnum_URS1 = 2'd3;

  wire                IBusCachedPlugin_cache_io_flush;
  wire                IBusCachedPlugin_cache_io_cpu_prefetch_isValid;
  wire                IBusCachedPlugin_cache_io_cpu_fetch_isValid;
  wire                IBusCachedPlugin_cache_io_cpu_fetch_isStuck;
  wire                IBusCachedPlugin_cache_io_cpu_fetch_isRemoved;
  wire                IBusCachedPlugin_cache_io_cpu_decode_isValid;
  wire                IBusCachedPlugin_cache_io_cpu_decode_isStuck;
  reg                 IBusCachedPlugin_cache_io_cpu_fill_valid;
  wire                dataCache_1_io_cpu_execute_isValid;
  wire       [31:0]   dataCache_1_io_cpu_execute_address;
  wire       [2:0]    dataCache_1_io_cpu_execute_args_size;
  wire                dataCache_1_io_cpu_memory_isValid;
  wire       [31:0]   dataCache_1_io_cpu_memory_address;
  reg                 dataCache_1_io_cpu_memory_mmuRsp_isIoAccess;
  reg                 dataCache_1_io_cpu_writeBack_isValid;
  reg        [127:0]  dataCache_1_io_cpu_writeBack_storeData;
  wire       [31:0]   dataCache_1_io_cpu_writeBack_address;
  wire                dataCache_1_io_cpu_writeBack_fence_SW;
  wire                dataCache_1_io_cpu_writeBack_fence_SR;
  wire                dataCache_1_io_cpu_writeBack_fence_SO;
  wire                dataCache_1_io_cpu_writeBack_fence_SI;
  wire                dataCache_1_io_cpu_writeBack_fence_PW;
  wire                dataCache_1_io_cpu_writeBack_fence_PR;
  wire                dataCache_1_io_cpu_writeBack_fence_PO;
  wire                dataCache_1_io_cpu_writeBack_fence_PI;
  wire       [3:0]    dataCache_1_io_cpu_writeBack_fence_FM;
  wire                dataCache_1_io_cpu_flush_valid;
  wire                dataCache_1_io_mem_cmd_ready;
  wire       [31:0]   _zz_RegFileOddEvenPlugin_regFileEven_port0;
  wire       [31:0]   _zz_RegFileOddEvenPlugin_regFileEven_port1;
  wire       [31:0]   _zz_RegFileOddEvenPlugin_regFileEven_port2;
  wire       [31:0]   _zz_RegFileOddEvenPlugin_regFileOdd_port0;
  wire       [31:0]   _zz_RegFileOddEvenPlugin_regFileOdd_port1;
  wire       [31:0]   _zz_RegFileOddEvenPlugin_regFileOdd_port2;
  wire                IBusCachedPlugin_cache_io_cpu_prefetch_haltIt;
  wire       [31:0]   IBusCachedPlugin_cache_io_cpu_fetch_data;
  wire       [31:0]   IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress;
  wire                IBusCachedPlugin_cache_io_cpu_decode_error;
  wire                IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling;
  wire                IBusCachedPlugin_cache_io_cpu_decode_mmuException;
  wire       [31:0]   IBusCachedPlugin_cache_io_cpu_decode_data;
  wire                IBusCachedPlugin_cache_io_cpu_decode_cacheMiss;
  wire       [31:0]   IBusCachedPlugin_cache_io_cpu_decode_physicalAddress;
  wire                IBusCachedPlugin_cache_io_mem_cmd_valid;
  wire       [31:0]   IBusCachedPlugin_cache_io_mem_cmd_payload_address;
  wire       [2:0]    IBusCachedPlugin_cache_io_mem_cmd_payload_size;
  wire                dataCache_1_io_cpu_execute_haltIt;
  wire                dataCache_1_io_cpu_execute_refilling;
  wire                dataCache_1_io_cpu_memory_isWrite;
  wire                dataCache_1_io_cpu_writeBack_haltIt;
  wire       [127:0]  dataCache_1_io_cpu_writeBack_data;
  wire                dataCache_1_io_cpu_writeBack_mmuException;
  wire                dataCache_1_io_cpu_writeBack_unalignedAccess;
  wire                dataCache_1_io_cpu_writeBack_accessError;
  wire                dataCache_1_io_cpu_writeBack_isWrite;
  wire                dataCache_1_io_cpu_writeBack_keepMemRspData;
  wire                dataCache_1_io_cpu_writeBack_exclusiveOk;
  wire                dataCache_1_io_cpu_flush_ready;
  wire                dataCache_1_io_cpu_redo;
  wire                dataCache_1_io_mem_cmd_valid;
  wire                dataCache_1_io_mem_cmd_payload_wr;
  wire                dataCache_1_io_mem_cmd_payload_uncached;
  wire       [31:0]   dataCache_1_io_mem_cmd_payload_address;
  wire       [127:0]  dataCache_1_io_mem_cmd_payload_data;
  wire       [15:0]   dataCache_1_io_mem_cmd_payload_mask;
  wire       [2:0]    dataCache_1_io_mem_cmd_payload_size;
  wire                dataCache_1_io_mem_cmd_payload_last;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_9;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_10;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_11;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_12;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_13;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_14;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_15;
  wire       [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_16;
  wire       [51:0]   _zz_memory_MUL_LOW;
  wire       [51:0]   _zz_memory_MUL_LOW_1;
  wire       [51:0]   _zz_memory_MUL_LOW_2;
  wire       [51:0]   _zz_memory_MUL_LOW_3;
  wire       [32:0]   _zz_memory_MUL_LOW_4;
  wire       [51:0]   _zz_memory_MUL_LOW_5;
  wire       [49:0]   _zz_memory_MUL_LOW_6;
  wire       [51:0]   _zz_memory_MUL_LOW_7;
  wire       [49:0]   _zz_memory_MUL_LOW_8;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_1;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_2;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_3;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_4;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_5;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_6;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_7;
  wire       [15:0]   _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_8;
  wire       [31:0]   _zz_execute_SHIFT_RIGHT;
  wire       [32:0]   _zz_execute_SHIFT_RIGHT_1;
  wire       [32:0]   _zz_execute_SHIFT_RIGHT_2;
  wire       [2:0]    _zz__zz_IBusCachedPlugin_jump_pcLoad_payload_1;
  reg        [31:0]   _zz_IBusCachedPlugin_jump_pcLoad_payload_4;
  wire       [1:0]    _zz_IBusCachedPlugin_jump_pcLoad_payload_5;
  wire       [31:0]   _zz_IBusCachedPlugin_fetchPc_pc;
  wire       [2:0]    _zz_IBusCachedPlugin_fetchPc_pc_1;
  wire       [11:0]   _zz__zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  wire       [31:0]   _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_2;
  wire       [19:0]   _zz__zz_3;
  wire       [11:0]   _zz__zz_5;
  wire       [31:0]   _zz__zz_7;
  wire       [31:0]   _zz__zz_7_1;
  wire       [19:0]   _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload;
  wire       [11:0]   _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
  wire                _zz_IBusCachedPlugin_predictionJumpInterface_payload_4;
  wire                _zz_IBusCachedPlugin_predictionJumpInterface_payload_5;
  wire                _zz_IBusCachedPlugin_predictionJumpInterface_payload_6;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted;
  wire       [3:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_1;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_2;
  wire       [2:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_3;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_4;
  wire       [1:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_5;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_6;
  wire       [1:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_7;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_8;
  wire       [0:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_9;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_10;
  wire       [0:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_11;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_12;
  wire       [0:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_13;
  reg        [7:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_14;
  wire       [0:0]    _zz_writeBack_DBusCachedPlugin_rspShifted_15;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_1;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_2;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_3;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_4;
  wire                _zz__zz_decode_IS_Goblin2c_5;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_6;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_7;
  wire       [33:0]   _zz__zz_decode_IS_Goblin2c_8;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_9;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_10;
  wire                _zz__zz_decode_IS_Goblin2c_11;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_12;
  wire                _zz__zz_decode_IS_Goblin2c_13;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_14;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_15;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_16;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_17;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_18;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_19;
  wire       [28:0]   _zz__zz_decode_IS_Goblin2c_20;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_21;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_22;
  wire       [3:0]    _zz__zz_decode_IS_Goblin2c_23;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_24;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_25;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_26;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_27;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_28;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_29;
  wire                _zz__zz_decode_IS_Goblin2c_30;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_31;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_32;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_33;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_34;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_35;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_36;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_37;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_38;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_39;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_40;
  wire       [24:0]   _zz__zz_decode_IS_Goblin2c_41;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_42;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_43;
  wire                _zz__zz_decode_IS_Goblin2c_44;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_45;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_46;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_47;
  wire                _zz__zz_decode_IS_Goblin2c_48;
  wire       [21:0]   _zz__zz_decode_IS_Goblin2c_49;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_50;
  wire                _zz__zz_decode_IS_Goblin2c_51;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_52;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_53;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_54;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_55;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_56;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_57;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_58;
  wire       [18:0]   _zz__zz_decode_IS_Goblin2c_59;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_60;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_61;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_62;
  wire                _zz__zz_decode_IS_Goblin2c_63;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_64;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_65;
  wire                _zz__zz_decode_IS_Goblin2c_66;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_67;
  wire       [3:0]    _zz__zz_decode_IS_Goblin2c_68;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_69;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_70;
  wire                _zz__zz_decode_IS_Goblin2c_71;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_72;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_73;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_74;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_75;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_76;
  wire       [14:0]   _zz__zz_decode_IS_Goblin2c_77;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_78;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_79;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_80;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_81;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_82;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_83;
  wire                _zz__zz_decode_IS_Goblin2c_84;
  wire                _zz__zz_decode_IS_Goblin2c_85;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_86;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_87;
  wire       [2:0]    _zz__zz_decode_IS_Goblin2c_88;
  wire                _zz__zz_decode_IS_Goblin2c_89;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_90;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_91;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_92;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_93;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_94;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_95;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_96;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_97;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_98;
  wire       [3:0]    _zz__zz_decode_IS_Goblin2c_99;
  wire                _zz__zz_decode_IS_Goblin2c_100;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_101;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_102;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_103;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_104;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_105;
  wire                _zz__zz_decode_IS_Goblin2c_106;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_107;
  wire                _zz__zz_decode_IS_Goblin2c_108;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_109;
  wire       [10:0]   _zz__zz_decode_IS_Goblin2c_110;
  wire       [3:0]    _zz__zz_decode_IS_Goblin2c_111;
  wire                _zz__zz_decode_IS_Goblin2c_112;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_113;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_114;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_115;
  wire                _zz__zz_decode_IS_Goblin2c_116;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_117;
  wire                _zz__zz_decode_IS_Goblin2c_118;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_119;
  wire                _zz__zz_decode_IS_Goblin2c_120;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_121;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_122;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_123;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_124;
  wire                _zz__zz_decode_IS_Goblin2c_125;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_126;
  wire       [7:0]    _zz__zz_decode_IS_Goblin2c_127;
  wire                _zz__zz_decode_IS_Goblin2c_128;
  wire                _zz__zz_decode_IS_Goblin2c_129;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_130;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_131;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_132;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_133;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_134;
  wire       [5:0]    _zz__zz_decode_IS_Goblin2c_135;
  wire                _zz__zz_decode_IS_Goblin2c_136;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_137;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_138;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_139;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_140;
  wire       [3:0]    _zz__zz_decode_IS_Goblin2c_141;
  wire                _zz__zz_decode_IS_Goblin2c_142;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_143;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_144;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_145;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_146;
  wire       [0:0]    _zz__zz_decode_IS_Goblin2c_147;
  wire       [1:0]    _zz__zz_decode_IS_Goblin2c_148;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_149;
  wire       [31:0]   _zz__zz_decode_IS_Goblin2c_150;
  wire       [0:0]    _zz__zz_execute_REGFILE_WRITE_DATA;
  wire       [2:0]    _zz__zz_execute_SRC1;
  wire       [4:0]    _zz__zz_execute_SRC1_1;
  wire       [11:0]   _zz__zz_execute_SRC2_3;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_1;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_2;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_3;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_4;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_5;
  wire       [31:0]   _zz_execute_SrcPlugin_addSub_6;
  wire       [65:0]   _zz_writeBack_MulPlugin_result;
  wire       [65:0]   _zz_writeBack_MulPlugin_result_1;
  wire       [31:0]   _zz__zz_decode_RS3_5;
  wire       [31:0]   _zz__zz_decode_RS3_5_1;
  wire       [31:0]   _zz__zz_execute_CG6Plugin_val_ternary_1;
  wire       [31:0]   _zz_execute_CG6Plugin_val_ternary_3;
  wire       [31:0]   _zz_execute_CG6Plugin_val_ternary_4;
  wire       [31:0]   _zz_execute_CG6Plugin_val_ternary_5;
  wire       [31:0]   _zz__zz_execute_CG6_FINAL_OUTPUT;
  wire       [31:0]   _zz__zz_execute_CG6_FINAL_OUTPUT_1;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_6;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_6_1;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_9;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_9_1;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_12;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_12_1;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_15;
  wire       [9:0]    _zz__zz_execute_GoblinPlugin_val_pdpikadd8_15_1;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_16;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_17;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_18;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_19;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_20;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_21;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_22;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_23;
  wire                _zz_execute_GoblinPlugin_val_pdpikadd8_24;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_25;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_26;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_27;
  wire                _zz_execute_GoblinPlugin_val_pdpikadd8_28;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_29;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_30;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_31;
  wire       [0:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_32;
  wire       [0:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_33;
  wire                _zz_execute_GoblinPlugin_val_pdpikadd8_34;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_35;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_36;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_37;
  wire       [0:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_38;
  wire       [0:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_39;
  wire       [0:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_40;
  wire       [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_41;
  wire       [19:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_2;
  wire       [11:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_4;
  wire       [31:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_6;
  wire       [31:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1;
  wire       [31:0]   _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2;
  wire       [19:0]   _zz__zz_execute_BranchPlugin_branch_src2_2;
  wire       [11:0]   _zz__zz_execute_BranchPlugin_branch_src2_4;
  wire                _zz_execute_BranchPlugin_branch_src2_6;
  wire                _zz_execute_BranchPlugin_branch_src2_7;
  wire                _zz_execute_BranchPlugin_branch_src2_8;
  wire       [2:0]    _zz_execute_BranchPlugin_branch_src2_9;
  wire       [27:0]   _zz_iBusWishbone_ADR_1;
  wire       [31:0]   memory_Goblin2c_FINAL_OUTPUT;
  wire       [51:0]   memory_MUL_LOW;
  wire       [31:0]   execute_BRANCH_CALC;
  wire                execute_BRANCH_DO;
  wire       [63:0]   execute_Goblin2c_INTERMEDIATE_UFMA8VxV64;
  wire       [31:0]   execute_Goblin_FINAL_OUTPUT;
  wire       [31:0]   execute_CG6_FINAL_OUTPUT;
  wire       [31:0]   execute_SHIFT_RIGHT;
  wire       [33:0]   memory_MUL_HH;
  wire       [33:0]   execute_MUL_HH;
  wire       [33:0]   execute_MUL_HL;
  wire       [33:0]   execute_MUL_LH;
  wire       [31:0]   execute_MUL_LL;
  wire       [31:0]   writeBack_REGFILE_WRITE_DATA_ODD;
  wire       [31:0]   memory_REGFILE_WRITE_DATA_ODD;
  wire       [31:0]   execute_REGFILE_WRITE_DATA_ODD;
  wire       [31:0]   execute_REGFILE_WRITE_DATA;
  wire       [63:0]   memory_MEMORY_STORE_DATA_RF;
  wire       [63:0]   execute_MEMORY_STORE_DATA_RF;
  wire                decode_PREDICTION_HAD_BRANCHED2;
  wire                decode_SRC2_FORCE_ZERO;
  wire       [1:0]    _zz_decode_to_execute_BRANCH_CTRL;
  wire       [1:0]    _zz_decode_to_execute_BRANCH_CTRL_1;
  wire                memory_IS_Goblin2c;
  wire                execute_IS_Goblin2c;
  wire                decode_IS_Goblin2c;
  wire       [0:0]    decode_GoblinCtrlpdpikadd8;
  wire       [0:0]    _zz_decode_GoblinCtrlpdpikadd8;
  wire       [0:0]    _zz_decode_to_execute_GoblinCtrlpdpikadd8;
  wire       [0:0]    _zz_decode_to_execute_GoblinCtrlpdpikadd8_1;
  wire                execute_IS_Goblin;
  wire                decode_IS_Goblin;
  wire       [1:0]    decode_CG6Ctrlternary;
  wire       [1:0]    _zz_decode_CG6Ctrlternary;
  wire       [1:0]    _zz_decode_to_execute_CG6Ctrlternary;
  wire       [1:0]    _zz_decode_to_execute_CG6Ctrlternary_1;
  wire       [0:0]    decode_CG6Ctrlsignextend;
  wire       [0:0]    _zz_decode_CG6Ctrlsignextend;
  wire       [0:0]    _zz_decode_to_execute_CG6Ctrlsignextend;
  wire       [0:0]    _zz_decode_to_execute_CG6Ctrlsignextend_1;
  wire       [0:0]    decode_CG6Ctrlminmax;
  wire       [0:0]    _zz_decode_CG6Ctrlminmax;
  wire       [0:0]    _zz_decode_to_execute_CG6Ctrlminmax;
  wire       [0:0]    _zz_decode_to_execute_CG6Ctrlminmax_1;
  wire       [2:0]    decode_CG6Ctrl;
  wire       [2:0]    _zz_decode_CG6Ctrl;
  wire       [2:0]    _zz_decode_to_execute_CG6Ctrl;
  wire       [2:0]    _zz_decode_to_execute_CG6Ctrl_1;
  wire                execute_IS_CG6;
  wire                decode_IS_CG6;
  wire       [1:0]    _zz_execute_to_memory_SHIFT_CTRL;
  wire       [1:0]    _zz_execute_to_memory_SHIFT_CTRL_1;
  wire       [1:0]    decode_SHIFT_CTRL;
  wire       [1:0]    _zz_decode_SHIFT_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SHIFT_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SHIFT_CTRL_1;
  wire                memory_IS_MUL;
  wire                execute_IS_MUL;
  wire                decode_IS_MUL;
  wire       [1:0]    decode_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_decode_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
  wire                decode_SRC_LESS_UNSIGNED;
  wire                decode_MEMORY_MANAGMENT;
  wire       [0:0]    decode_SRC3_CTRL;
  wire       [0:0]    _zz_decode_SRC3_CTRL;
  wire       [0:0]    _zz_decode_to_execute_SRC3_CTRL;
  wire       [0:0]    _zz_decode_to_execute_SRC3_CTRL_1;
  wire                decode_MEMORY_WR;
  wire                execute_BYPASSABLE_MEMORY_STAGE;
  wire                decode_BYPASSABLE_MEMORY_STAGE;
  wire                decode_BYPASSABLE_EXECUTE_STAGE;
  wire       [1:0]    decode_SRC2_CTRL;
  wire       [1:0]    _zz_decode_SRC2_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC2_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC2_CTRL_1;
  wire       [1:0]    decode_ALU_CTRL;
  wire       [1:0]    _zz_decode_ALU_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_CTRL;
  wire       [1:0]    _zz_decode_to_execute_ALU_CTRL_1;
  wire       [1:0]    decode_SRC1_CTRL;
  wire       [1:0]    _zz_decode_SRC1_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC1_CTRL;
  wire       [1:0]    _zz_decode_to_execute_SRC1_CTRL_1;
  wire                decode_MEMORY_FORCE_CONSTISTENCY;
  wire       [31:0]   writeBack_FORMAL_PC_NEXT;
  wire       [31:0]   memory_FORMAL_PC_NEXT;
  wire       [31:0]   execute_FORMAL_PC_NEXT;
  wire       [31:0]   decode_FORMAL_PC_NEXT;
  wire       [31:0]   memory_PC;
  wire       [31:0]   memory_BRANCH_CALC;
  wire                memory_BRANCH_DO;
  wire       [31:0]   execute_PC;
  wire                execute_PREDICTION_HAD_BRANCHED2;
  wire                execute_BRANCH_COND_RESULT;
  wire       [1:0]    execute_BRANCH_CTRL;
  wire       [1:0]    _zz_execute_BRANCH_CTRL;
  wire                decode_RS3_USE;
  wire                decode_RS2_USE;
  wire                decode_RS1_USE;
  wire       [31:0]   _zz_decode_RS3;
  wire                execute_REGFILE_WRITE_VALID_ODD;
  wire       [31:0]   _zz_decode_RS3_1;
  wire                execute_REGFILE_WRITE_VALID;
  wire                execute_BYPASSABLE_EXECUTE_STAGE;
  wire       [31:0]   _zz_decode_RS3_2;
  wire                memory_REGFILE_WRITE_VALID_ODD;
  wire                memory_REGFILE_WRITE_VALID;
  wire                memory_BYPASSABLE_MEMORY_STAGE;
  wire       [31:0]   memory_INSTRUCTION;
  wire                writeBack_REGFILE_WRITE_VALID_ODD;
  wire                writeBack_REGFILE_WRITE_VALID;
  reg        [31:0]   decode_RS3;
  reg        [31:0]   decode_RS2;
  reg        [31:0]   decode_RS1;
  wire       [31:0]   writeBack_Goblin2c_FINAL_OUTPUT;
  wire                writeBack_IS_Goblin2c;
  wire       [63:0]   memory_Goblin2c_INTERMEDIATE_UFMA8VxV64;
  wire       [31:0]   memory_Goblin_FINAL_OUTPUT;
  wire                memory_IS_Goblin;
  wire       [0:0]    execute_GoblinCtrlpdpikadd8;
  wire       [0:0]    _zz_execute_GoblinCtrlpdpikadd8;
  wire       [31:0]   memory_CG6_FINAL_OUTPUT;
  wire                memory_IS_CG6;
  wire       [2:0]    execute_CG6Ctrl;
  wire       [2:0]    _zz_execute_CG6Ctrl;
  wire       [31:0]   execute_SRC3;
  wire       [1:0]    execute_CG6Ctrlternary;
  wire       [1:0]    _zz_execute_CG6Ctrlternary;
  wire       [0:0]    execute_CG6Ctrlsignextend;
  wire       [0:0]    _zz_execute_CG6Ctrlsignextend;
  wire       [0:0]    execute_CG6Ctrlminmax;
  wire       [0:0]    _zz_execute_CG6Ctrlminmax;
  wire       [31:0]   memory_SHIFT_RIGHT;
  reg        [31:0]   _zz_decode_RS3_3;
  wire       [1:0]    memory_SHIFT_CTRL;
  wire       [1:0]    _zz_memory_SHIFT_CTRL;
  wire       [1:0]    execute_SHIFT_CTRL;
  wire       [1:0]    _zz_execute_SHIFT_CTRL;
  wire                writeBack_IS_MUL;
  wire       [33:0]   writeBack_MUL_HH;
  wire       [51:0]   writeBack_MUL_LOW;
  wire       [33:0]   memory_MUL_HL;
  wire       [33:0]   memory_MUL_LH;
  wire       [31:0]   memory_MUL_LL;
  (* keep , syn_keep *) wire       [31:0]   execute_RS1 /* synthesis syn_keep = 1 */ ;
  wire                execute_SRC_LESS_UNSIGNED;
  wire                execute_SRC2_FORCE_ZERO;
  wire                execute_SRC_USE_SUB_LESS;
  wire       [0:0]    execute_SRC3_CTRL;
  wire       [0:0]    _zz_execute_SRC3_CTRL;
  wire       [31:0]   _zz_execute_SRC2;
  wire       [1:0]    execute_SRC2_CTRL;
  wire       [1:0]    _zz_execute_SRC2_CTRL;
  wire       [1:0]    execute_SRC1_CTRL;
  wire       [1:0]    _zz_execute_SRC1_CTRL;
  wire                decode_SRC_USE_SUB_LESS;
  wire                decode_SRC_ADD_ZERO;
  wire       [31:0]   execute_SRC_ADD_SUB;
  wire                execute_SRC_LESS;
  wire       [1:0]    execute_ALU_CTRL;
  wire       [1:0]    _zz_execute_ALU_CTRL;
  wire       [31:0]   execute_SRC2;
  wire       [31:0]   execute_SRC1;
  wire       [1:0]    execute_ALU_BITWISE_CTRL;
  wire       [1:0]    _zz_execute_ALU_BITWISE_CTRL;
  wire                _zz_lastStageRegFileWrite_valid;
  reg                 _zz_1;
  wire                _zz_lastStageRegFileWrite_valid_1;
  reg                 _zz_2;
  wire       [31:0]   _zz_writeBack_RegFileOddEvenPlugin_rdIndex;
  reg                 decode_REGFILE_WRITE_VALID_ODD;
  reg                 decode_REGFILE_WRITE_VALID;
  wire       [1:0]    _zz_decode_BRANCH_CTRL;
  wire       [0:0]    _zz_decode_GoblinCtrlpdpikadd8_1;
  wire       [1:0]    _zz_decode_CG6Ctrlternary_1;
  wire       [0:0]    _zz_decode_CG6Ctrlsignextend_1;
  wire       [0:0]    _zz_decode_CG6Ctrlminmax_1;
  wire       [2:0]    _zz_decode_CG6Ctrl_1;
  wire       [1:0]    _zz_decode_SHIFT_CTRL_1;
  wire       [1:0]    _zz_decode_ALU_BITWISE_CTRL_1;
  wire       [0:0]    _zz_decode_SRC3_CTRL_1;
  wire       [1:0]    _zz_decode_SRC2_CTRL_1;
  wire       [1:0]    _zz_decode_ALU_CTRL_1;
  wire       [1:0]    _zz_decode_SRC1_CTRL_1;
  reg        [31:0]   _zz_decode_RS3_4;
  reg        [31:0]   _zz_decode_RS3_5;
  wire       [63:0]   writeBack_MEMORY_STORE_DATA_RF;
  wire       [31:0]   writeBack_REGFILE_WRITE_DATA;
  wire                writeBack_MEMORY_ENABLE;
  wire       [31:0]   memory_REGFILE_WRITE_DATA;
  wire                memory_MEMORY_ENABLE;
  wire                execute_MEMORY_FORCE_CONSTISTENCY;
  wire                execute_MEMORY_MANAGMENT;
  wire       [31:0]   execute_RS3;
  (* keep , syn_keep *) wire       [31:0]   execute_RS2 /* synthesis syn_keep = 1 */ ;
  wire                execute_MEMORY_WR;
  wire       [31:0]   execute_SRC_ADD;
  wire                execute_MEMORY_ENABLE;
  wire       [31:0]   execute_INSTRUCTION;
  wire                decode_MEMORY_ENABLE;
  wire                decode_FLUSH_ALL;
  reg                 IBusCachedPlugin_rsp_issueDetected_2;
  reg                 IBusCachedPlugin_rsp_issueDetected_1;
  wire       [1:0]    decode_BRANCH_CTRL;
  wire       [1:0]    _zz_decode_BRANCH_CTRL_1;
  wire       [31:0]   decode_INSTRUCTION;
  reg        [31:0]   _zz_memory_to_writeBack_FORMAL_PC_NEXT;
  reg        [31:0]   _zz_decode_to_execute_FORMAL_PC_NEXT;
  wire       [31:0]   decode_PC;
  wire       [31:0]   writeBack_PC;
  wire       [31:0]   writeBack_INSTRUCTION;
  reg                 decode_arbitration_haltItself;
  reg                 decode_arbitration_haltByOther;
  reg                 decode_arbitration_removeIt;
  wire                decode_arbitration_flushIt;
  reg                 decode_arbitration_flushNext;
  reg                 decode_arbitration_isValid;
  wire                decode_arbitration_isStuck;
  wire                decode_arbitration_isStuckByOthers;
  wire                decode_arbitration_isFlushed;
  wire                decode_arbitration_isMoving;
  wire                decode_arbitration_isFiring;
  reg                 execute_arbitration_haltItself;
  reg                 execute_arbitration_haltByOther;
  reg                 execute_arbitration_removeIt;
  wire                execute_arbitration_flushIt;
  wire                execute_arbitration_flushNext;
  reg                 execute_arbitration_isValid;
  wire                execute_arbitration_isStuck;
  wire                execute_arbitration_isStuckByOthers;
  wire                execute_arbitration_isFlushed;
  wire                execute_arbitration_isMoving;
  wire                execute_arbitration_isFiring;
  wire                memory_arbitration_haltItself;
  wire                memory_arbitration_haltByOther;
  reg                 memory_arbitration_removeIt;
  wire                memory_arbitration_flushIt;
  reg                 memory_arbitration_flushNext;
  reg                 memory_arbitration_isValid;
  wire                memory_arbitration_isStuck;
  wire                memory_arbitration_isStuckByOthers;
  wire                memory_arbitration_isFlushed;
  wire                memory_arbitration_isMoving;
  wire                memory_arbitration_isFiring;
  reg                 writeBack_arbitration_haltItself;
  wire                writeBack_arbitration_haltByOther;
  reg                 writeBack_arbitration_removeIt;
  reg                 writeBack_arbitration_flushIt;
  reg                 writeBack_arbitration_flushNext;
  reg                 writeBack_arbitration_isValid;
  wire                writeBack_arbitration_isStuck;
  wire                writeBack_arbitration_isStuckByOthers;
  wire                writeBack_arbitration_isFlushed;
  wire                writeBack_arbitration_isMoving;
  wire                writeBack_arbitration_isFiring;
  wire       [31:0]   lastStageInstruction /* verilator public */ ;
  wire       [31:0]   lastStagePc /* verilator public */ ;
  wire                lastStageIsValid /* verilator public */ ;
  wire                lastStageIsFiring /* verilator public */ ;
  wire                IBusCachedPlugin_fetcherHalt;
  wire                IBusCachedPlugin_forceNoDecodeCond;
  reg                 IBusCachedPlugin_incomingInstruction;
  wire                IBusCachedPlugin_predictionJumpInterface_valid;
  (* keep , syn_keep *) wire       [31:0]   IBusCachedPlugin_predictionJumpInterface_payload /* synthesis syn_keep = 1 */ ;
  reg                 IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  wire                IBusCachedPlugin_decodePrediction_rsp_wasWrong;
  wire                IBusCachedPlugin_pcValids_0;
  wire                IBusCachedPlugin_pcValids_1;
  wire                IBusCachedPlugin_pcValids_2;
  wire                IBusCachedPlugin_pcValids_3;
  wire                IBusCachedPlugin_mmuBus_cmd_0_isValid;
  wire                IBusCachedPlugin_mmuBus_cmd_0_isStuck;
  wire       [31:0]   IBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
  wire                IBusCachedPlugin_mmuBus_cmd_0_bypassTranslation;
  wire       [31:0]   IBusCachedPlugin_mmuBus_rsp_physicalAddress;
  wire                IBusCachedPlugin_mmuBus_rsp_isIoAccess;
  wire                IBusCachedPlugin_mmuBus_rsp_isPaging;
  wire                IBusCachedPlugin_mmuBus_rsp_allowRead;
  wire                IBusCachedPlugin_mmuBus_rsp_allowWrite;
  wire                IBusCachedPlugin_mmuBus_rsp_allowExecute;
  wire                IBusCachedPlugin_mmuBus_rsp_exception;
  wire                IBusCachedPlugin_mmuBus_rsp_refilling;
  wire                IBusCachedPlugin_mmuBus_rsp_bypassTranslation;
  wire                IBusCachedPlugin_mmuBus_end;
  wire                IBusCachedPlugin_mmuBus_busy;
  wire                dBus_cmd_valid;
  wire                dBus_cmd_ready;
  wire                dBus_cmd_payload_wr;
  wire                dBus_cmd_payload_uncached;
  wire       [31:0]   dBus_cmd_payload_address;
  wire       [127:0]  dBus_cmd_payload_data;
  wire       [15:0]   dBus_cmd_payload_mask;
  wire       [2:0]    dBus_cmd_payload_size;
  wire                dBus_cmd_payload_last;
  wire                dBus_rsp_valid;
  wire       [4:0]    dBus_rsp_payload_aggregated;
  wire                dBus_rsp_payload_last;
  wire       [127:0]  dBus_rsp_payload_data;
  wire                dBus_rsp_payload_error;
  wire                DBusCachedPlugin_mmuBus_cmd_0_isValid;
  wire                DBusCachedPlugin_mmuBus_cmd_0_isStuck;
  wire       [31:0]   DBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
  wire                DBusCachedPlugin_mmuBus_cmd_0_bypassTranslation;
  wire       [31:0]   DBusCachedPlugin_mmuBus_rsp_physicalAddress;
  wire                DBusCachedPlugin_mmuBus_rsp_isIoAccess;
  wire                DBusCachedPlugin_mmuBus_rsp_isPaging;
  wire                DBusCachedPlugin_mmuBus_rsp_allowRead;
  wire                DBusCachedPlugin_mmuBus_rsp_allowWrite;
  wire                DBusCachedPlugin_mmuBus_rsp_allowExecute;
  wire                DBusCachedPlugin_mmuBus_rsp_exception;
  wire                DBusCachedPlugin_mmuBus_rsp_refilling;
  wire                DBusCachedPlugin_mmuBus_rsp_bypassTranslation;
  wire                DBusCachedPlugin_mmuBus_end;
  wire                DBusCachedPlugin_mmuBus_busy;
  reg                 DBusCachedPlugin_redoBranch_valid;
  wire       [31:0]   DBusCachedPlugin_redoBranch_payload;
  wire                BranchPlugin_jumpInterface_valid;
  wire       [31:0]   BranchPlugin_jumpInterface_payload;
  wire                BranchPlugin_inDebugNoFetchFlag;
  wire                IBusCachedPlugin_externalFlush;
  wire                IBusCachedPlugin_jump_pcLoad_valid;
  wire       [31:0]   IBusCachedPlugin_jump_pcLoad_payload;
  wire       [2:0]    _zz_IBusCachedPlugin_jump_pcLoad_payload;
  wire       [2:0]    _zz_IBusCachedPlugin_jump_pcLoad_payload_1;
  wire                _zz_IBusCachedPlugin_jump_pcLoad_payload_2;
  wire                _zz_IBusCachedPlugin_jump_pcLoad_payload_3;
  wire                IBusCachedPlugin_fetchPc_output_valid;
  wire                IBusCachedPlugin_fetchPc_output_ready;
  wire       [31:0]   IBusCachedPlugin_fetchPc_output_payload;
  reg        [31:0]   IBusCachedPlugin_fetchPc_pcReg /* verilator public */ ;
  reg                 IBusCachedPlugin_fetchPc_correction;
  reg                 IBusCachedPlugin_fetchPc_correctionReg;
  wire                IBusCachedPlugin_fetchPc_output_fire;
  wire                IBusCachedPlugin_fetchPc_corrected;
  reg                 IBusCachedPlugin_fetchPc_pcRegPropagate;
  reg                 IBusCachedPlugin_fetchPc_booted;
  reg                 IBusCachedPlugin_fetchPc_inc;
  wire                when_Fetcher_l134;
  wire                IBusCachedPlugin_fetchPc_output_fire_1;
  wire                when_Fetcher_l134_1;
  reg        [31:0]   IBusCachedPlugin_fetchPc_pc;
  wire                IBusCachedPlugin_fetchPc_redo_valid;
  wire       [31:0]   IBusCachedPlugin_fetchPc_redo_payload;
  reg                 IBusCachedPlugin_fetchPc_flushed;
  wire                when_Fetcher_l161;
  reg                 IBusCachedPlugin_iBusRsp_redoFetch;
  wire                IBusCachedPlugin_iBusRsp_stages_0_input_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_0_input_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_0_input_payload;
  wire                IBusCachedPlugin_iBusRsp_stages_0_output_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_0_output_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_0_output_payload;
  reg                 IBusCachedPlugin_iBusRsp_stages_0_halt;
  wire                IBusCachedPlugin_iBusRsp_stages_1_input_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_1_input_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  wire                IBusCachedPlugin_iBusRsp_stages_1_output_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_1_output_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_1_output_payload;
  reg                 IBusCachedPlugin_iBusRsp_stages_1_halt;
  wire                IBusCachedPlugin_iBusRsp_stages_2_input_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_2_input_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_2_input_payload;
  wire                IBusCachedPlugin_iBusRsp_stages_2_output_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_2_output_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_2_output_payload;
  reg                 IBusCachedPlugin_iBusRsp_stages_2_halt;
  wire                _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready;
  wire                _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready;
  wire                _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready;
  wire                IBusCachedPlugin_iBusRsp_flush;
  wire                _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready;
  wire                _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_1;
  reg                 _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_2;
  wire                IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
  wire                IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
  reg                 _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
  reg        [31:0]   _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
  reg                 IBusCachedPlugin_iBusRsp_readyForError;
  wire                IBusCachedPlugin_iBusRsp_output_valid;
  wire                IBusCachedPlugin_iBusRsp_output_ready;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_output_payload_pc;
  wire                IBusCachedPlugin_iBusRsp_output_payload_rsp_error;
  wire       [31:0]   IBusCachedPlugin_iBusRsp_output_payload_rsp_inst;
  wire                IBusCachedPlugin_iBusRsp_output_payload_isRvc;
  wire                when_Fetcher_l243;
  wire                when_Fetcher_l323;
  reg                 IBusCachedPlugin_injector_nextPcCalc_valids_0;
  wire                when_Fetcher_l332;
  reg                 IBusCachedPlugin_injector_nextPcCalc_valids_1;
  wire                when_Fetcher_l332_1;
  reg                 IBusCachedPlugin_injector_nextPcCalc_valids_2;
  wire                when_Fetcher_l332_2;
  reg                 IBusCachedPlugin_injector_nextPcCalc_valids_3;
  wire                when_Fetcher_l332_3;
  reg                 IBusCachedPlugin_injector_nextPcCalc_valids_4;
  wire                when_Fetcher_l332_4;
  wire                _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  reg        [18:0]   _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1;
  wire                _zz_3;
  reg        [10:0]   _zz_4;
  wire                _zz_5;
  reg        [18:0]   _zz_6;
  reg                 _zz_7;
  wire                _zz_IBusCachedPlugin_predictionJumpInterface_payload;
  reg        [10:0]   _zz_IBusCachedPlugin_predictionJumpInterface_payload_1;
  wire                _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
  reg        [18:0]   _zz_IBusCachedPlugin_predictionJumpInterface_payload_3;
  wire                iBus_cmd_valid;
  wire                iBus_cmd_ready;
  reg        [31:0]   iBus_cmd_payload_address;
  wire       [2:0]    iBus_cmd_payload_size;
  wire                iBus_rsp_valid;
  wire       [31:0]   iBus_rsp_payload_data;
  wire                iBus_rsp_payload_error;
  reg        [31:0]   IBusCachedPlugin_rspCounter;
  wire                IBusCachedPlugin_s0_tightlyCoupledHit;
  reg                 IBusCachedPlugin_s1_tightlyCoupledHit;
  reg                 IBusCachedPlugin_s2_tightlyCoupledHit;
  wire                IBusCachedPlugin_rsp_iBusRspOutputHalt;
  wire                IBusCachedPlugin_rsp_issueDetected;
  reg                 IBusCachedPlugin_rsp_redoFetch;
  wire                when_IBusCachedPlugin_l239;
  wire                when_IBusCachedPlugin_l250;
  wire                when_IBusCachedPlugin_l267;
  wire                dataCache_1_io_mem_cmd_s2mPipe_valid;
  wire                dataCache_1_io_mem_cmd_s2mPipe_ready;
  wire                dataCache_1_io_mem_cmd_s2mPipe_payload_wr;
  wire                dataCache_1_io_mem_cmd_s2mPipe_payload_uncached;
  wire       [31:0]   dataCache_1_io_mem_cmd_s2mPipe_payload_address;
  wire       [127:0]  dataCache_1_io_mem_cmd_s2mPipe_payload_data;
  wire       [15:0]   dataCache_1_io_mem_cmd_s2mPipe_payload_mask;
  wire       [2:0]    dataCache_1_io_mem_cmd_s2mPipe_payload_size;
  wire                dataCache_1_io_mem_cmd_s2mPipe_payload_last;
  reg                 dataCache_1_io_mem_cmd_rValid;
  reg                 dataCache_1_io_mem_cmd_rData_wr;
  reg                 dataCache_1_io_mem_cmd_rData_uncached;
  reg        [31:0]   dataCache_1_io_mem_cmd_rData_address;
  reg        [127:0]  dataCache_1_io_mem_cmd_rData_data;
  reg        [15:0]   dataCache_1_io_mem_cmd_rData_mask;
  reg        [2:0]    dataCache_1_io_mem_cmd_rData_size;
  reg                 dataCache_1_io_mem_cmd_rData_last;
  reg                 dBus_rsp_regNext_valid;
  reg        [4:0]    dBus_rsp_regNext_payload_aggregated;
  reg                 dBus_rsp_regNext_payload_last;
  reg        [127:0]  dBus_rsp_regNext_payload_data;
  reg                 dBus_rsp_regNext_payload_error;
  reg        [31:0]   DBusCachedPlugin_rspCounter;
  wire                when_DBusCachedPlugin_l318;
  wire       [1:0]    execute_DBusCachedPlugin_size;
  reg        [63:0]   _zz_execute_MEMORY_STORE_DATA_RF;
  wire                dataCache_1_io_cpu_flush_isStall;
  wire                when_DBusCachedPlugin_l359;
  wire                when_DBusCachedPlugin_l375;
  wire                when_DBusCachedPlugin_l402;
  wire                when_DBusCachedPlugin_l455;
  wire                when_DBusCachedPlugin_l475;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_0;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_1;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_2;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_3;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_4;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_5;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_6;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_7;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_8;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_9;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_10;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_11;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_12;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_13;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_14;
  wire       [7:0]    writeBack_DBusCachedPlugin_rspSplits_15;
  reg        [127:0]  writeBack_DBusCachedPlugin_rspShifted;
  wire       [63:0]   writeBack_DBusCachedPlugin_rspRf;
  wire       [1:0]    switch_Misc_l211;
  wire                _zz_writeBack_DBusCachedPlugin_rspFormated;
  reg        [63:0]   _zz_writeBack_DBusCachedPlugin_rspFormated_1;
  wire                _zz_writeBack_DBusCachedPlugin_rspFormated_2;
  reg        [63:0]   _zz_writeBack_DBusCachedPlugin_rspFormated_3;
  reg        [63:0]   _zz_writeBack_DBusCachedPlugin_rspFormated_4;
  reg        [63:0]   writeBack_DBusCachedPlugin_rspFormated;
  wire                when_DBusCachedPlugin_l502;
  wire       [39:0]   _zz_decode_IS_Goblin2c;
  wire                _zz_decode_IS_Goblin2c_1;
  wire                _zz_decode_IS_Goblin2c_2;
  wire                _zz_decode_IS_Goblin2c_3;
  wire                _zz_decode_IS_Goblin2c_4;
  wire                _zz_decode_IS_Goblin2c_5;
  wire                _zz_decode_IS_Goblin2c_6;
  wire                _zz_decode_IS_Goblin2c_7;
  wire                _zz_decode_IS_Goblin2c_8;
  wire                _zz_decode_IS_Goblin2c_9;
  wire       [1:0]    _zz_decode_SRC1_CTRL_2;
  wire       [1:0]    _zz_decode_ALU_CTRL_2;
  wire       [1:0]    _zz_decode_SRC2_CTRL_2;
  wire       [0:0]    _zz_decode_SRC3_CTRL_2;
  wire       [1:0]    _zz_decode_ALU_BITWISE_CTRL_2;
  wire       [1:0]    _zz_decode_SHIFT_CTRL_2;
  wire       [2:0]    _zz_decode_CG6Ctrl_2;
  wire       [0:0]    _zz_decode_CG6Ctrlminmax_2;
  wire       [0:0]    _zz_decode_CG6Ctrlsignextend_2;
  wire       [1:0]    _zz_decode_CG6Ctrlternary_2;
  wire       [0:0]    _zz_decode_GoblinCtrlpdpikadd8_2;
  wire       [1:0]    _zz_decode_BRANCH_CTRL_2;
  wire                when_RegFileOddEvenPlugin_l69;
  wire       [4:0]    decode_RegFileOddEvenPlugin_regFileReadAddress1;
  wire       [4:0]    decode_RegFileOddEvenPlugin_regFileReadAddress2;
  wire       [4:0]    decode_RegFileOddEvenPlugin_regFileReadAddress3;
  wire       [4:0]    decode_RegFileOddEvenPlugin_rfra1o;
  wire       [4:0]    decode_RegFileOddEvenPlugin_rfra2o;
  wire       [4:0]    decode_RegFileOddEvenPlugin_rfra3o;
  wire       [3:0]    _zz_decode_RegFileOddEvenPlugin_rs1Data;
  wire       [3:0]    _zz_decode_RegFileOddEvenPlugin_rs1Data_1;
  wire       [31:0]   decode_RegFileOddEvenPlugin_rs1Data;
  wire       [3:0]    _zz_decode_RegFileOddEvenPlugin_rs2Data;
  wire       [3:0]    _zz_decode_RegFileOddEvenPlugin_rs2Data_1;
  wire       [31:0]   decode_RegFileOddEvenPlugin_rs2Data;
  wire       [3:0]    _zz_decode_RegFileOddEvenPlugin_rs3Data;
  wire       [3:0]    _zz_decode_RegFileOddEvenPlugin_rs3Data_1;
  wire       [31:0]   decode_RegFileOddEvenPlugin_rs3Data;
  wire       [4:0]    writeBack_RegFileOddEvenPlugin_rdIndex;
  reg                 lastStageRegFileWrite_valid /* verilator public */ ;
  reg        [3:0]    lastStageRegFileWrite_payload_address /* verilator public */ ;
  reg        [31:0]   lastStageRegFileWrite_payload_data /* verilator public */ ;
  wire                lastStageRegFileWrite_valid_1 /* verilator public */ ;
  wire       [3:0]    lastStageRegFileWrite_payload_address_1 /* verilator public */ ;
  wire       [31:0]   lastStageRegFileWrite_payload_data_1 /* verilator public */ ;
  reg                 _zz_8;
  reg        [31:0]   execute_IntAluPlugin_bitwise;
  reg        [31:0]   _zz_execute_REGFILE_WRITE_DATA;
  reg        [31:0]   _zz_execute_SRC1;
  wire                _zz_execute_SRC2_1;
  reg        [19:0]   _zz_execute_SRC2_2;
  wire                _zz_execute_SRC2_3;
  reg        [19:0]   _zz_execute_SRC2_4;
  reg        [31:0]   _zz_execute_SRC2_5;
  wire                _zz_execute_SRC3;
  reg        [19:0]   _zz_execute_SRC3_1;
  reg        [31:0]   _zz_execute_SRC3_2;
  reg        [31:0]   execute_SrcPlugin_addSub;
  wire                execute_SrcPlugin_less;
  reg                 execute_MulPlugin_aSigned;
  reg                 execute_MulPlugin_bSigned;
  wire       [31:0]   execute_MulPlugin_a;
  wire       [31:0]   execute_MulPlugin_b;
  wire       [1:0]    switch_MulPlugin_l87;
  wire       [15:0]   execute_MulPlugin_aULow;
  wire       [15:0]   execute_MulPlugin_bULow;
  wire       [16:0]   execute_MulPlugin_aSLow;
  wire       [16:0]   execute_MulPlugin_bSLow;
  wire       [16:0]   execute_MulPlugin_aHigh;
  wire       [16:0]   execute_MulPlugin_bHigh;
  wire       [65:0]   writeBack_MulPlugin_result;
  wire                when_MulPlugin_l147;
  wire       [1:0]    switch_MulPlugin_l148;
  wire       [4:0]    execute_FullBarrelShifterPlugin_amplitude;
  reg        [31:0]   _zz_execute_FullBarrelShifterPlugin_reversed;
  wire       [31:0]   execute_FullBarrelShifterPlugin_reversed;
  reg        [31:0]   _zz_decode_RS3_6;
  reg        [31:0]   execute_CG6Plugin_val_minmax;
  reg        [31:0]   execute_CG6Plugin_val_signextend;
  wire       [31:0]   _zz_execute_CG6Plugin_val_ternary;
  wire       [31:0]   _zz_execute_CG6Plugin_val_ternary_1;
  wire       [31:0]   _zz_execute_CG6Plugin_val_ternary_2;
  reg        [31:0]   execute_CG6Plugin_val_ternary;
  reg        [31:0]   _zz_execute_CG6_FINAL_OUTPUT;
  wire                when_CG6_l489;
  wire       [8:0]    _zz_when_UInt_l119;
  reg        [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8;
  wire                when_UInt_l119;
  wire       [8:0]    _zz_when_UInt_l119_1;
  reg        [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_1;
  wire                when_UInt_l119_1;
  wire       [8:0]    _zz_when_UInt_l119_2;
  reg        [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_2;
  wire                when_UInt_l119_2;
  wire       [8:0]    _zz_when_UInt_l119_3;
  reg        [7:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_3;
  wire                when_UInt_l119_3;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_4;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_5;
  wire       [9:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_6;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_7;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_8;
  wire       [9:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_9;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_10;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_11;
  wire       [9:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_12;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_13;
  wire       [8:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_14;
  wire       [9:0]    _zz_execute_GoblinPlugin_val_pdpikadd8_15;
  reg        [31:0]   execute_GoblinPlugin_val_pdpikadd8;
  wire                when_Goblin_l591;
  wire       [7:0]    _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64;
  wire       [31:0]   _zz_memory_Goblin2c_FINAL_OUTPUT;
  wire       [8:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_1;
  reg        [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_2;
  wire                when_UInt_l119_4;
  wire       [8:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_3;
  reg        [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_4;
  wire                when_UInt_l119_5;
  wire       [8:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_5;
  reg        [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_6;
  wire                when_UInt_l119_6;
  wire       [8:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_7;
  reg        [7:0]    _zz_memory_Goblin2c_FINAL_OUTPUT_8;
  wire                when_UInt_l119_7;
  wire                when_Goblin2c_l115;
  reg                 HazardSimplePlugin_src0Hazard;
  reg                 HazardSimplePlugin_src1Hazard;
  reg                 HazardSimplePlugin_src2Hazard;
  wire                HazardSimplePlugin_writeBackWrites_valid;
  wire       [4:0]    HazardSimplePlugin_writeBackWrites_payload_address;
  wire       [31:0]   HazardSimplePlugin_writeBackWrites_payload_data;
  wire                HazardSimplePlugin_notAES;
  wire       [4:0]    HazardSimplePlugin_rdIndex;
  wire       [4:0]    HazardSimplePlugin_regFileReadAddress3;
  reg                 HazardSimplePlugin_writeBackBuffer_valid;
  reg        [4:0]    HazardSimplePlugin_writeBackBuffer_payload_address;
  reg        [31:0]   HazardSimplePlugin_writeBackBuffer_payload_data;
  wire                HazardSimplePlugin_addr0Match;
  wire                HazardSimplePlugin_addr1Match;
  wire                HazardSimplePlugin_addr2Match;
  wire                _zz_when_HazardSimplePlugin_l79;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l64;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l79_1;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l70;
  wire                when_HazardSimplePlugin_l63;
  wire                when_HazardSimplePlugin_l64;
  wire                when_HazardSimplePlugin_l67;
  wire                when_HazardSimplePlugin_l70;
  wire                when_HazardSimplePlugin_l79;
  wire                when_HazardSimplePlugin_l82;
  wire                when_HazardSimplePlugin_l85;
  wire                when_HazardSimplePlugin_l61;
  wire                when_HazardSimplePlugin_l76;
  wire                when_HazardSimplePlugin_l91;
  wire                when_HazardSimplePlugin_l92;
  wire                when_HazardSimplePlugin_l93;
  wire                when_HazardSimplePlugin_l96;
  wire                when_HazardSimplePlugin_l99;
  wire                _zz_when_HazardSimplePlugin_l79_2;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l64_1;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l79_3;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l70_1;
  wire                when_HazardSimplePlugin_l64_1;
  wire                when_HazardSimplePlugin_l67_1;
  wire                when_HazardSimplePlugin_l70_1;
  wire                when_HazardSimplePlugin_l79_1;
  wire                when_HazardSimplePlugin_l82_1;
  wire                when_HazardSimplePlugin_l85_1;
  wire                when_HazardSimplePlugin_l61_1;
  wire                when_HazardSimplePlugin_l76_1;
  wire                when_HazardSimplePlugin_l91_1;
  wire                when_HazardSimplePlugin_l92_1;
  wire                when_HazardSimplePlugin_l93_1;
  wire                when_HazardSimplePlugin_l96_1;
  wire                when_HazardSimplePlugin_l99_1;
  wire                _zz_when_HazardSimplePlugin_l79_4;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l64_2;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l79_5;
  wire       [4:0]    _zz_when_HazardSimplePlugin_l70_2;
  wire                when_HazardSimplePlugin_l64_2;
  wire                when_HazardSimplePlugin_l67_2;
  wire                when_HazardSimplePlugin_l70_2;
  wire                when_HazardSimplePlugin_l79_2;
  wire                when_HazardSimplePlugin_l82_2;
  wire                when_HazardSimplePlugin_l85_2;
  wire                when_HazardSimplePlugin_l61_2;
  wire                when_HazardSimplePlugin_l76_2;
  wire                when_HazardSimplePlugin_l91_2;
  wire                when_HazardSimplePlugin_l92_2;
  wire                when_HazardSimplePlugin_l93_2;
  wire                when_HazardSimplePlugin_l96_2;
  wire                when_HazardSimplePlugin_l99_2;
  wire                when_HazardSimplePlugin_l152;
  wire                when_HazardSimplePlugin_l155;
  wire                when_HazardSimplePlugin_l158;
  wire                when_HazardSimplePlugin_l163;
  wire                execute_BranchPlugin_eq;
  wire       [2:0]    switch_Misc_l211_1;
  reg                 _zz_execute_BRANCH_COND_RESULT;
  reg                 _zz_execute_BRANCH_COND_RESULT_1;
  wire                _zz_execute_BranchPlugin_missAlignedTarget;
  reg        [19:0]   _zz_execute_BranchPlugin_missAlignedTarget_1;
  wire                _zz_execute_BranchPlugin_missAlignedTarget_2;
  reg        [10:0]   _zz_execute_BranchPlugin_missAlignedTarget_3;
  wire                _zz_execute_BranchPlugin_missAlignedTarget_4;
  reg        [18:0]   _zz_execute_BranchPlugin_missAlignedTarget_5;
  reg                 _zz_execute_BranchPlugin_missAlignedTarget_6;
  wire                execute_BranchPlugin_missAlignedTarget;
  reg        [31:0]   execute_BranchPlugin_branch_src1;
  reg        [31:0]   execute_BranchPlugin_branch_src2;
  wire                _zz_execute_BranchPlugin_branch_src2;
  reg        [19:0]   _zz_execute_BranchPlugin_branch_src2_1;
  wire                _zz_execute_BranchPlugin_branch_src2_2;
  reg        [10:0]   _zz_execute_BranchPlugin_branch_src2_3;
  wire                _zz_execute_BranchPlugin_branch_src2_4;
  reg        [18:0]   _zz_execute_BranchPlugin_branch_src2_5;
  wire       [31:0]   execute_BranchPlugin_branchAdder;
  wire                when_Pipeline_l124;
  reg        [31:0]   decode_to_execute_PC;
  wire                when_Pipeline_l124_1;
  reg        [31:0]   execute_to_memory_PC;
  wire                when_Pipeline_l124_2;
  reg        [31:0]   memory_to_writeBack_PC;
  wire                when_Pipeline_l124_3;
  reg        [31:0]   decode_to_execute_INSTRUCTION;
  wire                when_Pipeline_l124_4;
  reg        [31:0]   execute_to_memory_INSTRUCTION;
  wire                when_Pipeline_l124_5;
  reg        [31:0]   memory_to_writeBack_INSTRUCTION;
  wire                when_Pipeline_l124_6;
  reg        [31:0]   decode_to_execute_FORMAL_PC_NEXT;
  wire                when_Pipeline_l124_7;
  reg        [31:0]   execute_to_memory_FORMAL_PC_NEXT;
  wire                when_Pipeline_l124_8;
  reg        [31:0]   memory_to_writeBack_FORMAL_PC_NEXT;
  wire                when_Pipeline_l124_9;
  reg                 decode_to_execute_MEMORY_FORCE_CONSTISTENCY;
  wire                when_Pipeline_l124_10;
  reg        [1:0]    decode_to_execute_SRC1_CTRL;
  wire                when_Pipeline_l124_11;
  reg                 decode_to_execute_SRC_USE_SUB_LESS;
  wire                when_Pipeline_l124_12;
  reg                 decode_to_execute_MEMORY_ENABLE;
  wire                when_Pipeline_l124_13;
  reg                 execute_to_memory_MEMORY_ENABLE;
  wire                when_Pipeline_l124_14;
  reg                 memory_to_writeBack_MEMORY_ENABLE;
  wire                when_Pipeline_l124_15;
  reg        [1:0]    decode_to_execute_ALU_CTRL;
  wire                when_Pipeline_l124_16;
  reg        [1:0]    decode_to_execute_SRC2_CTRL;
  wire                when_Pipeline_l124_17;
  reg                 decode_to_execute_REGFILE_WRITE_VALID;
  wire                when_Pipeline_l124_18;
  reg                 execute_to_memory_REGFILE_WRITE_VALID;
  wire                when_Pipeline_l124_19;
  reg                 memory_to_writeBack_REGFILE_WRITE_VALID;
  wire                when_Pipeline_l124_20;
  reg                 decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  wire                when_Pipeline_l124_21;
  reg                 decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  wire                when_Pipeline_l124_22;
  reg                 execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  wire                when_Pipeline_l124_23;
  reg                 decode_to_execute_MEMORY_WR;
  wire                when_Pipeline_l124_24;
  reg                 decode_to_execute_REGFILE_WRITE_VALID_ODD;
  wire                when_Pipeline_l124_25;
  reg                 execute_to_memory_REGFILE_WRITE_VALID_ODD;
  wire                when_Pipeline_l124_26;
  reg                 memory_to_writeBack_REGFILE_WRITE_VALID_ODD;
  wire                when_Pipeline_l124_27;
  reg        [0:0]    decode_to_execute_SRC3_CTRL;
  wire                when_Pipeline_l124_28;
  reg                 decode_to_execute_MEMORY_MANAGMENT;
  wire                when_Pipeline_l124_29;
  reg                 decode_to_execute_SRC_LESS_UNSIGNED;
  wire                when_Pipeline_l124_30;
  reg        [1:0]    decode_to_execute_ALU_BITWISE_CTRL;
  wire                when_Pipeline_l124_31;
  reg                 decode_to_execute_IS_MUL;
  wire                when_Pipeline_l124_32;
  reg                 execute_to_memory_IS_MUL;
  wire                when_Pipeline_l124_33;
  reg                 memory_to_writeBack_IS_MUL;
  wire                when_Pipeline_l124_34;
  reg        [1:0]    decode_to_execute_SHIFT_CTRL;
  wire                when_Pipeline_l124_35;
  reg        [1:0]    execute_to_memory_SHIFT_CTRL;
  wire                when_Pipeline_l124_36;
  reg                 decode_to_execute_IS_CG6;
  wire                when_Pipeline_l124_37;
  reg                 execute_to_memory_IS_CG6;
  wire                when_Pipeline_l124_38;
  reg        [2:0]    decode_to_execute_CG6Ctrl;
  wire                when_Pipeline_l124_39;
  reg        [0:0]    decode_to_execute_CG6Ctrlminmax;
  wire                when_Pipeline_l124_40;
  reg        [0:0]    decode_to_execute_CG6Ctrlsignextend;
  wire                when_Pipeline_l124_41;
  reg        [1:0]    decode_to_execute_CG6Ctrlternary;
  wire                when_Pipeline_l124_42;
  reg                 decode_to_execute_IS_Goblin;
  wire                when_Pipeline_l124_43;
  reg                 execute_to_memory_IS_Goblin;
  wire                when_Pipeline_l124_44;
  reg        [0:0]    decode_to_execute_GoblinCtrlpdpikadd8;
  wire                when_Pipeline_l124_45;
  reg                 decode_to_execute_IS_Goblin2c;
  wire                when_Pipeline_l124_46;
  reg                 execute_to_memory_IS_Goblin2c;
  wire                when_Pipeline_l124_47;
  reg                 memory_to_writeBack_IS_Goblin2c;
  wire                when_Pipeline_l124_48;
  reg        [1:0]    decode_to_execute_BRANCH_CTRL;
  wire                when_Pipeline_l124_49;
  reg        [31:0]   decode_to_execute_RS1;
  wire                when_Pipeline_l124_50;
  reg        [31:0]   decode_to_execute_RS2;
  wire                when_Pipeline_l124_51;
  reg        [31:0]   decode_to_execute_RS3;
  wire                when_Pipeline_l124_52;
  reg                 decode_to_execute_SRC2_FORCE_ZERO;
  wire                when_Pipeline_l124_53;
  reg                 decode_to_execute_PREDICTION_HAD_BRANCHED2;
  wire                when_Pipeline_l124_54;
  reg        [63:0]   execute_to_memory_MEMORY_STORE_DATA_RF;
  wire                when_Pipeline_l124_55;
  reg        [63:0]   memory_to_writeBack_MEMORY_STORE_DATA_RF;
  wire                when_Pipeline_l124_56;
  reg        [31:0]   execute_to_memory_REGFILE_WRITE_DATA;
  wire                when_Pipeline_l124_57;
  reg        [31:0]   memory_to_writeBack_REGFILE_WRITE_DATA;
  wire                when_Pipeline_l124_58;
  reg        [31:0]   execute_to_memory_REGFILE_WRITE_DATA_ODD;
  wire                when_Pipeline_l124_59;
  reg        [31:0]   memory_to_writeBack_REGFILE_WRITE_DATA_ODD;
  wire                when_Pipeline_l124_60;
  reg        [31:0]   execute_to_memory_MUL_LL;
  wire                when_Pipeline_l124_61;
  reg        [33:0]   execute_to_memory_MUL_LH;
  wire                when_Pipeline_l124_62;
  reg        [33:0]   execute_to_memory_MUL_HL;
  wire                when_Pipeline_l124_63;
  reg        [33:0]   execute_to_memory_MUL_HH;
  wire                when_Pipeline_l124_64;
  reg        [33:0]   memory_to_writeBack_MUL_HH;
  wire                when_Pipeline_l124_65;
  reg        [31:0]   execute_to_memory_SHIFT_RIGHT;
  wire                when_Pipeline_l124_66;
  reg        [31:0]   execute_to_memory_CG6_FINAL_OUTPUT;
  wire                when_Pipeline_l124_67;
  reg        [31:0]   execute_to_memory_Goblin_FINAL_OUTPUT;
  wire                when_Pipeline_l124_68;
  reg        [63:0]   execute_to_memory_Goblin2c_INTERMEDIATE_UFMA8VxV64;
  wire                when_Pipeline_l124_69;
  reg                 execute_to_memory_BRANCH_DO;
  wire                when_Pipeline_l124_70;
  reg        [31:0]   execute_to_memory_BRANCH_CALC;
  wire                when_Pipeline_l124_71;
  reg        [51:0]   memory_to_writeBack_MUL_LOW;
  wire                when_Pipeline_l124_72;
  reg        [31:0]   memory_to_writeBack_Goblin2c_FINAL_OUTPUT;
  wire                when_Pipeline_l151;
  wire                when_Pipeline_l154;
  wire                when_Pipeline_l151_1;
  wire                when_Pipeline_l154_1;
  wire                when_Pipeline_l151_2;
  wire                when_Pipeline_l154_2;
  reg        [1:0]    _zz_iBusWishbone_ADR;
  wire                when_InstructionCache_l239;
  reg                 _zz_iBus_rsp_valid;
  reg        [31:0]   iBusWishbone_DAT_MISO_regNext;
  wire                _zz_dBus_cmd_ready;
  wire                _zz_dBus_cmd_ready_1;
  wire                _zz_dBus_cmd_ready_2;
  wire                _zz_dBus_cmd_ready_3;
  reg                 _zz_dBus_rsp_valid;
  reg        [127:0]  dBusWishbone_DAT_MISO_regNext;
  `ifndef SYNTHESIS
  reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_string;
  reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_1_string;
  reg [87:0] decode_GoblinCtrlpdpikadd8_string;
  reg [87:0] _zz_decode_GoblinCtrlpdpikadd8_string;
  reg [87:0] _zz_decode_to_execute_GoblinCtrlpdpikadd8_string;
  reg [87:0] _zz_decode_to_execute_GoblinCtrlpdpikadd8_1_string;
  reg [71:0] decode_CG6Ctrlternary_string;
  reg [71:0] _zz_decode_CG6Ctrlternary_string;
  reg [71:0] _zz_decode_to_execute_CG6Ctrlternary_string;
  reg [71:0] _zz_decode_to_execute_CG6Ctrlternary_1_string;
  reg [103:0] decode_CG6Ctrlsignextend_string;
  reg [103:0] _zz_decode_CG6Ctrlsignextend_string;
  reg [103:0] _zz_decode_to_execute_CG6Ctrlsignextend_string;
  reg [103:0] _zz_decode_to_execute_CG6Ctrlsignextend_1_string;
  reg [71:0] decode_CG6Ctrlminmax_string;
  reg [71:0] _zz_decode_CG6Ctrlminmax_string;
  reg [71:0] _zz_decode_to_execute_CG6Ctrlminmax_string;
  reg [71:0] _zz_decode_to_execute_CG6Ctrlminmax_1_string;
  reg [119:0] decode_CG6Ctrl_string;
  reg [119:0] _zz_decode_CG6Ctrl_string;
  reg [119:0] _zz_decode_to_execute_CG6Ctrl_string;
  reg [119:0] _zz_decode_to_execute_CG6Ctrl_1_string;
  reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_string;
  reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_1_string;
  reg [71:0] decode_SHIFT_CTRL_string;
  reg [71:0] _zz_decode_SHIFT_CTRL_string;
  reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_string;
  reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_1_string;
  reg [39:0] decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_decode_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string;
  reg [23:0] decode_SRC3_CTRL_string;
  reg [23:0] _zz_decode_SRC3_CTRL_string;
  reg [23:0] _zz_decode_to_execute_SRC3_CTRL_string;
  reg [23:0] _zz_decode_to_execute_SRC3_CTRL_1_string;
  reg [23:0] decode_SRC2_CTRL_string;
  reg [23:0] _zz_decode_SRC2_CTRL_string;
  reg [23:0] _zz_decode_to_execute_SRC2_CTRL_string;
  reg [23:0] _zz_decode_to_execute_SRC2_CTRL_1_string;
  reg [63:0] decode_ALU_CTRL_string;
  reg [63:0] _zz_decode_ALU_CTRL_string;
  reg [63:0] _zz_decode_to_execute_ALU_CTRL_string;
  reg [63:0] _zz_decode_to_execute_ALU_CTRL_1_string;
  reg [95:0] decode_SRC1_CTRL_string;
  reg [95:0] _zz_decode_SRC1_CTRL_string;
  reg [95:0] _zz_decode_to_execute_SRC1_CTRL_string;
  reg [95:0] _zz_decode_to_execute_SRC1_CTRL_1_string;
  reg [31:0] execute_BRANCH_CTRL_string;
  reg [31:0] _zz_execute_BRANCH_CTRL_string;
  reg [87:0] execute_GoblinCtrlpdpikadd8_string;
  reg [87:0] _zz_execute_GoblinCtrlpdpikadd8_string;
  reg [119:0] execute_CG6Ctrl_string;
  reg [119:0] _zz_execute_CG6Ctrl_string;
  reg [71:0] execute_CG6Ctrlternary_string;
  reg [71:0] _zz_execute_CG6Ctrlternary_string;
  reg [103:0] execute_CG6Ctrlsignextend_string;
  reg [103:0] _zz_execute_CG6Ctrlsignextend_string;
  reg [71:0] execute_CG6Ctrlminmax_string;
  reg [71:0] _zz_execute_CG6Ctrlminmax_string;
  reg [71:0] memory_SHIFT_CTRL_string;
  reg [71:0] _zz_memory_SHIFT_CTRL_string;
  reg [71:0] execute_SHIFT_CTRL_string;
  reg [71:0] _zz_execute_SHIFT_CTRL_string;
  reg [23:0] execute_SRC3_CTRL_string;
  reg [23:0] _zz_execute_SRC3_CTRL_string;
  reg [23:0] execute_SRC2_CTRL_string;
  reg [23:0] _zz_execute_SRC2_CTRL_string;
  reg [95:0] execute_SRC1_CTRL_string;
  reg [95:0] _zz_execute_SRC1_CTRL_string;
  reg [63:0] execute_ALU_CTRL_string;
  reg [63:0] _zz_execute_ALU_CTRL_string;
  reg [39:0] execute_ALU_BITWISE_CTRL_string;
  reg [39:0] _zz_execute_ALU_BITWISE_CTRL_string;
  reg [31:0] _zz_decode_BRANCH_CTRL_string;
  reg [87:0] _zz_decode_GoblinCtrlpdpikadd8_1_string;
  reg [71:0] _zz_decode_CG6Ctrlternary_1_string;
  reg [103:0] _zz_decode_CG6Ctrlsignextend_1_string;
  reg [71:0] _zz_decode_CG6Ctrlminmax_1_string;
  reg [119:0] _zz_decode_CG6Ctrl_1_string;
  reg [71:0] _zz_decode_SHIFT_CTRL_1_string;
  reg [39:0] _zz_decode_ALU_BITWISE_CTRL_1_string;
  reg [23:0] _zz_decode_SRC3_CTRL_1_string;
  reg [23:0] _zz_decode_SRC2_CTRL_1_string;
  reg [63:0] _zz_decode_ALU_CTRL_1_string;
  reg [95:0] _zz_decode_SRC1_CTRL_1_string;
  reg [31:0] decode_BRANCH_CTRL_string;
  reg [31:0] _zz_decode_BRANCH_CTRL_1_string;
  reg [95:0] _zz_decode_SRC1_CTRL_2_string;
  reg [63:0] _zz_decode_ALU_CTRL_2_string;
  reg [23:0] _zz_decode_SRC2_CTRL_2_string;
  reg [23:0] _zz_decode_SRC3_CTRL_2_string;
  reg [39:0] _zz_decode_ALU_BITWISE_CTRL_2_string;
  reg [71:0] _zz_decode_SHIFT_CTRL_2_string;
  reg [119:0] _zz_decode_CG6Ctrl_2_string;
  reg [71:0] _zz_decode_CG6Ctrlminmax_2_string;
  reg [103:0] _zz_decode_CG6Ctrlsignextend_2_string;
  reg [71:0] _zz_decode_CG6Ctrlternary_2_string;
  reg [87:0] _zz_decode_GoblinCtrlpdpikadd8_2_string;
  reg [31:0] _zz_decode_BRANCH_CTRL_2_string;
  reg [95:0] decode_to_execute_SRC1_CTRL_string;
  reg [63:0] decode_to_execute_ALU_CTRL_string;
  reg [23:0] decode_to_execute_SRC2_CTRL_string;
  reg [23:0] decode_to_execute_SRC3_CTRL_string;
  reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
  reg [71:0] decode_to_execute_SHIFT_CTRL_string;
  reg [71:0] execute_to_memory_SHIFT_CTRL_string;
  reg [119:0] decode_to_execute_CG6Ctrl_string;
  reg [71:0] decode_to_execute_CG6Ctrlminmax_string;
  reg [103:0] decode_to_execute_CG6Ctrlsignextend_string;
  reg [71:0] decode_to_execute_CG6Ctrlternary_string;
  reg [87:0] decode_to_execute_GoblinCtrlpdpikadd8_string;
  reg [31:0] decode_to_execute_BRANCH_CTRL_string;
  `endif

  (* ram_style = "distributed" *) reg [31:0] RegFileOddEvenPlugin_regFileEven [0:15] /* verilator public */ ;
  (* ram_style = "distributed" *) reg [31:0] RegFileOddEvenPlugin_regFileOdd [0:15] /* verilator public */ ;

  assign _zz_memory_Goblin2c_FINAL_OUTPUT_10 = _zz_memory_Goblin2c_FINAL_OUTPUT_8;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_9 = _zz_memory_Goblin2c_FINAL_OUTPUT_10;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_12 = _zz_memory_Goblin2c_FINAL_OUTPUT_6;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_11 = _zz_memory_Goblin2c_FINAL_OUTPUT_12;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_14 = _zz_memory_Goblin2c_FINAL_OUTPUT_4;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_13 = _zz_memory_Goblin2c_FINAL_OUTPUT_14;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_16 = _zz_memory_Goblin2c_FINAL_OUTPUT_2;
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_15 = _zz_memory_Goblin2c_FINAL_OUTPUT_16;
  assign _zz_memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW_1) + $signed(_zz_memory_MUL_LOW_5));
  assign _zz_memory_MUL_LOW_1 = ($signed(_zz_memory_MUL_LOW_2) + $signed(_zz_memory_MUL_LOW_3));
  assign _zz_memory_MUL_LOW_2 = 52'h0;
  assign _zz_memory_MUL_LOW_4 = {1'b0,memory_MUL_LL};
  assign _zz_memory_MUL_LOW_3 = {{19{_zz_memory_MUL_LOW_4[32]}}, _zz_memory_MUL_LOW_4};
  assign _zz_memory_MUL_LOW_6 = ({16'd0,memory_MUL_LH} <<< 16);
  assign _zz_memory_MUL_LOW_5 = {{2{_zz_memory_MUL_LOW_6[49]}}, _zz_memory_MUL_LOW_6};
  assign _zz_memory_MUL_LOW_8 = ({16'd0,memory_MUL_HL} <<< 16);
  assign _zz_memory_MUL_LOW_7 = {{2{_zz_memory_MUL_LOW_8[49]}}, _zz_memory_MUL_LOW_8};
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_1 = _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_2;
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_2 = (execute_SRC1[31 : 24] * _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64);
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_3 = _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_4;
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_4 = (execute_SRC1[23 : 16] * _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64);
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_5 = _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_6;
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_6 = (execute_SRC1[15 : 8] * _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64);
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_7 = _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_8;
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_8 = (execute_SRC1[7 : 0] * _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64);
  assign _zz_execute_SHIFT_RIGHT_1 = ($signed(_zz_execute_SHIFT_RIGHT_2) >>> execute_FullBarrelShifterPlugin_amplitude);
  assign _zz_execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT_1[31 : 0];
  assign _zz_execute_SHIFT_RIGHT_2 = {((execute_SHIFT_CTRL == ShiftCtrlEnum_SRA_1) && execute_FullBarrelShifterPlugin_reversed[31]),execute_FullBarrelShifterPlugin_reversed};
  assign _zz__zz_IBusCachedPlugin_jump_pcLoad_payload_1 = (_zz_IBusCachedPlugin_jump_pcLoad_payload - 3'b001);
  assign _zz_IBusCachedPlugin_fetchPc_pc_1 = {IBusCachedPlugin_fetchPc_inc,2'b00};
  assign _zz_IBusCachedPlugin_fetchPc_pc = {29'd0, _zz_IBusCachedPlugin_fetchPc_pc_1};
  assign _zz__zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_2 = {{_zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz__zz_3 = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz__zz_5 = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz__zz_7 = {{_zz_4,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz__zz_7_1 = {{_zz_6,{{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload_2 = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz__zz_execute_REGFILE_WRITE_DATA = execute_SRC_LESS;
  assign _zz__zz_execute_SRC1 = 3'b100;
  assign _zz__zz_execute_SRC1_1 = execute_INSTRUCTION[19 : 15];
  assign _zz__zz_execute_SRC2_3 = {execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]};
  assign _zz_execute_SrcPlugin_addSub = ($signed(_zz_execute_SrcPlugin_addSub_1) + $signed(_zz_execute_SrcPlugin_addSub_4));
  assign _zz_execute_SrcPlugin_addSub_1 = ($signed(_zz_execute_SrcPlugin_addSub_2) + $signed(_zz_execute_SrcPlugin_addSub_3));
  assign _zz_execute_SrcPlugin_addSub_2 = execute_SRC1;
  assign _zz_execute_SrcPlugin_addSub_3 = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
  assign _zz_execute_SrcPlugin_addSub_4 = (execute_SRC_USE_SUB_LESS ? _zz_execute_SrcPlugin_addSub_5 : _zz_execute_SrcPlugin_addSub_6);
  assign _zz_execute_SrcPlugin_addSub_5 = 32'h00000001;
  assign _zz_execute_SrcPlugin_addSub_6 = 32'h0;
  assign _zz_writeBack_MulPlugin_result = {{14{writeBack_MUL_LOW[51]}}, writeBack_MUL_LOW};
  assign _zz_writeBack_MulPlugin_result_1 = ({32'd0,writeBack_MUL_HH} <<< 32);
  assign _zz__zz_decode_RS3_5 = writeBack_MUL_LOW[31 : 0];
  assign _zz__zz_decode_RS3_5_1 = writeBack_MulPlugin_result[63 : 32];
  assign _zz__zz_execute_CG6Plugin_val_ternary_1 = (_zz_execute_CG6Plugin_val_ternary - 32'h00000020);
  assign _zz_execute_CG6Plugin_val_ternary_3 = (_zz_execute_CG6Plugin_val_ternary_2 >>> _zz_execute_CG6Plugin_val_ternary_1);
  assign _zz_execute_CG6Plugin_val_ternary_4 = (((_zz_execute_CG6Plugin_val_ternary_1 == _zz_execute_CG6Plugin_val_ternary) ? execute_SRC3 : execute_SRC1) <<< _zz_execute_CG6Plugin_val_ternary_5);
  assign _zz_execute_CG6Plugin_val_ternary_5 = (32'h00000020 - _zz_execute_CG6Plugin_val_ternary_1);
  assign _zz__zz_execute_CG6_FINAL_OUTPUT = (_zz__zz_execute_CG6_FINAL_OUTPUT_1 + execute_SRC2);
  assign _zz__zz_execute_CG6_FINAL_OUTPUT_1 = (execute_SRC1 <<< 2);
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_6 = {_zz_execute_GoblinPlugin_val_pdpikadd8_4[8],_zz_execute_GoblinPlugin_val_pdpikadd8_4};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_6_1 = {_zz_execute_GoblinPlugin_val_pdpikadd8_5[8],_zz_execute_GoblinPlugin_val_pdpikadd8_5};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_9 = {_zz_execute_GoblinPlugin_val_pdpikadd8_7[8],_zz_execute_GoblinPlugin_val_pdpikadd8_7};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_9_1 = {_zz_execute_GoblinPlugin_val_pdpikadd8_8[8],_zz_execute_GoblinPlugin_val_pdpikadd8_8};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_12 = {_zz_execute_GoblinPlugin_val_pdpikadd8_10[8],_zz_execute_GoblinPlugin_val_pdpikadd8_10};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_12_1 = {_zz_execute_GoblinPlugin_val_pdpikadd8_11[8],_zz_execute_GoblinPlugin_val_pdpikadd8_11};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_15 = {_zz_execute_GoblinPlugin_val_pdpikadd8_13[8],_zz_execute_GoblinPlugin_val_pdpikadd8_13};
  assign _zz__zz_execute_GoblinPlugin_val_pdpikadd8_15_1 = {_zz_execute_GoblinPlugin_val_pdpikadd8_14[8],_zz_execute_GoblinPlugin_val_pdpikadd8_14};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_17 = _zz_execute_GoblinPlugin_val_pdpikadd8_3;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_16 = _zz_execute_GoblinPlugin_val_pdpikadd8_17;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_19 = _zz_execute_GoblinPlugin_val_pdpikadd8_2;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_18 = _zz_execute_GoblinPlugin_val_pdpikadd8_19;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_21 = _zz_execute_GoblinPlugin_val_pdpikadd8_1;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_20 = _zz_execute_GoblinPlugin_val_pdpikadd8_21;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_23 = _zz_execute_GoblinPlugin_val_pdpikadd8;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_22 = _zz_execute_GoblinPlugin_val_pdpikadd8_23;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_27 = _zz_execute_GoblinPlugin_val_pdpikadd8_15[7 : 0];
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_31 = _zz_execute_GoblinPlugin_val_pdpikadd8_12[7 : 0];
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_37 = _zz_execute_GoblinPlugin_val_pdpikadd8_9[7 : 0];
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_41 = _zz_execute_GoblinPlugin_val_pdpikadd8_6[7 : 0];
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_2 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_4 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6 = {_zz_execute_BranchPlugin_missAlignedTarget_1,execute_INSTRUCTION[31 : 20]};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1 = {{_zz_execute_BranchPlugin_missAlignedTarget_3,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2 = {{_zz_execute_BranchPlugin_missAlignedTarget_5,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz__zz_execute_BranchPlugin_branch_src2_2 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz__zz_execute_BranchPlugin_branch_src2_4 = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_execute_BranchPlugin_branch_src2_9 = 3'b100;
  assign _zz_iBusWishbone_ADR_1 = (iBus_cmd_payload_address >>> 4);
  assign _zz_IBusCachedPlugin_jump_pcLoad_payload_5 = {_zz_IBusCachedPlugin_jump_pcLoad_payload_3,_zz_IBusCachedPlugin_jump_pcLoad_payload_2};
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_1 = dataCache_1_io_cpu_writeBack_address[3 : 0];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_3 = dataCache_1_io_cpu_writeBack_address[3 : 1];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_5 = dataCache_1_io_cpu_writeBack_address[3 : 2];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_7 = dataCache_1_io_cpu_writeBack_address[3 : 2];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_9 = dataCache_1_io_cpu_writeBack_address[3 : 3];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_11 = dataCache_1_io_cpu_writeBack_address[3 : 3];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_13 = dataCache_1_io_cpu_writeBack_address[3 : 3];
  assign _zz_writeBack_DBusCachedPlugin_rspShifted_15 = dataCache_1_io_cpu_writeBack_address[3 : 3];
  assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_4 = decode_INSTRUCTION[31];
  assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_5 = decode_INSTRUCTION[31];
  assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_6 = decode_INSTRUCTION[7];
  assign _zz__zz_decode_IS_Goblin2c = (decode_INSTRUCTION & 32'h0000001c);
  assign _zz__zz_decode_IS_Goblin2c_1 = 32'h00000004;
  assign _zz__zz_decode_IS_Goblin2c_2 = (decode_INSTRUCTION & 32'h00000058);
  assign _zz__zz_decode_IS_Goblin2c_3 = 32'h00000040;
  assign _zz__zz_decode_IS_Goblin2c_4 = _zz_decode_IS_Goblin2c_9;
  assign _zz__zz_decode_IS_Goblin2c_5 = (|((decode_INSTRUCTION & 32'h80000050) == 32'h00000050));
  assign _zz__zz_decode_IS_Goblin2c_6 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_7) == 32'h0));
  assign _zz__zz_decode_IS_Goblin2c_8 = {(|(_zz__zz_decode_IS_Goblin2c_9 == _zz__zz_decode_IS_Goblin2c_10)),{(|_zz__zz_decode_IS_Goblin2c_11),{(|_zz__zz_decode_IS_Goblin2c_12),{_zz__zz_decode_IS_Goblin2c_13,{_zz__zz_decode_IS_Goblin2c_15,_zz__zz_decode_IS_Goblin2c_20}}}}};
  assign _zz__zz_decode_IS_Goblin2c_7 = 32'h02000000;
  assign _zz__zz_decode_IS_Goblin2c_9 = (decode_INSTRUCTION & 32'h02004000);
  assign _zz__zz_decode_IS_Goblin2c_10 = 32'h02004000;
  assign _zz__zz_decode_IS_Goblin2c_11 = ((decode_INSTRUCTION & 32'h40000000) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_12 = ((decode_INSTRUCTION & 32'h00002000) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_13 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_14) == 32'h0));
  assign _zz__zz_decode_IS_Goblin2c_15 = (|{_zz_decode_IS_Goblin2c_8,{_zz__zz_decode_IS_Goblin2c_16,_zz__zz_decode_IS_Goblin2c_18}});
  assign _zz__zz_decode_IS_Goblin2c_20 = {(|{_zz__zz_decode_IS_Goblin2c_21,_zz__zz_decode_IS_Goblin2c_22}),{(|_zz__zz_decode_IS_Goblin2c_23),{_zz__zz_decode_IS_Goblin2c_30,{_zz__zz_decode_IS_Goblin2c_33,_zz__zz_decode_IS_Goblin2c_41}}}};
  assign _zz__zz_decode_IS_Goblin2c_14 = 32'h00400020;
  assign _zz__zz_decode_IS_Goblin2c_16 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_17) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_18 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_19) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_21 = _zz_decode_IS_Goblin2c_9;
  assign _zz__zz_decode_IS_Goblin2c_22 = _zz_decode_IS_Goblin2c_8;
  assign _zz__zz_decode_IS_Goblin2c_23 = {(_zz__zz_decode_IS_Goblin2c_24 == _zz__zz_decode_IS_Goblin2c_25),{_zz_decode_IS_Goblin2c_6,{_zz__zz_decode_IS_Goblin2c_26,_zz__zz_decode_IS_Goblin2c_28}}};
  assign _zz__zz_decode_IS_Goblin2c_30 = (|(_zz__zz_decode_IS_Goblin2c_31 == _zz__zz_decode_IS_Goblin2c_32));
  assign _zz__zz_decode_IS_Goblin2c_33 = (|{_zz__zz_decode_IS_Goblin2c_34,_zz__zz_decode_IS_Goblin2c_36});
  assign _zz__zz_decode_IS_Goblin2c_41 = {(|_zz__zz_decode_IS_Goblin2c_42),{_zz__zz_decode_IS_Goblin2c_44,{_zz__zz_decode_IS_Goblin2c_47,_zz__zz_decode_IS_Goblin2c_49}}};
  assign _zz__zz_decode_IS_Goblin2c_17 = 32'h00004000;
  assign _zz__zz_decode_IS_Goblin2c_19 = 32'h22000000;
  assign _zz__zz_decode_IS_Goblin2c_24 = (decode_INSTRUCTION & 32'h08004064);
  assign _zz__zz_decode_IS_Goblin2c_25 = 32'h08004020;
  assign _zz__zz_decode_IS_Goblin2c_26 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_27) == 32'h20001010);
  assign _zz__zz_decode_IS_Goblin2c_28 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_29) == 32'h20004020);
  assign _zz__zz_decode_IS_Goblin2c_31 = (decode_INSTRUCTION & 32'h0c007014);
  assign _zz__zz_decode_IS_Goblin2c_32 = 32'h00005010;
  assign _zz__zz_decode_IS_Goblin2c_34 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_35) == 32'h40001010);
  assign _zz__zz_decode_IS_Goblin2c_36 = {(_zz__zz_decode_IS_Goblin2c_37 == _zz__zz_decode_IS_Goblin2c_38),(_zz__zz_decode_IS_Goblin2c_39 == _zz__zz_decode_IS_Goblin2c_40)};
  assign _zz__zz_decode_IS_Goblin2c_42 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_43) == 32'h02000030);
  assign _zz__zz_decode_IS_Goblin2c_44 = (|(_zz__zz_decode_IS_Goblin2c_45 == _zz__zz_decode_IS_Goblin2c_46));
  assign _zz__zz_decode_IS_Goblin2c_47 = (|_zz__zz_decode_IS_Goblin2c_48);
  assign _zz__zz_decode_IS_Goblin2c_49 = {(|_zz__zz_decode_IS_Goblin2c_50),{_zz__zz_decode_IS_Goblin2c_51,{_zz__zz_decode_IS_Goblin2c_56,_zz__zz_decode_IS_Goblin2c_59}}};
  assign _zz__zz_decode_IS_Goblin2c_27 = 32'h20003014;
  assign _zz__zz_decode_IS_Goblin2c_29 = 32'h20004064;
  assign _zz__zz_decode_IS_Goblin2c_35 = 32'h64003014;
  assign _zz__zz_decode_IS_Goblin2c_37 = (decode_INSTRUCTION & 32'h42007014);
  assign _zz__zz_decode_IS_Goblin2c_38 = 32'h00001010;
  assign _zz__zz_decode_IS_Goblin2c_39 = (decode_INSTRUCTION & 32'h40007034);
  assign _zz__zz_decode_IS_Goblin2c_40 = 32'h00001010;
  assign _zz__zz_decode_IS_Goblin2c_43 = 32'h0e000034;
  assign _zz__zz_decode_IS_Goblin2c_45 = (decode_INSTRUCTION & 32'h00000064);
  assign _zz__zz_decode_IS_Goblin2c_46 = 32'h00000024;
  assign _zz__zz_decode_IS_Goblin2c_48 = ((decode_INSTRUCTION & 32'h00001000) == 32'h00001000);
  assign _zz__zz_decode_IS_Goblin2c_50 = ((decode_INSTRUCTION & 32'h00003000) == 32'h00002000);
  assign _zz__zz_decode_IS_Goblin2c_51 = (|{(_zz__zz_decode_IS_Goblin2c_52 == _zz__zz_decode_IS_Goblin2c_53),(_zz__zz_decode_IS_Goblin2c_54 == _zz__zz_decode_IS_Goblin2c_55)});
  assign _zz__zz_decode_IS_Goblin2c_56 = (|(_zz__zz_decode_IS_Goblin2c_57 == _zz__zz_decode_IS_Goblin2c_58));
  assign _zz__zz_decode_IS_Goblin2c_59 = {(|{_zz__zz_decode_IS_Goblin2c_60,_zz__zz_decode_IS_Goblin2c_61}),{1'b0,{_zz__zz_decode_IS_Goblin2c_63,{_zz__zz_decode_IS_Goblin2c_65,_zz__zz_decode_IS_Goblin2c_77}}}};
  assign _zz__zz_decode_IS_Goblin2c_52 = (decode_INSTRUCTION & 32'h00002010);
  assign _zz__zz_decode_IS_Goblin2c_53 = 32'h00002000;
  assign _zz__zz_decode_IS_Goblin2c_54 = (decode_INSTRUCTION & 32'h00005000);
  assign _zz__zz_decode_IS_Goblin2c_55 = 32'h00001000;
  assign _zz__zz_decode_IS_Goblin2c_57 = (decode_INSTRUCTION & 32'h00004048);
  assign _zz__zz_decode_IS_Goblin2c_58 = 32'h00004008;
  assign _zz__zz_decode_IS_Goblin2c_60 = _zz_decode_IS_Goblin2c_7;
  assign _zz__zz_decode_IS_Goblin2c_61 = {_zz_decode_IS_Goblin2c_6,((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_62) == 32'h00003020)};
  assign _zz__zz_decode_IS_Goblin2c_63 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_64) == 32'h00003000));
  assign _zz__zz_decode_IS_Goblin2c_65 = (|{_zz__zz_decode_IS_Goblin2c_66,{_zz__zz_decode_IS_Goblin2c_67,_zz__zz_decode_IS_Goblin2c_68}});
  assign _zz__zz_decode_IS_Goblin2c_77 = {(|{_zz__zz_decode_IS_Goblin2c_78,_zz__zz_decode_IS_Goblin2c_80}),{(|_zz__zz_decode_IS_Goblin2c_82),{_zz__zz_decode_IS_Goblin2c_84,{_zz__zz_decode_IS_Goblin2c_97,_zz__zz_decode_IS_Goblin2c_110}}}};
  assign _zz__zz_decode_IS_Goblin2c_62 = 32'h00003070;
  assign _zz__zz_decode_IS_Goblin2c_64 = 32'h00003030;
  assign _zz__zz_decode_IS_Goblin2c_66 = ((decode_INSTRUCTION & 32'h00000050) == 32'h00000050);
  assign _zz__zz_decode_IS_Goblin2c_67 = _zz_decode_IS_Goblin2c_3;
  assign _zz__zz_decode_IS_Goblin2c_68 = {(_zz__zz_decode_IS_Goblin2c_69 == _zz__zz_decode_IS_Goblin2c_70),{_zz__zz_decode_IS_Goblin2c_71,{_zz__zz_decode_IS_Goblin2c_73,_zz__zz_decode_IS_Goblin2c_76}}};
  assign _zz__zz_decode_IS_Goblin2c_78 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_79) == 32'h00000040);
  assign _zz__zz_decode_IS_Goblin2c_80 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_81) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_82 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_83) == 32'h00000020);
  assign _zz__zz_decode_IS_Goblin2c_84 = (|{_zz__zz_decode_IS_Goblin2c_85,{_zz__zz_decode_IS_Goblin2c_87,_zz__zz_decode_IS_Goblin2c_88}});
  assign _zz__zz_decode_IS_Goblin2c_97 = (|{_zz__zz_decode_IS_Goblin2c_98,_zz__zz_decode_IS_Goblin2c_99});
  assign _zz__zz_decode_IS_Goblin2c_110 = {(|_zz__zz_decode_IS_Goblin2c_111),{_zz__zz_decode_IS_Goblin2c_120,{_zz__zz_decode_IS_Goblin2c_123,_zz__zz_decode_IS_Goblin2c_127}}};
  assign _zz__zz_decode_IS_Goblin2c_69 = (decode_INSTRUCTION & 32'h04000024);
  assign _zz__zz_decode_IS_Goblin2c_70 = 32'h04000020;
  assign _zz__zz_decode_IS_Goblin2c_71 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_72) == 32'h02000020);
  assign _zz__zz_decode_IS_Goblin2c_73 = (_zz__zz_decode_IS_Goblin2c_74 == _zz__zz_decode_IS_Goblin2c_75);
  assign _zz__zz_decode_IS_Goblin2c_76 = _zz_decode_IS_Goblin2c_4;
  assign _zz__zz_decode_IS_Goblin2c_79 = 32'h00000050;
  assign _zz__zz_decode_IS_Goblin2c_81 = 32'h00000018;
  assign _zz__zz_decode_IS_Goblin2c_83 = 32'h00000020;
  assign _zz__zz_decode_IS_Goblin2c_85 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_86) == 32'h00000010);
  assign _zz__zz_decode_IS_Goblin2c_87 = _zz_decode_IS_Goblin2c_1;
  assign _zz__zz_decode_IS_Goblin2c_88 = {_zz__zz_decode_IS_Goblin2c_89,{_zz__zz_decode_IS_Goblin2c_91,_zz__zz_decode_IS_Goblin2c_94}};
  assign _zz__zz_decode_IS_Goblin2c_98 = _zz_decode_IS_Goblin2c_1;
  assign _zz__zz_decode_IS_Goblin2c_99 = {_zz__zz_decode_IS_Goblin2c_100,{_zz__zz_decode_IS_Goblin2c_102,_zz__zz_decode_IS_Goblin2c_105}};
  assign _zz__zz_decode_IS_Goblin2c_111 = {_zz__zz_decode_IS_Goblin2c_112,{_zz__zz_decode_IS_Goblin2c_114,_zz__zz_decode_IS_Goblin2c_115}};
  assign _zz__zz_decode_IS_Goblin2c_120 = (|{_zz__zz_decode_IS_Goblin2c_121,_zz__zz_decode_IS_Goblin2c_122});
  assign _zz__zz_decode_IS_Goblin2c_123 = (|_zz__zz_decode_IS_Goblin2c_124);
  assign _zz__zz_decode_IS_Goblin2c_127 = {_zz__zz_decode_IS_Goblin2c_128,{_zz__zz_decode_IS_Goblin2c_131,_zz__zz_decode_IS_Goblin2c_135}};
  assign _zz__zz_decode_IS_Goblin2c_72 = 32'h02000024;
  assign _zz__zz_decode_IS_Goblin2c_74 = (decode_INSTRUCTION & 32'h08000024);
  assign _zz__zz_decode_IS_Goblin2c_75 = 32'h00000020;
  assign _zz__zz_decode_IS_Goblin2c_86 = 32'h00000030;
  assign _zz__zz_decode_IS_Goblin2c_89 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_90) == 32'h08000020);
  assign _zz__zz_decode_IS_Goblin2c_91 = (_zz__zz_decode_IS_Goblin2c_92 == _zz__zz_decode_IS_Goblin2c_93);
  assign _zz__zz_decode_IS_Goblin2c_94 = (_zz__zz_decode_IS_Goblin2c_95 == _zz__zz_decode_IS_Goblin2c_96);
  assign _zz__zz_decode_IS_Goblin2c_100 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_101) == 32'h00002010);
  assign _zz__zz_decode_IS_Goblin2c_102 = (_zz__zz_decode_IS_Goblin2c_103 == _zz__zz_decode_IS_Goblin2c_104);
  assign _zz__zz_decode_IS_Goblin2c_105 = {_zz__zz_decode_IS_Goblin2c_106,_zz__zz_decode_IS_Goblin2c_108};
  assign _zz__zz_decode_IS_Goblin2c_112 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_113) == 32'h00000010);
  assign _zz__zz_decode_IS_Goblin2c_114 = _zz_decode_IS_Goblin2c_5;
  assign _zz__zz_decode_IS_Goblin2c_115 = {_zz__zz_decode_IS_Goblin2c_116,_zz__zz_decode_IS_Goblin2c_118};
  assign _zz__zz_decode_IS_Goblin2c_121 = _zz_decode_IS_Goblin2c_2;
  assign _zz__zz_decode_IS_Goblin2c_122 = {_zz_decode_IS_Goblin2c_1,_zz_decode_IS_Goblin2c_4};
  assign _zz__zz_decode_IS_Goblin2c_124 = {_zz__zz_decode_IS_Goblin2c_125,_zz_decode_IS_Goblin2c_2};
  assign _zz__zz_decode_IS_Goblin2c_128 = (|_zz__zz_decode_IS_Goblin2c_129);
  assign _zz__zz_decode_IS_Goblin2c_131 = (|_zz__zz_decode_IS_Goblin2c_132);
  assign _zz__zz_decode_IS_Goblin2c_135 = {_zz__zz_decode_IS_Goblin2c_136,{_zz__zz_decode_IS_Goblin2c_139,_zz__zz_decode_IS_Goblin2c_141}};
  assign _zz__zz_decode_IS_Goblin2c_90 = 32'h88000020;
  assign _zz__zz_decode_IS_Goblin2c_92 = (decode_INSTRUCTION & 32'h04000060);
  assign _zz__zz_decode_IS_Goblin2c_93 = 32'h04000020;
  assign _zz__zz_decode_IS_Goblin2c_95 = (decode_INSTRUCTION & 32'h82000010);
  assign _zz__zz_decode_IS_Goblin2c_96 = 32'h00000010;
  assign _zz__zz_decode_IS_Goblin2c_101 = 32'h00002030;
  assign _zz__zz_decode_IS_Goblin2c_103 = (decode_INSTRUCTION & 32'h02002020);
  assign _zz__zz_decode_IS_Goblin2c_104 = 32'h00002020;
  assign _zz__zz_decode_IS_Goblin2c_106 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_107) == 32'h00000010);
  assign _zz__zz_decode_IS_Goblin2c_108 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_109) == 32'h00000020);
  assign _zz__zz_decode_IS_Goblin2c_113 = 32'h00000010;
  assign _zz__zz_decode_IS_Goblin2c_116 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_117) == 32'h00000004);
  assign _zz__zz_decode_IS_Goblin2c_118 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_119) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_125 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_126) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_129 = ((decode_INSTRUCTION & _zz__zz_decode_IS_Goblin2c_130) == 32'h00004010);
  assign _zz__zz_decode_IS_Goblin2c_132 = (_zz__zz_decode_IS_Goblin2c_133 == _zz__zz_decode_IS_Goblin2c_134);
  assign _zz__zz_decode_IS_Goblin2c_136 = (|{_zz__zz_decode_IS_Goblin2c_137,_zz__zz_decode_IS_Goblin2c_138});
  assign _zz__zz_decode_IS_Goblin2c_139 = (|_zz__zz_decode_IS_Goblin2c_140);
  assign _zz__zz_decode_IS_Goblin2c_141 = {_zz__zz_decode_IS_Goblin2c_142,{_zz__zz_decode_IS_Goblin2c_147,_zz__zz_decode_IS_Goblin2c_148}};
  assign _zz__zz_decode_IS_Goblin2c_107 = 32'h00001030;
  assign _zz__zz_decode_IS_Goblin2c_109 = 32'h2a001020;
  assign _zz__zz_decode_IS_Goblin2c_117 = 32'h0000000c;
  assign _zz__zz_decode_IS_Goblin2c_119 = 32'h00000028;
  assign _zz__zz_decode_IS_Goblin2c_126 = 32'h00000020;
  assign _zz__zz_decode_IS_Goblin2c_130 = 32'h00004014;
  assign _zz__zz_decode_IS_Goblin2c_133 = (decode_INSTRUCTION & 32'h00006014);
  assign _zz__zz_decode_IS_Goblin2c_134 = 32'h00002010;
  assign _zz__zz_decode_IS_Goblin2c_137 = ((decode_INSTRUCTION & 32'h00000004) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_138 = ((decode_INSTRUCTION & 32'h00000048) == 32'h00000040);
  assign _zz__zz_decode_IS_Goblin2c_140 = ((decode_INSTRUCTION & 32'h00000058) == 32'h0);
  assign _zz__zz_decode_IS_Goblin2c_142 = (|{_zz_decode_IS_Goblin2c_3,{(_zz__zz_decode_IS_Goblin2c_143 == _zz__zz_decode_IS_Goblin2c_144),(_zz__zz_decode_IS_Goblin2c_145 == _zz__zz_decode_IS_Goblin2c_146)}});
  assign _zz__zz_decode_IS_Goblin2c_147 = (|_zz_decode_IS_Goblin2c_2);
  assign _zz__zz_decode_IS_Goblin2c_148 = {(|_zz_decode_IS_Goblin2c_1),(|(_zz__zz_decode_IS_Goblin2c_149 == _zz__zz_decode_IS_Goblin2c_150))};
  assign _zz__zz_decode_IS_Goblin2c_143 = (decode_INSTRUCTION & 32'h00002014);
  assign _zz__zz_decode_IS_Goblin2c_144 = 32'h00002010;
  assign _zz__zz_decode_IS_Goblin2c_145 = (decode_INSTRUCTION & 32'h40000034);
  assign _zz__zz_decode_IS_Goblin2c_146 = 32'h40000030;
  assign _zz__zz_decode_IS_Goblin2c_149 = (decode_INSTRUCTION & 32'h00005048);
  assign _zz__zz_decode_IS_Goblin2c_150 = 32'h00001008;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_24 = (_zz_execute_GoblinPlugin_val_pdpikadd8_15[9] == 1'b1);
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_25 = 8'h0;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_26 = ((_zz_execute_GoblinPlugin_val_pdpikadd8_15[8] == 1'b1) ? 8'hff : _zz_execute_GoblinPlugin_val_pdpikadd8_27);
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_28 = (_zz_execute_GoblinPlugin_val_pdpikadd8_12[9] == 1'b1);
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_29 = 8'h0;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_30 = ((_zz_execute_GoblinPlugin_val_pdpikadd8_12[8] == 1'b1) ? 8'hff : _zz_execute_GoblinPlugin_val_pdpikadd8_31);
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_32 = _zz_execute_GoblinPlugin_val_pdpikadd8_9[9];
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_33 = 1'b1;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_34 = (_zz_execute_GoblinPlugin_val_pdpikadd8_9[8] == 1'b1);
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_35 = 8'hff;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_36 = _zz_execute_GoblinPlugin_val_pdpikadd8_37;
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_38 = _zz_execute_GoblinPlugin_val_pdpikadd8_6[9];
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_39 = _zz_execute_GoblinPlugin_val_pdpikadd8_6[8];
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_40 = 1'b1;
  assign _zz_execute_BranchPlugin_branch_src2_6 = execute_INSTRUCTION[31];
  assign _zz_execute_BranchPlugin_branch_src2_7 = execute_INSTRUCTION[31];
  assign _zz_execute_BranchPlugin_branch_src2_8 = execute_INSTRUCTION[7];
  assign _zz_RegFileOddEvenPlugin_regFileEven_port0 = RegFileOddEvenPlugin_regFileEven[_zz_decode_RegFileOddEvenPlugin_rs1Data];
  assign _zz_RegFileOddEvenPlugin_regFileEven_port1 = RegFileOddEvenPlugin_regFileEven[_zz_decode_RegFileOddEvenPlugin_rs2Data];
  assign _zz_RegFileOddEvenPlugin_regFileEven_port2 = RegFileOddEvenPlugin_regFileEven[_zz_decode_RegFileOddEvenPlugin_rs3Data];
  always @(posedge clk) begin
    if(_zz_2) begin
      RegFileOddEvenPlugin_regFileEven[lastStageRegFileWrite_payload_address] <= lastStageRegFileWrite_payload_data;
    end
  end

  assign _zz_RegFileOddEvenPlugin_regFileOdd_port0 = RegFileOddEvenPlugin_regFileOdd[_zz_decode_RegFileOddEvenPlugin_rs1Data_1];
  assign _zz_RegFileOddEvenPlugin_regFileOdd_port1 = RegFileOddEvenPlugin_regFileOdd[_zz_decode_RegFileOddEvenPlugin_rs2Data_1];
  assign _zz_RegFileOddEvenPlugin_regFileOdd_port2 = RegFileOddEvenPlugin_regFileOdd[_zz_decode_RegFileOddEvenPlugin_rs3Data_1];
  always @(posedge clk) begin
    if(_zz_1) begin
      RegFileOddEvenPlugin_regFileOdd[lastStageRegFileWrite_payload_address_1] <= lastStageRegFileWrite_payload_data_1;
    end
  end

  InstructionCache IBusCachedPlugin_cache (
    .io_flush                              (IBusCachedPlugin_cache_io_flush                           ), //i
    .io_cpu_prefetch_isValid               (IBusCachedPlugin_cache_io_cpu_prefetch_isValid            ), //i
    .io_cpu_prefetch_haltIt                (IBusCachedPlugin_cache_io_cpu_prefetch_haltIt             ), //o
    .io_cpu_prefetch_pc                    (IBusCachedPlugin_iBusRsp_stages_0_input_payload[31:0]     ), //i
    .io_cpu_fetch_isValid                  (IBusCachedPlugin_cache_io_cpu_fetch_isValid               ), //i
    .io_cpu_fetch_isStuck                  (IBusCachedPlugin_cache_io_cpu_fetch_isStuck               ), //i
    .io_cpu_fetch_isRemoved                (IBusCachedPlugin_cache_io_cpu_fetch_isRemoved             ), //i
    .io_cpu_fetch_pc                       (IBusCachedPlugin_iBusRsp_stages_1_input_payload[31:0]     ), //i
    .io_cpu_fetch_data                     (IBusCachedPlugin_cache_io_cpu_fetch_data[31:0]            ), //o
    .io_cpu_fetch_mmuRsp_physicalAddress   (IBusCachedPlugin_mmuBus_rsp_physicalAddress[31:0]         ), //i
    .io_cpu_fetch_mmuRsp_isIoAccess        (IBusCachedPlugin_mmuBus_rsp_isIoAccess                    ), //i
    .io_cpu_fetch_mmuRsp_isPaging          (IBusCachedPlugin_mmuBus_rsp_isPaging                      ), //i
    .io_cpu_fetch_mmuRsp_allowRead         (IBusCachedPlugin_mmuBus_rsp_allowRead                     ), //i
    .io_cpu_fetch_mmuRsp_allowWrite        (IBusCachedPlugin_mmuBus_rsp_allowWrite                    ), //i
    .io_cpu_fetch_mmuRsp_allowExecute      (IBusCachedPlugin_mmuBus_rsp_allowExecute                  ), //i
    .io_cpu_fetch_mmuRsp_exception         (IBusCachedPlugin_mmuBus_rsp_exception                     ), //i
    .io_cpu_fetch_mmuRsp_refilling         (IBusCachedPlugin_mmuBus_rsp_refilling                     ), //i
    .io_cpu_fetch_mmuRsp_bypassTranslation (IBusCachedPlugin_mmuBus_rsp_bypassTranslation             ), //i
    .io_cpu_fetch_physicalAddress          (IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress[31:0] ), //o
    .io_cpu_decode_isValid                 (IBusCachedPlugin_cache_io_cpu_decode_isValid              ), //i
    .io_cpu_decode_isStuck                 (IBusCachedPlugin_cache_io_cpu_decode_isStuck              ), //i
    .io_cpu_decode_pc                      (IBusCachedPlugin_iBusRsp_stages_2_input_payload[31:0]     ), //i
    .io_cpu_decode_physicalAddress         (IBusCachedPlugin_cache_io_cpu_decode_physicalAddress[31:0]), //o
    .io_cpu_decode_data                    (IBusCachedPlugin_cache_io_cpu_decode_data[31:0]           ), //o
    .io_cpu_decode_cacheMiss               (IBusCachedPlugin_cache_io_cpu_decode_cacheMiss            ), //o
    .io_cpu_decode_error                   (IBusCachedPlugin_cache_io_cpu_decode_error                ), //o
    .io_cpu_decode_mmuRefilling            (IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling         ), //o
    .io_cpu_decode_mmuException            (IBusCachedPlugin_cache_io_cpu_decode_mmuException         ), //o
    .io_cpu_decode_isUser                  (1'b0                                                      ), //i
    .io_cpu_fill_valid                     (IBusCachedPlugin_cache_io_cpu_fill_valid                  ), //i
    .io_cpu_fill_payload                   (IBusCachedPlugin_cache_io_cpu_decode_physicalAddress[31:0]), //i
    .io_mem_cmd_valid                      (IBusCachedPlugin_cache_io_mem_cmd_valid                   ), //o
    .io_mem_cmd_ready                      (iBus_cmd_ready                                            ), //i
    .io_mem_cmd_payload_address            (IBusCachedPlugin_cache_io_mem_cmd_payload_address[31:0]   ), //o
    .io_mem_cmd_payload_size               (IBusCachedPlugin_cache_io_mem_cmd_payload_size[2:0]       ), //o
    .io_mem_rsp_valid                      (iBus_rsp_valid                                            ), //i
    .io_mem_rsp_payload_data               (iBus_rsp_payload_data[31:0]                               ), //i
    .io_mem_rsp_payload_error              (iBus_rsp_payload_error                                    ), //i
    .clk                                   (clk                                                       ), //i
    .reset                                 (reset                                                     )  //i
  );
  DataCache dataCache_1 (
    .io_cpu_execute_isValid                 (dataCache_1_io_cpu_execute_isValid               ), //i
    .io_cpu_execute_address                 (dataCache_1_io_cpu_execute_address[31:0]         ), //i
    .io_cpu_execute_haltIt                  (dataCache_1_io_cpu_execute_haltIt                ), //o
    .io_cpu_execute_args_wr                 (execute_MEMORY_WR                                ), //i
    .io_cpu_execute_args_size               (dataCache_1_io_cpu_execute_args_size[2:0]        ), //i
    .io_cpu_execute_args_totalyConsistent   (execute_MEMORY_FORCE_CONSTISTENCY                ), //i
    .io_cpu_execute_refilling               (dataCache_1_io_cpu_execute_refilling             ), //o
    .io_cpu_memory_isValid                  (dataCache_1_io_cpu_memory_isValid                ), //i
    .io_cpu_memory_isStuck                  (memory_arbitration_isStuck                       ), //i
    .io_cpu_memory_isWrite                  (dataCache_1_io_cpu_memory_isWrite                ), //o
    .io_cpu_memory_address                  (dataCache_1_io_cpu_memory_address[31:0]          ), //i
    .io_cpu_memory_mmuRsp_physicalAddress   (DBusCachedPlugin_mmuBus_rsp_physicalAddress[31:0]), //i
    .io_cpu_memory_mmuRsp_isIoAccess        (dataCache_1_io_cpu_memory_mmuRsp_isIoAccess      ), //i
    .io_cpu_memory_mmuRsp_isPaging          (DBusCachedPlugin_mmuBus_rsp_isPaging             ), //i
    .io_cpu_memory_mmuRsp_allowRead         (DBusCachedPlugin_mmuBus_rsp_allowRead            ), //i
    .io_cpu_memory_mmuRsp_allowWrite        (DBusCachedPlugin_mmuBus_rsp_allowWrite           ), //i
    .io_cpu_memory_mmuRsp_allowExecute      (DBusCachedPlugin_mmuBus_rsp_allowExecute         ), //i
    .io_cpu_memory_mmuRsp_exception         (DBusCachedPlugin_mmuBus_rsp_exception            ), //i
    .io_cpu_memory_mmuRsp_refilling         (DBusCachedPlugin_mmuBus_rsp_refilling            ), //i
    .io_cpu_memory_mmuRsp_bypassTranslation (DBusCachedPlugin_mmuBus_rsp_bypassTranslation    ), //i
    .io_cpu_writeBack_isValid               (dataCache_1_io_cpu_writeBack_isValid             ), //i
    .io_cpu_writeBack_isStuck               (writeBack_arbitration_isStuck                    ), //i
    .io_cpu_writeBack_isFiring              (writeBack_arbitration_isFiring                   ), //i
    .io_cpu_writeBack_isUser                (1'b0                                             ), //i
    .io_cpu_writeBack_haltIt                (dataCache_1_io_cpu_writeBack_haltIt              ), //o
    .io_cpu_writeBack_isWrite               (dataCache_1_io_cpu_writeBack_isWrite             ), //o
    .io_cpu_writeBack_storeData             (dataCache_1_io_cpu_writeBack_storeData[127:0]    ), //i
    .io_cpu_writeBack_data                  (dataCache_1_io_cpu_writeBack_data[127:0]         ), //o
    .io_cpu_writeBack_address               (dataCache_1_io_cpu_writeBack_address[31:0]       ), //i
    .io_cpu_writeBack_mmuException          (dataCache_1_io_cpu_writeBack_mmuException        ), //o
    .io_cpu_writeBack_unalignedAccess       (dataCache_1_io_cpu_writeBack_unalignedAccess     ), //o
    .io_cpu_writeBack_accessError           (dataCache_1_io_cpu_writeBack_accessError         ), //o
    .io_cpu_writeBack_keepMemRspData        (dataCache_1_io_cpu_writeBack_keepMemRspData      ), //o
    .io_cpu_writeBack_fence_SW              (dataCache_1_io_cpu_writeBack_fence_SW            ), //i
    .io_cpu_writeBack_fence_SR              (dataCache_1_io_cpu_writeBack_fence_SR            ), //i
    .io_cpu_writeBack_fence_SO              (dataCache_1_io_cpu_writeBack_fence_SO            ), //i
    .io_cpu_writeBack_fence_SI              (dataCache_1_io_cpu_writeBack_fence_SI            ), //i
    .io_cpu_writeBack_fence_PW              (dataCache_1_io_cpu_writeBack_fence_PW            ), //i
    .io_cpu_writeBack_fence_PR              (dataCache_1_io_cpu_writeBack_fence_PR            ), //i
    .io_cpu_writeBack_fence_PO              (dataCache_1_io_cpu_writeBack_fence_PO            ), //i
    .io_cpu_writeBack_fence_PI              (dataCache_1_io_cpu_writeBack_fence_PI            ), //i
    .io_cpu_writeBack_fence_FM              (dataCache_1_io_cpu_writeBack_fence_FM[3:0]       ), //i
    .io_cpu_writeBack_exclusiveOk           (dataCache_1_io_cpu_writeBack_exclusiveOk         ), //o
    .io_cpu_redo                            (dataCache_1_io_cpu_redo                          ), //o
    .io_cpu_flush_valid                     (dataCache_1_io_cpu_flush_valid                   ), //i
    .io_cpu_flush_ready                     (dataCache_1_io_cpu_flush_ready                   ), //o
    .io_mem_cmd_valid                       (dataCache_1_io_mem_cmd_valid                     ), //o
    .io_mem_cmd_ready                       (dataCache_1_io_mem_cmd_ready                     ), //i
    .io_mem_cmd_payload_wr                  (dataCache_1_io_mem_cmd_payload_wr                ), //o
    .io_mem_cmd_payload_uncached            (dataCache_1_io_mem_cmd_payload_uncached          ), //o
    .io_mem_cmd_payload_address             (dataCache_1_io_mem_cmd_payload_address[31:0]     ), //o
    .io_mem_cmd_payload_data                (dataCache_1_io_mem_cmd_payload_data[127:0]       ), //o
    .io_mem_cmd_payload_mask                (dataCache_1_io_mem_cmd_payload_mask[15:0]        ), //o
    .io_mem_cmd_payload_size                (dataCache_1_io_mem_cmd_payload_size[2:0]         ), //o
    .io_mem_cmd_payload_last                (dataCache_1_io_mem_cmd_payload_last              ), //o
    .io_mem_rsp_valid                       (dBus_rsp_regNext_valid                           ), //i
    .io_mem_rsp_payload_aggregated          (dBus_rsp_regNext_payload_aggregated[4:0]         ), //i
    .io_mem_rsp_payload_last                (dBus_rsp_regNext_payload_last                    ), //i
    .io_mem_rsp_payload_data                (dBus_rsp_regNext_payload_data[127:0]             ), //i
    .io_mem_rsp_payload_error               (dBus_rsp_regNext_payload_error                   ), //i
    .clk                                    (clk                                              ), //i
    .reset                                  (reset                                            )  //i
  );
  always @(*) begin
    case(_zz_IBusCachedPlugin_jump_pcLoad_payload_5)
      2'b00 : _zz_IBusCachedPlugin_jump_pcLoad_payload_4 = DBusCachedPlugin_redoBranch_payload;
      2'b01 : _zz_IBusCachedPlugin_jump_pcLoad_payload_4 = BranchPlugin_jumpInterface_payload;
      default : _zz_IBusCachedPlugin_jump_pcLoad_payload_4 = IBusCachedPlugin_predictionJumpInterface_payload;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_1)
      4'b0000 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_0;
      4'b0001 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_1;
      4'b0010 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_2;
      4'b0011 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_3;
      4'b0100 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_4;
      4'b0101 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_5;
      4'b0110 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_6;
      4'b0111 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_7;
      4'b1000 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_8;
      4'b1001 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_9;
      4'b1010 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_10;
      4'b1011 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_11;
      4'b1100 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_12;
      4'b1101 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_13;
      4'b1110 : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_14;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_15;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_3)
      3'b000 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_1;
      3'b001 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_3;
      3'b010 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_5;
      3'b011 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_7;
      3'b100 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_9;
      3'b101 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_11;
      3'b110 : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_13;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_15;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_5)
      2'b00 : _zz_writeBack_DBusCachedPlugin_rspShifted_4 = writeBack_DBusCachedPlugin_rspSplits_2;
      2'b01 : _zz_writeBack_DBusCachedPlugin_rspShifted_4 = writeBack_DBusCachedPlugin_rspSplits_6;
      2'b10 : _zz_writeBack_DBusCachedPlugin_rspShifted_4 = writeBack_DBusCachedPlugin_rspSplits_10;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_4 = writeBack_DBusCachedPlugin_rspSplits_14;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_7)
      2'b00 : _zz_writeBack_DBusCachedPlugin_rspShifted_6 = writeBack_DBusCachedPlugin_rspSplits_3;
      2'b01 : _zz_writeBack_DBusCachedPlugin_rspShifted_6 = writeBack_DBusCachedPlugin_rspSplits_7;
      2'b10 : _zz_writeBack_DBusCachedPlugin_rspShifted_6 = writeBack_DBusCachedPlugin_rspSplits_11;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_6 = writeBack_DBusCachedPlugin_rspSplits_15;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_9)
      1'b0 : _zz_writeBack_DBusCachedPlugin_rspShifted_8 = writeBack_DBusCachedPlugin_rspSplits_4;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_8 = writeBack_DBusCachedPlugin_rspSplits_12;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_11)
      1'b0 : _zz_writeBack_DBusCachedPlugin_rspShifted_10 = writeBack_DBusCachedPlugin_rspSplits_5;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_10 = writeBack_DBusCachedPlugin_rspSplits_13;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_13)
      1'b0 : _zz_writeBack_DBusCachedPlugin_rspShifted_12 = writeBack_DBusCachedPlugin_rspSplits_6;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_12 = writeBack_DBusCachedPlugin_rspSplits_14;
    endcase
  end

  always @(*) begin
    case(_zz_writeBack_DBusCachedPlugin_rspShifted_15)
      1'b0 : _zz_writeBack_DBusCachedPlugin_rspShifted_14 = writeBack_DBusCachedPlugin_rspSplits_7;
      default : _zz_writeBack_DBusCachedPlugin_rspShifted_14 = writeBack_DBusCachedPlugin_rspSplits_15;
    endcase
  end

  `ifndef SYNTHESIS
  always @(*) begin
    case(_zz_decode_to_execute_BRANCH_CTRL)
      BranchCtrlEnum_INC : _zz_decode_to_execute_BRANCH_CTRL_string = "INC ";
      BranchCtrlEnum_B : _zz_decode_to_execute_BRANCH_CTRL_string = "B   ";
      BranchCtrlEnum_JAL : _zz_decode_to_execute_BRANCH_CTRL_string = "JAL ";
      BranchCtrlEnum_JALR : _zz_decode_to_execute_BRANCH_CTRL_string = "JALR";
      default : _zz_decode_to_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_BRANCH_CTRL_1)
      BranchCtrlEnum_INC : _zz_decode_to_execute_BRANCH_CTRL_1_string = "INC ";
      BranchCtrlEnum_B : _zz_decode_to_execute_BRANCH_CTRL_1_string = "B   ";
      BranchCtrlEnum_JAL : _zz_decode_to_execute_BRANCH_CTRL_1_string = "JAL ";
      BranchCtrlEnum_JALR : _zz_decode_to_execute_BRANCH_CTRL_1_string = "JALR";
      default : _zz_decode_to_execute_BRANCH_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(decode_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : decode_GoblinCtrlpdpikadd8_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : decode_GoblinCtrlpdpikadd8_string = "CTRL_UKSUB8";
      default : decode_GoblinCtrlpdpikadd8_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : _zz_decode_GoblinCtrlpdpikadd8_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : _zz_decode_GoblinCtrlpdpikadd8_string = "CTRL_UKSUB8";
      default : _zz_decode_GoblinCtrlpdpikadd8_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : _zz_decode_to_execute_GoblinCtrlpdpikadd8_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : _zz_decode_to_execute_GoblinCtrlpdpikadd8_string = "CTRL_UKSUB8";
      default : _zz_decode_to_execute_GoblinCtrlpdpikadd8_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_GoblinCtrlpdpikadd8_1)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : _zz_decode_to_execute_GoblinCtrlpdpikadd8_1_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : _zz_decode_to_execute_GoblinCtrlpdpikadd8_1_string = "CTRL_UKSUB8";
      default : _zz_decode_to_execute_GoblinCtrlpdpikadd8_1_string = "???????????";
    endcase
  end
  always @(*) begin
    case(decode_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : decode_CG6Ctrlternary_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : decode_CG6Ctrlternary_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : decode_CG6Ctrlternary_string = "CTRL_FSR ";
      default : decode_CG6Ctrlternary_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : _zz_decode_CG6Ctrlternary_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : _zz_decode_CG6Ctrlternary_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : _zz_decode_CG6Ctrlternary_string = "CTRL_FSR ";
      default : _zz_decode_CG6Ctrlternary_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : _zz_decode_to_execute_CG6Ctrlternary_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : _zz_decode_to_execute_CG6Ctrlternary_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : _zz_decode_to_execute_CG6Ctrlternary_string = "CTRL_FSR ";
      default : _zz_decode_to_execute_CG6Ctrlternary_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrlternary_1)
      CG6CtrlternaryEnum_CTRL_CMIX : _zz_decode_to_execute_CG6Ctrlternary_1_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : _zz_decode_to_execute_CG6Ctrlternary_1_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : _zz_decode_to_execute_CG6Ctrlternary_1_string = "CTRL_FSR ";
      default : _zz_decode_to_execute_CG6Ctrlternary_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : decode_CG6Ctrlsignextend_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : decode_CG6Ctrlsignextend_string = "CTRL_ZEXTdotH";
      default : decode_CG6Ctrlsignextend_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : _zz_decode_CG6Ctrlsignextend_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : _zz_decode_CG6Ctrlsignextend_string = "CTRL_ZEXTdotH";
      default : _zz_decode_CG6Ctrlsignextend_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : _zz_decode_to_execute_CG6Ctrlsignextend_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : _zz_decode_to_execute_CG6Ctrlsignextend_string = "CTRL_ZEXTdotH";
      default : _zz_decode_to_execute_CG6Ctrlsignextend_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrlsignextend_1)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : _zz_decode_to_execute_CG6Ctrlsignextend_1_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : _zz_decode_to_execute_CG6Ctrlsignextend_1_string = "CTRL_ZEXTdotH";
      default : _zz_decode_to_execute_CG6Ctrlsignextend_1_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(decode_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : decode_CG6Ctrlminmax_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : decode_CG6Ctrlminmax_string = "CTRL_MINU";
      default : decode_CG6Ctrlminmax_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : _zz_decode_CG6Ctrlminmax_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : _zz_decode_CG6Ctrlminmax_string = "CTRL_MINU";
      default : _zz_decode_CG6Ctrlminmax_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : _zz_decode_to_execute_CG6Ctrlminmax_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : _zz_decode_to_execute_CG6Ctrlminmax_string = "CTRL_MINU";
      default : _zz_decode_to_execute_CG6Ctrlminmax_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrlminmax_1)
      CG6CtrlminmaxEnum_CTRL_MAXU : _zz_decode_to_execute_CG6Ctrlminmax_1_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : _zz_decode_to_execute_CG6Ctrlminmax_1_string = "CTRL_MINU";
      default : _zz_decode_to_execute_CG6Ctrlminmax_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : decode_CG6Ctrl_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : decode_CG6Ctrl_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : decode_CG6Ctrl_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : decode_CG6Ctrl_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : decode_CG6Ctrl_string = "CTRL_REV8      ";
      default : decode_CG6Ctrl_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : _zz_decode_CG6Ctrl_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : _zz_decode_CG6Ctrl_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : _zz_decode_CG6Ctrl_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : _zz_decode_CG6Ctrl_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : _zz_decode_CG6Ctrl_string = "CTRL_REV8      ";
      default : _zz_decode_CG6Ctrl_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : _zz_decode_to_execute_CG6Ctrl_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : _zz_decode_to_execute_CG6Ctrl_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : _zz_decode_to_execute_CG6Ctrl_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : _zz_decode_to_execute_CG6Ctrl_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : _zz_decode_to_execute_CG6Ctrl_string = "CTRL_REV8      ";
      default : _zz_decode_to_execute_CG6Ctrl_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_CG6Ctrl_1)
      CG6CtrlEnum_CTRL_SH2ADD : _zz_decode_to_execute_CG6Ctrl_1_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : _zz_decode_to_execute_CG6Ctrl_1_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : _zz_decode_to_execute_CG6Ctrl_1_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : _zz_decode_to_execute_CG6Ctrl_1_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : _zz_decode_to_execute_CG6Ctrl_1_string = "CTRL_REV8      ";
      default : _zz_decode_to_execute_CG6Ctrl_1_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_to_memory_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_execute_to_memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_to_memory_SHIFT_CTRL_1)
      ShiftCtrlEnum_DISABLE_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRA_1    ";
      default : _zz_execute_to_memory_SHIFT_CTRL_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : decode_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : decode_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : decode_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : decode_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : _zz_decode_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_decode_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_decode_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_decode_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_decode_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_decode_to_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SHIFT_CTRL_1)
      ShiftCtrlEnum_DISABLE_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRA_1    ";
      default : _zz_decode_to_execute_SHIFT_CTRL_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_XOR_1 : decode_ALU_BITWISE_CTRL_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : decode_ALU_BITWISE_CTRL_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : decode_ALU_BITWISE_CTRL_string = "AND_1";
      default : decode_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_XOR_1 : _zz_decode_ALU_BITWISE_CTRL_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : _zz_decode_ALU_BITWISE_CTRL_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : _zz_decode_ALU_BITWISE_CTRL_string = "AND_1";
      default : _zz_decode_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_XOR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_BITWISE_CTRL_1)
      AluBitwiseCtrlEnum_XOR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "AND_1";
      default : _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_SRC3_CTRL)
      Src3CtrlEnum_RS : decode_SRC3_CTRL_string = "RS ";
      Src3CtrlEnum_IMI : decode_SRC3_CTRL_string = "IMI";
      default : decode_SRC3_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC3_CTRL)
      Src3CtrlEnum_RS : _zz_decode_SRC3_CTRL_string = "RS ";
      Src3CtrlEnum_IMI : _zz_decode_SRC3_CTRL_string = "IMI";
      default : _zz_decode_SRC3_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC3_CTRL)
      Src3CtrlEnum_RS : _zz_decode_to_execute_SRC3_CTRL_string = "RS ";
      Src3CtrlEnum_IMI : _zz_decode_to_execute_SRC3_CTRL_string = "IMI";
      default : _zz_decode_to_execute_SRC3_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC3_CTRL_1)
      Src3CtrlEnum_RS : _zz_decode_to_execute_SRC3_CTRL_1_string = "RS ";
      Src3CtrlEnum_IMI : _zz_decode_to_execute_SRC3_CTRL_1_string = "IMI";
      default : _zz_decode_to_execute_SRC3_CTRL_1_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_SRC2_CTRL)
      Src2CtrlEnum_RS : decode_SRC2_CTRL_string = "RS ";
      Src2CtrlEnum_IMI : decode_SRC2_CTRL_string = "IMI";
      Src2CtrlEnum_IMS : decode_SRC2_CTRL_string = "IMS";
      Src2CtrlEnum_PC : decode_SRC2_CTRL_string = "PC ";
      default : decode_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC2_CTRL)
      Src2CtrlEnum_RS : _zz_decode_SRC2_CTRL_string = "RS ";
      Src2CtrlEnum_IMI : _zz_decode_SRC2_CTRL_string = "IMI";
      Src2CtrlEnum_IMS : _zz_decode_SRC2_CTRL_string = "IMS";
      Src2CtrlEnum_PC : _zz_decode_SRC2_CTRL_string = "PC ";
      default : _zz_decode_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC2_CTRL)
      Src2CtrlEnum_RS : _zz_decode_to_execute_SRC2_CTRL_string = "RS ";
      Src2CtrlEnum_IMI : _zz_decode_to_execute_SRC2_CTRL_string = "IMI";
      Src2CtrlEnum_IMS : _zz_decode_to_execute_SRC2_CTRL_string = "IMS";
      Src2CtrlEnum_PC : _zz_decode_to_execute_SRC2_CTRL_string = "PC ";
      default : _zz_decode_to_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC2_CTRL_1)
      Src2CtrlEnum_RS : _zz_decode_to_execute_SRC2_CTRL_1_string = "RS ";
      Src2CtrlEnum_IMI : _zz_decode_to_execute_SRC2_CTRL_1_string = "IMI";
      Src2CtrlEnum_IMS : _zz_decode_to_execute_SRC2_CTRL_1_string = "IMS";
      Src2CtrlEnum_PC : _zz_decode_to_execute_SRC2_CTRL_1_string = "PC ";
      default : _zz_decode_to_execute_SRC2_CTRL_1_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_ALU_CTRL)
      AluCtrlEnum_ADD_SUB : decode_ALU_CTRL_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : decode_ALU_CTRL_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : decode_ALU_CTRL_string = "BITWISE ";
      default : decode_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_CTRL)
      AluCtrlEnum_ADD_SUB : _zz_decode_ALU_CTRL_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : _zz_decode_ALU_CTRL_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : _zz_decode_ALU_CTRL_string = "BITWISE ";
      default : _zz_decode_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_CTRL)
      AluCtrlEnum_ADD_SUB : _zz_decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : _zz_decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : _zz_decode_to_execute_ALU_CTRL_string = "BITWISE ";
      default : _zz_decode_to_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_ALU_CTRL_1)
      AluCtrlEnum_ADD_SUB : _zz_decode_to_execute_ALU_CTRL_1_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : _zz_decode_to_execute_ALU_CTRL_1_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : _zz_decode_to_execute_ALU_CTRL_1_string = "BITWISE ";
      default : _zz_decode_to_execute_ALU_CTRL_1_string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_SRC1_CTRL)
      Src1CtrlEnum_RS : decode_SRC1_CTRL_string = "RS          ";
      Src1CtrlEnum_IMU : decode_SRC1_CTRL_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : decode_SRC1_CTRL_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : decode_SRC1_CTRL_string = "URS1        ";
      default : decode_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC1_CTRL)
      Src1CtrlEnum_RS : _zz_decode_SRC1_CTRL_string = "RS          ";
      Src1CtrlEnum_IMU : _zz_decode_SRC1_CTRL_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : _zz_decode_SRC1_CTRL_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : _zz_decode_SRC1_CTRL_string = "URS1        ";
      default : _zz_decode_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC1_CTRL)
      Src1CtrlEnum_RS : _zz_decode_to_execute_SRC1_CTRL_string = "RS          ";
      Src1CtrlEnum_IMU : _zz_decode_to_execute_SRC1_CTRL_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : _zz_decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : _zz_decode_to_execute_SRC1_CTRL_string = "URS1        ";
      default : _zz_decode_to_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_to_execute_SRC1_CTRL_1)
      Src1CtrlEnum_RS : _zz_decode_to_execute_SRC1_CTRL_1_string = "RS          ";
      Src1CtrlEnum_IMU : _zz_decode_to_execute_SRC1_CTRL_1_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : _zz_decode_to_execute_SRC1_CTRL_1_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : _zz_decode_to_execute_SRC1_CTRL_1_string = "URS1        ";
      default : _zz_decode_to_execute_SRC1_CTRL_1_string = "????????????";
    endcase
  end
  always @(*) begin
    case(execute_BRANCH_CTRL)
      BranchCtrlEnum_INC : execute_BRANCH_CTRL_string = "INC ";
      BranchCtrlEnum_B : execute_BRANCH_CTRL_string = "B   ";
      BranchCtrlEnum_JAL : execute_BRANCH_CTRL_string = "JAL ";
      BranchCtrlEnum_JALR : execute_BRANCH_CTRL_string = "JALR";
      default : execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_BRANCH_CTRL)
      BranchCtrlEnum_INC : _zz_execute_BRANCH_CTRL_string = "INC ";
      BranchCtrlEnum_B : _zz_execute_BRANCH_CTRL_string = "B   ";
      BranchCtrlEnum_JAL : _zz_execute_BRANCH_CTRL_string = "JAL ";
      BranchCtrlEnum_JALR : _zz_execute_BRANCH_CTRL_string = "JALR";
      default : _zz_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(execute_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : execute_GoblinCtrlpdpikadd8_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : execute_GoblinCtrlpdpikadd8_string = "CTRL_UKSUB8";
      default : execute_GoblinCtrlpdpikadd8_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : _zz_execute_GoblinCtrlpdpikadd8_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : _zz_execute_GoblinCtrlpdpikadd8_string = "CTRL_UKSUB8";
      default : _zz_execute_GoblinCtrlpdpikadd8_string = "???????????";
    endcase
  end
  always @(*) begin
    case(execute_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : execute_CG6Ctrl_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : execute_CG6Ctrl_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : execute_CG6Ctrl_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : execute_CG6Ctrl_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : execute_CG6Ctrl_string = "CTRL_REV8      ";
      default : execute_CG6Ctrl_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : _zz_execute_CG6Ctrl_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : _zz_execute_CG6Ctrl_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : _zz_execute_CG6Ctrl_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : _zz_execute_CG6Ctrl_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : _zz_execute_CG6Ctrl_string = "CTRL_REV8      ";
      default : _zz_execute_CG6Ctrl_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(execute_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : execute_CG6Ctrlternary_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : execute_CG6Ctrlternary_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : execute_CG6Ctrlternary_string = "CTRL_FSR ";
      default : execute_CG6Ctrlternary_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : _zz_execute_CG6Ctrlternary_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : _zz_execute_CG6Ctrlternary_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : _zz_execute_CG6Ctrlternary_string = "CTRL_FSR ";
      default : _zz_execute_CG6Ctrlternary_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : execute_CG6Ctrlsignextend_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : execute_CG6Ctrlsignextend_string = "CTRL_ZEXTdotH";
      default : execute_CG6Ctrlsignextend_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : _zz_execute_CG6Ctrlsignextend_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : _zz_execute_CG6Ctrlsignextend_string = "CTRL_ZEXTdotH";
      default : _zz_execute_CG6Ctrlsignextend_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(execute_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : execute_CG6Ctrlminmax_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : execute_CG6Ctrlminmax_string = "CTRL_MINU";
      default : execute_CG6Ctrlminmax_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : _zz_execute_CG6Ctrlminmax_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : _zz_execute_CG6Ctrlminmax_string = "CTRL_MINU";
      default : _zz_execute_CG6Ctrlminmax_string = "?????????";
    endcase
  end
  always @(*) begin
    case(memory_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : memory_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : memory_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : memory_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : memory_SHIFT_CTRL_string = "SRA_1    ";
      default : memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_memory_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : _zz_memory_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_memory_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_memory_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_memory_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : execute_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : execute_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : execute_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : execute_SHIFT_CTRL_string = "SRA_1    ";
      default : execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : _zz_execute_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_execute_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_execute_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : _zz_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_SRC3_CTRL)
      Src3CtrlEnum_RS : execute_SRC3_CTRL_string = "RS ";
      Src3CtrlEnum_IMI : execute_SRC3_CTRL_string = "IMI";
      default : execute_SRC3_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SRC3_CTRL)
      Src3CtrlEnum_RS : _zz_execute_SRC3_CTRL_string = "RS ";
      Src3CtrlEnum_IMI : _zz_execute_SRC3_CTRL_string = "IMI";
      default : _zz_execute_SRC3_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(execute_SRC2_CTRL)
      Src2CtrlEnum_RS : execute_SRC2_CTRL_string = "RS ";
      Src2CtrlEnum_IMI : execute_SRC2_CTRL_string = "IMI";
      Src2CtrlEnum_IMS : execute_SRC2_CTRL_string = "IMS";
      Src2CtrlEnum_PC : execute_SRC2_CTRL_string = "PC ";
      default : execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SRC2_CTRL)
      Src2CtrlEnum_RS : _zz_execute_SRC2_CTRL_string = "RS ";
      Src2CtrlEnum_IMI : _zz_execute_SRC2_CTRL_string = "IMI";
      Src2CtrlEnum_IMS : _zz_execute_SRC2_CTRL_string = "IMS";
      Src2CtrlEnum_PC : _zz_execute_SRC2_CTRL_string = "PC ";
      default : _zz_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(execute_SRC1_CTRL)
      Src1CtrlEnum_RS : execute_SRC1_CTRL_string = "RS          ";
      Src1CtrlEnum_IMU : execute_SRC1_CTRL_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : execute_SRC1_CTRL_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : execute_SRC1_CTRL_string = "URS1        ";
      default : execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_SRC1_CTRL)
      Src1CtrlEnum_RS : _zz_execute_SRC1_CTRL_string = "RS          ";
      Src1CtrlEnum_IMU : _zz_execute_SRC1_CTRL_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : _zz_execute_SRC1_CTRL_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : _zz_execute_SRC1_CTRL_string = "URS1        ";
      default : _zz_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(execute_ALU_CTRL)
      AluCtrlEnum_ADD_SUB : execute_ALU_CTRL_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : execute_ALU_CTRL_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : execute_ALU_CTRL_string = "BITWISE ";
      default : execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_ALU_CTRL)
      AluCtrlEnum_ADD_SUB : _zz_execute_ALU_CTRL_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : _zz_execute_ALU_CTRL_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : _zz_execute_ALU_CTRL_string = "BITWISE ";
      default : _zz_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(execute_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_XOR_1 : execute_ALU_BITWISE_CTRL_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_execute_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_XOR_1 : _zz_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : _zz_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : _zz_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : _zz_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_BRANCH_CTRL)
      BranchCtrlEnum_INC : _zz_decode_BRANCH_CTRL_string = "INC ";
      BranchCtrlEnum_B : _zz_decode_BRANCH_CTRL_string = "B   ";
      BranchCtrlEnum_JAL : _zz_decode_BRANCH_CTRL_string = "JAL ";
      BranchCtrlEnum_JALR : _zz_decode_BRANCH_CTRL_string = "JALR";
      default : _zz_decode_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_GoblinCtrlpdpikadd8_1)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : _zz_decode_GoblinCtrlpdpikadd8_1_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : _zz_decode_GoblinCtrlpdpikadd8_1_string = "CTRL_UKSUB8";
      default : _zz_decode_GoblinCtrlpdpikadd8_1_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlternary_1)
      CG6CtrlternaryEnum_CTRL_CMIX : _zz_decode_CG6Ctrlternary_1_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : _zz_decode_CG6Ctrlternary_1_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : _zz_decode_CG6Ctrlternary_1_string = "CTRL_FSR ";
      default : _zz_decode_CG6Ctrlternary_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlsignextend_1)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : _zz_decode_CG6Ctrlsignextend_1_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : _zz_decode_CG6Ctrlsignextend_1_string = "CTRL_ZEXTdotH";
      default : _zz_decode_CG6Ctrlsignextend_1_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlminmax_1)
      CG6CtrlminmaxEnum_CTRL_MAXU : _zz_decode_CG6Ctrlminmax_1_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : _zz_decode_CG6Ctrlminmax_1_string = "CTRL_MINU";
      default : _zz_decode_CG6Ctrlminmax_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrl_1)
      CG6CtrlEnum_CTRL_SH2ADD : _zz_decode_CG6Ctrl_1_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : _zz_decode_CG6Ctrl_1_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : _zz_decode_CG6Ctrl_1_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : _zz_decode_CG6Ctrl_1_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : _zz_decode_CG6Ctrl_1_string = "CTRL_REV8      ";
      default : _zz_decode_CG6Ctrl_1_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SHIFT_CTRL_1)
      ShiftCtrlEnum_DISABLE_1 : _zz_decode_SHIFT_CTRL_1_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_decode_SHIFT_CTRL_1_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_decode_SHIFT_CTRL_1_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_decode_SHIFT_CTRL_1_string = "SRA_1    ";
      default : _zz_decode_SHIFT_CTRL_1_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_BITWISE_CTRL_1)
      AluBitwiseCtrlEnum_XOR_1 : _zz_decode_ALU_BITWISE_CTRL_1_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : _zz_decode_ALU_BITWISE_CTRL_1_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : _zz_decode_ALU_BITWISE_CTRL_1_string = "AND_1";
      default : _zz_decode_ALU_BITWISE_CTRL_1_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC3_CTRL_1)
      Src3CtrlEnum_RS : _zz_decode_SRC3_CTRL_1_string = "RS ";
      Src3CtrlEnum_IMI : _zz_decode_SRC3_CTRL_1_string = "IMI";
      default : _zz_decode_SRC3_CTRL_1_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC2_CTRL_1)
      Src2CtrlEnum_RS : _zz_decode_SRC2_CTRL_1_string = "RS ";
      Src2CtrlEnum_IMI : _zz_decode_SRC2_CTRL_1_string = "IMI";
      Src2CtrlEnum_IMS : _zz_decode_SRC2_CTRL_1_string = "IMS";
      Src2CtrlEnum_PC : _zz_decode_SRC2_CTRL_1_string = "PC ";
      default : _zz_decode_SRC2_CTRL_1_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_CTRL_1)
      AluCtrlEnum_ADD_SUB : _zz_decode_ALU_CTRL_1_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : _zz_decode_ALU_CTRL_1_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : _zz_decode_ALU_CTRL_1_string = "BITWISE ";
      default : _zz_decode_ALU_CTRL_1_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC1_CTRL_1)
      Src1CtrlEnum_RS : _zz_decode_SRC1_CTRL_1_string = "RS          ";
      Src1CtrlEnum_IMU : _zz_decode_SRC1_CTRL_1_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : _zz_decode_SRC1_CTRL_1_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : _zz_decode_SRC1_CTRL_1_string = "URS1        ";
      default : _zz_decode_SRC1_CTRL_1_string = "????????????";
    endcase
  end
  always @(*) begin
    case(decode_BRANCH_CTRL)
      BranchCtrlEnum_INC : decode_BRANCH_CTRL_string = "INC ";
      BranchCtrlEnum_B : decode_BRANCH_CTRL_string = "B   ";
      BranchCtrlEnum_JAL : decode_BRANCH_CTRL_string = "JAL ";
      BranchCtrlEnum_JALR : decode_BRANCH_CTRL_string = "JALR";
      default : decode_BRANCH_CTRL_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_BRANCH_CTRL_1)
      BranchCtrlEnum_INC : _zz_decode_BRANCH_CTRL_1_string = "INC ";
      BranchCtrlEnum_B : _zz_decode_BRANCH_CTRL_1_string = "B   ";
      BranchCtrlEnum_JAL : _zz_decode_BRANCH_CTRL_1_string = "JAL ";
      BranchCtrlEnum_JALR : _zz_decode_BRANCH_CTRL_1_string = "JALR";
      default : _zz_decode_BRANCH_CTRL_1_string = "????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC1_CTRL_2)
      Src1CtrlEnum_RS : _zz_decode_SRC1_CTRL_2_string = "RS          ";
      Src1CtrlEnum_IMU : _zz_decode_SRC1_CTRL_2_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : _zz_decode_SRC1_CTRL_2_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : _zz_decode_SRC1_CTRL_2_string = "URS1        ";
      default : _zz_decode_SRC1_CTRL_2_string = "????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_CTRL_2)
      AluCtrlEnum_ADD_SUB : _zz_decode_ALU_CTRL_2_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : _zz_decode_ALU_CTRL_2_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : _zz_decode_ALU_CTRL_2_string = "BITWISE ";
      default : _zz_decode_ALU_CTRL_2_string = "????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC2_CTRL_2)
      Src2CtrlEnum_RS : _zz_decode_SRC2_CTRL_2_string = "RS ";
      Src2CtrlEnum_IMI : _zz_decode_SRC2_CTRL_2_string = "IMI";
      Src2CtrlEnum_IMS : _zz_decode_SRC2_CTRL_2_string = "IMS";
      Src2CtrlEnum_PC : _zz_decode_SRC2_CTRL_2_string = "PC ";
      default : _zz_decode_SRC2_CTRL_2_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SRC3_CTRL_2)
      Src3CtrlEnum_RS : _zz_decode_SRC3_CTRL_2_string = "RS ";
      Src3CtrlEnum_IMI : _zz_decode_SRC3_CTRL_2_string = "IMI";
      default : _zz_decode_SRC3_CTRL_2_string = "???";
    endcase
  end
  always @(*) begin
    case(_zz_decode_ALU_BITWISE_CTRL_2)
      AluBitwiseCtrlEnum_XOR_1 : _zz_decode_ALU_BITWISE_CTRL_2_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : _zz_decode_ALU_BITWISE_CTRL_2_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : _zz_decode_ALU_BITWISE_CTRL_2_string = "AND_1";
      default : _zz_decode_ALU_BITWISE_CTRL_2_string = "?????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_SHIFT_CTRL_2)
      ShiftCtrlEnum_DISABLE_1 : _zz_decode_SHIFT_CTRL_2_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : _zz_decode_SHIFT_CTRL_2_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : _zz_decode_SHIFT_CTRL_2_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : _zz_decode_SHIFT_CTRL_2_string = "SRA_1    ";
      default : _zz_decode_SHIFT_CTRL_2_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrl_2)
      CG6CtrlEnum_CTRL_SH2ADD : _zz_decode_CG6Ctrl_2_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : _zz_decode_CG6Ctrl_2_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : _zz_decode_CG6Ctrl_2_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : _zz_decode_CG6Ctrl_2_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : _zz_decode_CG6Ctrl_2_string = "CTRL_REV8      ";
      default : _zz_decode_CG6Ctrl_2_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlminmax_2)
      CG6CtrlminmaxEnum_CTRL_MAXU : _zz_decode_CG6Ctrlminmax_2_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : _zz_decode_CG6Ctrlminmax_2_string = "CTRL_MINU";
      default : _zz_decode_CG6Ctrlminmax_2_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlsignextend_2)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : _zz_decode_CG6Ctrlsignextend_2_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : _zz_decode_CG6Ctrlsignextend_2_string = "CTRL_ZEXTdotH";
      default : _zz_decode_CG6Ctrlsignextend_2_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_CG6Ctrlternary_2)
      CG6CtrlternaryEnum_CTRL_CMIX : _zz_decode_CG6Ctrlternary_2_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : _zz_decode_CG6Ctrlternary_2_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : _zz_decode_CG6Ctrlternary_2_string = "CTRL_FSR ";
      default : _zz_decode_CG6Ctrlternary_2_string = "?????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_GoblinCtrlpdpikadd8_2)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : _zz_decode_GoblinCtrlpdpikadd8_2_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : _zz_decode_GoblinCtrlpdpikadd8_2_string = "CTRL_UKSUB8";
      default : _zz_decode_GoblinCtrlpdpikadd8_2_string = "???????????";
    endcase
  end
  always @(*) begin
    case(_zz_decode_BRANCH_CTRL_2)
      BranchCtrlEnum_INC : _zz_decode_BRANCH_CTRL_2_string = "INC ";
      BranchCtrlEnum_B : _zz_decode_BRANCH_CTRL_2_string = "B   ";
      BranchCtrlEnum_JAL : _zz_decode_BRANCH_CTRL_2_string = "JAL ";
      BranchCtrlEnum_JALR : _zz_decode_BRANCH_CTRL_2_string = "JALR";
      default : _zz_decode_BRANCH_CTRL_2_string = "????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC1_CTRL)
      Src1CtrlEnum_RS : decode_to_execute_SRC1_CTRL_string = "RS          ";
      Src1CtrlEnum_IMU : decode_to_execute_SRC1_CTRL_string = "IMU         ";
      Src1CtrlEnum_PC_INCREMENT : decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
      Src1CtrlEnum_URS1 : decode_to_execute_SRC1_CTRL_string = "URS1        ";
      default : decode_to_execute_SRC1_CTRL_string = "????????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ALU_CTRL)
      AluCtrlEnum_ADD_SUB : decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
      AluCtrlEnum_SLT_SLTU : decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
      AluCtrlEnum_BITWISE : decode_to_execute_ALU_CTRL_string = "BITWISE ";
      default : decode_to_execute_ALU_CTRL_string = "????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC2_CTRL)
      Src2CtrlEnum_RS : decode_to_execute_SRC2_CTRL_string = "RS ";
      Src2CtrlEnum_IMI : decode_to_execute_SRC2_CTRL_string = "IMI";
      Src2CtrlEnum_IMS : decode_to_execute_SRC2_CTRL_string = "IMS";
      Src2CtrlEnum_PC : decode_to_execute_SRC2_CTRL_string = "PC ";
      default : decode_to_execute_SRC2_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SRC3_CTRL)
      Src3CtrlEnum_RS : decode_to_execute_SRC3_CTRL_string = "RS ";
      Src3CtrlEnum_IMI : decode_to_execute_SRC3_CTRL_string = "IMI";
      default : decode_to_execute_SRC3_CTRL_string = "???";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_XOR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
      AluBitwiseCtrlEnum_OR_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
      AluBitwiseCtrlEnum_AND_1 : decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
      default : decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
      default : decode_to_execute_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(execute_to_memory_SHIFT_CTRL)
      ShiftCtrlEnum_DISABLE_1 : execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
      ShiftCtrlEnum_SLL_1 : execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
      ShiftCtrlEnum_SRL_1 : execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
      ShiftCtrlEnum_SRA_1 : execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
      default : execute_to_memory_SHIFT_CTRL_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : decode_to_execute_CG6Ctrl_string = "CTRL_SH2ADD    ";
      CG6CtrlEnum_CTRL_minmax : decode_to_execute_CG6Ctrl_string = "CTRL_minmax    ";
      CG6CtrlEnum_CTRL_signextend : decode_to_execute_CG6Ctrl_string = "CTRL_signextend";
      CG6CtrlEnum_CTRL_ternary : decode_to_execute_CG6Ctrl_string = "CTRL_ternary   ";
      CG6CtrlEnum_CTRL_REV8 : decode_to_execute_CG6Ctrl_string = "CTRL_REV8      ";
      default : decode_to_execute_CG6Ctrl_string = "???????????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : decode_to_execute_CG6Ctrlminmax_string = "CTRL_MAXU";
      CG6CtrlminmaxEnum_CTRL_MINU : decode_to_execute_CG6Ctrlminmax_string = "CTRL_MINU";
      default : decode_to_execute_CG6Ctrlminmax_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : decode_to_execute_CG6Ctrlsignextend_string = "CTRL_SEXTdotB";
      CG6CtrlsignextendEnum_CTRL_ZEXTdotH : decode_to_execute_CG6Ctrlsignextend_string = "CTRL_ZEXTdotH";
      default : decode_to_execute_CG6Ctrlsignextend_string = "?????????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : decode_to_execute_CG6Ctrlternary_string = "CTRL_CMIX";
      CG6CtrlternaryEnum_CTRL_CMOV : decode_to_execute_CG6Ctrlternary_string = "CTRL_CMOV";
      CG6CtrlternaryEnum_CTRL_FSR : decode_to_execute_CG6Ctrlternary_string = "CTRL_FSR ";
      default : decode_to_execute_CG6Ctrlternary_string = "?????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : decode_to_execute_GoblinCtrlpdpikadd8_string = "CTRL_UKADD8";
      GoblinCtrlpdpikadd8Enum_CTRL_UKSUB8 : decode_to_execute_GoblinCtrlpdpikadd8_string = "CTRL_UKSUB8";
      default : decode_to_execute_GoblinCtrlpdpikadd8_string = "???????????";
    endcase
  end
  always @(*) begin
    case(decode_to_execute_BRANCH_CTRL)
      BranchCtrlEnum_INC : decode_to_execute_BRANCH_CTRL_string = "INC ";
      BranchCtrlEnum_B : decode_to_execute_BRANCH_CTRL_string = "B   ";
      BranchCtrlEnum_JAL : decode_to_execute_BRANCH_CTRL_string = "JAL ";
      BranchCtrlEnum_JALR : decode_to_execute_BRANCH_CTRL_string = "JALR";
      default : decode_to_execute_BRANCH_CTRL_string = "????";
    endcase
  end
  `endif

  assign memory_Goblin2c_FINAL_OUTPUT = {{{_zz_memory_Goblin2c_FINAL_OUTPUT_9,_zz_memory_Goblin2c_FINAL_OUTPUT_11},_zz_memory_Goblin2c_FINAL_OUTPUT_13},_zz_memory_Goblin2c_FINAL_OUTPUT_15};
  assign memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW) + $signed(_zz_memory_MUL_LOW_7));
  assign execute_BRANCH_CALC = {execute_BranchPlugin_branchAdder[31 : 1],1'b0};
  assign execute_BRANCH_DO = ((execute_PREDICTION_HAD_BRANCHED2 != execute_BRANCH_COND_RESULT) || execute_BranchPlugin_missAlignedTarget);
  assign execute_Goblin2c_INTERMEDIATE_UFMA8VxV64 = {{{{execute_SRC3,_zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_1[15 : 8]},_zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_3[15 : 8]},_zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_5[15 : 8]},_zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64_7[15 : 8]};
  assign execute_Goblin_FINAL_OUTPUT = execute_GoblinPlugin_val_pdpikadd8;
  assign execute_CG6_FINAL_OUTPUT = _zz_execute_CG6_FINAL_OUTPUT;
  assign execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT;
  assign memory_MUL_HH = execute_to_memory_MUL_HH;
  assign execute_MUL_HH = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bHigh));
  assign execute_MUL_HL = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bSLow));
  assign execute_MUL_LH = ($signed(execute_MulPlugin_aSLow) * $signed(execute_MulPlugin_bHigh));
  assign execute_MUL_LL = (execute_MulPlugin_aULow * execute_MulPlugin_bULow);
  assign writeBack_REGFILE_WRITE_DATA_ODD = memory_to_writeBack_REGFILE_WRITE_DATA_ODD;
  assign memory_REGFILE_WRITE_DATA_ODD = execute_to_memory_REGFILE_WRITE_DATA_ODD;
  assign execute_REGFILE_WRITE_DATA_ODD = 32'h0;
  assign execute_REGFILE_WRITE_DATA = _zz_execute_REGFILE_WRITE_DATA;
  assign memory_MEMORY_STORE_DATA_RF = execute_to_memory_MEMORY_STORE_DATA_RF;
  assign execute_MEMORY_STORE_DATA_RF = _zz_execute_MEMORY_STORE_DATA_RF;
  assign decode_PREDICTION_HAD_BRANCHED2 = IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  assign decode_SRC2_FORCE_ZERO = (decode_SRC_ADD_ZERO && (! decode_SRC_USE_SUB_LESS));
  assign _zz_decode_to_execute_BRANCH_CTRL = _zz_decode_to_execute_BRANCH_CTRL_1;
  assign memory_IS_Goblin2c = execute_to_memory_IS_Goblin2c;
  assign execute_IS_Goblin2c = decode_to_execute_IS_Goblin2c;
  assign decode_IS_Goblin2c = _zz_decode_IS_Goblin2c[37];
  assign decode_GoblinCtrlpdpikadd8 = _zz_decode_GoblinCtrlpdpikadd8;
  assign _zz_decode_to_execute_GoblinCtrlpdpikadd8 = _zz_decode_to_execute_GoblinCtrlpdpikadd8_1;
  assign execute_IS_Goblin = decode_to_execute_IS_Goblin;
  assign decode_IS_Goblin = _zz_decode_IS_Goblin2c[35];
  assign decode_CG6Ctrlternary = _zz_decode_CG6Ctrlternary;
  assign _zz_decode_to_execute_CG6Ctrlternary = _zz_decode_to_execute_CG6Ctrlternary_1;
  assign decode_CG6Ctrlsignextend = _zz_decode_CG6Ctrlsignextend;
  assign _zz_decode_to_execute_CG6Ctrlsignextend = _zz_decode_to_execute_CG6Ctrlsignextend_1;
  assign decode_CG6Ctrlminmax = _zz_decode_CG6Ctrlminmax;
  assign _zz_decode_to_execute_CG6Ctrlminmax = _zz_decode_to_execute_CG6Ctrlminmax_1;
  assign decode_CG6Ctrl = _zz_decode_CG6Ctrl;
  assign _zz_decode_to_execute_CG6Ctrl = _zz_decode_to_execute_CG6Ctrl_1;
  assign execute_IS_CG6 = decode_to_execute_IS_CG6;
  assign decode_IS_CG6 = _zz_decode_IS_Goblin2c[27];
  assign _zz_execute_to_memory_SHIFT_CTRL = _zz_execute_to_memory_SHIFT_CTRL_1;
  assign decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL;
  assign _zz_decode_to_execute_SHIFT_CTRL = _zz_decode_to_execute_SHIFT_CTRL_1;
  assign memory_IS_MUL = execute_to_memory_IS_MUL;
  assign execute_IS_MUL = decode_to_execute_IS_MUL;
  assign decode_IS_MUL = _zz_decode_IS_Goblin2c[24];
  assign decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL;
  assign _zz_decode_to_execute_ALU_BITWISE_CTRL = _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
  assign decode_SRC_LESS_UNSIGNED = _zz_decode_IS_Goblin2c[20];
  assign decode_MEMORY_MANAGMENT = _zz_decode_IS_Goblin2c[19];
  assign decode_SRC3_CTRL = _zz_decode_SRC3_CTRL;
  assign _zz_decode_to_execute_SRC3_CTRL = _zz_decode_to_execute_SRC3_CTRL_1;
  assign decode_MEMORY_WR = _zz_decode_IS_Goblin2c[13];
  assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  assign decode_BYPASSABLE_MEMORY_STAGE = _zz_decode_IS_Goblin2c[12];
  assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_decode_IS_Goblin2c[11];
  assign decode_SRC2_CTRL = _zz_decode_SRC2_CTRL;
  assign _zz_decode_to_execute_SRC2_CTRL = _zz_decode_to_execute_SRC2_CTRL_1;
  assign decode_ALU_CTRL = _zz_decode_ALU_CTRL;
  assign _zz_decode_to_execute_ALU_CTRL = _zz_decode_to_execute_ALU_CTRL_1;
  assign decode_SRC1_CTRL = _zz_decode_SRC1_CTRL;
  assign _zz_decode_to_execute_SRC1_CTRL = _zz_decode_to_execute_SRC1_CTRL_1;
  assign decode_MEMORY_FORCE_CONSTISTENCY = 1'b0;
  assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
  assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = (decode_PC + 32'h00000004);
  assign memory_PC = execute_to_memory_PC;
  assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
  assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
  assign execute_PC = decode_to_execute_PC;
  assign execute_PREDICTION_HAD_BRANCHED2 = decode_to_execute_PREDICTION_HAD_BRANCHED2;
  assign execute_BRANCH_COND_RESULT = _zz_execute_BRANCH_COND_RESULT_1;
  assign execute_BRANCH_CTRL = _zz_execute_BRANCH_CTRL;
  assign decode_RS3_USE = _zz_decode_IS_Goblin2c[18];
  assign decode_RS2_USE = _zz_decode_IS_Goblin2c[15];
  assign decode_RS1_USE = _zz_decode_IS_Goblin2c[5];
  assign _zz_decode_RS3 = execute_REGFILE_WRITE_DATA_ODD;
  assign execute_REGFILE_WRITE_VALID_ODD = decode_to_execute_REGFILE_WRITE_VALID_ODD;
  assign _zz_decode_RS3_1 = execute_REGFILE_WRITE_DATA;
  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  assign _zz_decode_RS3_2 = memory_REGFILE_WRITE_DATA_ODD;
  assign memory_REGFILE_WRITE_VALID_ODD = execute_to_memory_REGFILE_WRITE_VALID_ODD;
  assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
  assign memory_BYPASSABLE_MEMORY_STAGE = execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
  assign writeBack_REGFILE_WRITE_VALID_ODD = memory_to_writeBack_REGFILE_WRITE_VALID_ODD;
  assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
  always @(*) begin
    decode_RS3 = decode_RegFileOddEvenPlugin_rs3Data;
    if(HazardSimplePlugin_writeBackBuffer_valid) begin
      if(HazardSimplePlugin_addr2Match) begin
        decode_RS3 = HazardSimplePlugin_writeBackBuffer_payload_data;
      end
    end
    if(when_HazardSimplePlugin_l61) begin
      if(when_HazardSimplePlugin_l63) begin
        if(when_HazardSimplePlugin_l70) begin
          decode_RS3 = _zz_decode_RS3_5;
        end
      end
    end
    if(when_HazardSimplePlugin_l76) begin
      if(when_HazardSimplePlugin_l63) begin
        if(when_HazardSimplePlugin_l85) begin
          decode_RS3 = _zz_decode_RS3_4;
        end
      end
    end
    if(when_HazardSimplePlugin_l61_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l70_1) begin
          decode_RS3 = _zz_decode_RS3_3;
        end
      end
    end
    if(when_HazardSimplePlugin_l76_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l85_1) begin
          decode_RS3 = _zz_decode_RS3_2;
        end
      end
    end
    if(when_HazardSimplePlugin_l61_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l70_2) begin
          decode_RS3 = _zz_decode_RS3_1;
        end
      end
    end
    if(when_HazardSimplePlugin_l76_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l85_2) begin
          decode_RS3 = _zz_decode_RS3;
        end
      end
    end
  end

  always @(*) begin
    decode_RS2 = decode_RegFileOddEvenPlugin_rs2Data;
    if(HazardSimplePlugin_writeBackBuffer_valid) begin
      if(HazardSimplePlugin_addr1Match) begin
        decode_RS2 = HazardSimplePlugin_writeBackBuffer_payload_data;
      end
    end
    if(when_HazardSimplePlugin_l61) begin
      if(when_HazardSimplePlugin_l63) begin
        if(when_HazardSimplePlugin_l67) begin
          decode_RS2 = _zz_decode_RS3_5;
        end
      end
    end
    if(when_HazardSimplePlugin_l76) begin
      if(when_HazardSimplePlugin_l63) begin
        if(when_HazardSimplePlugin_l82) begin
          decode_RS2 = _zz_decode_RS3_4;
        end
      end
    end
    if(when_HazardSimplePlugin_l61_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l67_1) begin
          decode_RS2 = _zz_decode_RS3_3;
        end
      end
    end
    if(when_HazardSimplePlugin_l76_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l82_1) begin
          decode_RS2 = _zz_decode_RS3_2;
        end
      end
    end
    if(when_HazardSimplePlugin_l61_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l67_2) begin
          decode_RS2 = _zz_decode_RS3_1;
        end
      end
    end
    if(when_HazardSimplePlugin_l76_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l82_2) begin
          decode_RS2 = _zz_decode_RS3;
        end
      end
    end
  end

  always @(*) begin
    decode_RS1 = decode_RegFileOddEvenPlugin_rs1Data;
    if(HazardSimplePlugin_writeBackBuffer_valid) begin
      if(HazardSimplePlugin_addr0Match) begin
        decode_RS1 = HazardSimplePlugin_writeBackBuffer_payload_data;
      end
    end
    if(when_HazardSimplePlugin_l61) begin
      if(when_HazardSimplePlugin_l63) begin
        if(when_HazardSimplePlugin_l64) begin
          decode_RS1 = _zz_decode_RS3_5;
        end
      end
    end
    if(when_HazardSimplePlugin_l76) begin
      if(when_HazardSimplePlugin_l63) begin
        if(when_HazardSimplePlugin_l79) begin
          decode_RS1 = _zz_decode_RS3_4;
        end
      end
    end
    if(when_HazardSimplePlugin_l61_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l64_1) begin
          decode_RS1 = _zz_decode_RS3_3;
        end
      end
    end
    if(when_HazardSimplePlugin_l76_1) begin
      if(memory_BYPASSABLE_MEMORY_STAGE) begin
        if(when_HazardSimplePlugin_l79_1) begin
          decode_RS1 = _zz_decode_RS3_2;
        end
      end
    end
    if(when_HazardSimplePlugin_l61_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l64_2) begin
          decode_RS1 = _zz_decode_RS3_1;
        end
      end
    end
    if(when_HazardSimplePlugin_l76_2) begin
      if(execute_BYPASSABLE_EXECUTE_STAGE) begin
        if(when_HazardSimplePlugin_l79_2) begin
          decode_RS1 = _zz_decode_RS3;
        end
      end
    end
  end

  assign writeBack_Goblin2c_FINAL_OUTPUT = memory_to_writeBack_Goblin2c_FINAL_OUTPUT;
  assign writeBack_IS_Goblin2c = memory_to_writeBack_IS_Goblin2c;
  assign memory_Goblin2c_INTERMEDIATE_UFMA8VxV64 = execute_to_memory_Goblin2c_INTERMEDIATE_UFMA8VxV64;
  assign memory_Goblin_FINAL_OUTPUT = execute_to_memory_Goblin_FINAL_OUTPUT;
  assign memory_IS_Goblin = execute_to_memory_IS_Goblin;
  assign execute_GoblinCtrlpdpikadd8 = _zz_execute_GoblinCtrlpdpikadd8;
  assign memory_CG6_FINAL_OUTPUT = execute_to_memory_CG6_FINAL_OUTPUT;
  assign memory_IS_CG6 = execute_to_memory_IS_CG6;
  assign execute_CG6Ctrl = _zz_execute_CG6Ctrl;
  assign execute_SRC3 = _zz_execute_SRC3_2;
  assign execute_CG6Ctrlternary = _zz_execute_CG6Ctrlternary;
  assign execute_CG6Ctrlsignextend = _zz_execute_CG6Ctrlsignextend;
  assign execute_CG6Ctrlminmax = _zz_execute_CG6Ctrlminmax;
  assign memory_SHIFT_RIGHT = execute_to_memory_SHIFT_RIGHT;
  always @(*) begin
    _zz_decode_RS3_3 = memory_REGFILE_WRITE_DATA;
    if(memory_arbitration_isValid) begin
      case(memory_SHIFT_CTRL)
        ShiftCtrlEnum_SLL_1 : begin
          _zz_decode_RS3_3 = _zz_decode_RS3_6;
        end
        ShiftCtrlEnum_SRL_1, ShiftCtrlEnum_SRA_1 : begin
          _zz_decode_RS3_3 = memory_SHIFT_RIGHT;
        end
        default : begin
        end
      endcase
    end
    if(when_CG6_l489) begin
      _zz_decode_RS3_3 = memory_CG6_FINAL_OUTPUT;
    end
    if(when_Goblin_l591) begin
      _zz_decode_RS3_3 = memory_Goblin_FINAL_OUTPUT;
    end
  end

  assign memory_SHIFT_CTRL = _zz_memory_SHIFT_CTRL;
  assign execute_SHIFT_CTRL = _zz_execute_SHIFT_CTRL;
  assign writeBack_IS_MUL = memory_to_writeBack_IS_MUL;
  assign writeBack_MUL_HH = memory_to_writeBack_MUL_HH;
  assign writeBack_MUL_LOW = memory_to_writeBack_MUL_LOW;
  assign memory_MUL_HL = execute_to_memory_MUL_HL;
  assign memory_MUL_LH = execute_to_memory_MUL_LH;
  assign memory_MUL_LL = execute_to_memory_MUL_LL;
  assign execute_RS1 = decode_to_execute_RS1;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign execute_SRC2_FORCE_ZERO = decode_to_execute_SRC2_FORCE_ZERO;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign execute_SRC3_CTRL = _zz_execute_SRC3_CTRL;
  assign _zz_execute_SRC2 = execute_PC;
  assign execute_SRC2_CTRL = _zz_execute_SRC2_CTRL;
  assign execute_SRC1_CTRL = _zz_execute_SRC1_CTRL;
  assign decode_SRC_USE_SUB_LESS = _zz_decode_IS_Goblin2c[3];
  assign decode_SRC_ADD_ZERO = _zz_decode_IS_Goblin2c[23];
  assign execute_SRC_ADD_SUB = execute_SrcPlugin_addSub;
  assign execute_SRC_LESS = execute_SrcPlugin_less;
  assign execute_ALU_CTRL = _zz_execute_ALU_CTRL;
  assign execute_SRC2 = _zz_execute_SRC2_5;
  assign execute_SRC1 = _zz_execute_SRC1;
  assign execute_ALU_BITWISE_CTRL = _zz_execute_ALU_BITWISE_CTRL;
  assign _zz_lastStageRegFileWrite_valid = writeBack_REGFILE_WRITE_VALID_ODD;
  always @(*) begin
    _zz_1 = 1'b0;
    if(lastStageRegFileWrite_valid_1) begin
      _zz_1 = 1'b1;
    end
  end

  assign _zz_lastStageRegFileWrite_valid_1 = writeBack_REGFILE_WRITE_VALID;
  always @(*) begin
    _zz_2 = 1'b0;
    if(lastStageRegFileWrite_valid) begin
      _zz_2 = 1'b1;
    end
  end

  assign _zz_writeBack_RegFileOddEvenPlugin_rdIndex = writeBack_INSTRUCTION;
  always @(*) begin
    decode_REGFILE_WRITE_VALID_ODD = _zz_decode_IS_Goblin2c[16];
    if(when_RegFileOddEvenPlugin_l69) begin
      decode_REGFILE_WRITE_VALID_ODD = 1'b0;
    end
  end

  always @(*) begin
    decode_REGFILE_WRITE_VALID = _zz_decode_IS_Goblin2c[10];
    if(when_RegFileOddEvenPlugin_l69) begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  always @(*) begin
    _zz_decode_RS3_4 = writeBack_REGFILE_WRITE_DATA_ODD;
    if(when_DBusCachedPlugin_l502) begin
      _zz_decode_RS3_4 = writeBack_DBusCachedPlugin_rspFormated[63 : 32];
    end
  end

  always @(*) begin
    _zz_decode_RS3_5 = writeBack_REGFILE_WRITE_DATA;
    if(when_DBusCachedPlugin_l502) begin
      _zz_decode_RS3_5 = writeBack_DBusCachedPlugin_rspFormated[31 : 0];
    end
    if(when_MulPlugin_l147) begin
      case(switch_MulPlugin_l148)
        2'b00 : begin
          _zz_decode_RS3_5 = _zz__zz_decode_RS3_5;
        end
        default : begin
          _zz_decode_RS3_5 = _zz__zz_decode_RS3_5_1;
        end
      endcase
    end
    if(when_Goblin2c_l115) begin
      _zz_decode_RS3_5 = writeBack_Goblin2c_FINAL_OUTPUT;
    end
  end

  assign writeBack_MEMORY_STORE_DATA_RF = memory_to_writeBack_MEMORY_STORE_DATA_RF;
  assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
  assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
  assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
  assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
  assign execute_MEMORY_FORCE_CONSTISTENCY = decode_to_execute_MEMORY_FORCE_CONSTISTENCY;
  assign execute_MEMORY_MANAGMENT = decode_to_execute_MEMORY_MANAGMENT;
  assign execute_RS3 = decode_to_execute_RS3;
  assign execute_RS2 = decode_to_execute_RS2;
  assign execute_MEMORY_WR = decode_to_execute_MEMORY_WR;
  assign execute_SRC_ADD = execute_SrcPlugin_addSub;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign decode_MEMORY_ENABLE = _zz_decode_IS_Goblin2c[4];
  assign decode_FLUSH_ALL = _zz_decode_IS_Goblin2c[0];
  always @(*) begin
    IBusCachedPlugin_rsp_issueDetected_2 = IBusCachedPlugin_rsp_issueDetected_1;
    if(when_IBusCachedPlugin_l250) begin
      IBusCachedPlugin_rsp_issueDetected_2 = 1'b1;
    end
  end

  always @(*) begin
    IBusCachedPlugin_rsp_issueDetected_1 = IBusCachedPlugin_rsp_issueDetected;
    if(when_IBusCachedPlugin_l239) begin
      IBusCachedPlugin_rsp_issueDetected_1 = 1'b1;
    end
  end

  assign decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_1;
  assign decode_INSTRUCTION = IBusCachedPlugin_iBusRsp_output_payload_rsp_inst;
  always @(*) begin
    _zz_memory_to_writeBack_FORMAL_PC_NEXT = memory_FORMAL_PC_NEXT;
    if(BranchPlugin_jumpInterface_valid) begin
      _zz_memory_to_writeBack_FORMAL_PC_NEXT = BranchPlugin_jumpInterface_payload;
    end
  end

  always @(*) begin
    _zz_decode_to_execute_FORMAL_PC_NEXT = decode_FORMAL_PC_NEXT;
    if(IBusCachedPlugin_predictionJumpInterface_valid) begin
      _zz_decode_to_execute_FORMAL_PC_NEXT = IBusCachedPlugin_predictionJumpInterface_payload;
    end
  end

  assign decode_PC = IBusCachedPlugin_iBusRsp_output_payload_pc;
  assign writeBack_PC = memory_to_writeBack_PC;
  assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
  always @(*) begin
    decode_arbitration_haltItself = 1'b0;
    if(when_DBusCachedPlugin_l318) begin
      decode_arbitration_haltItself = 1'b1;
    end
  end

  always @(*) begin
    decode_arbitration_haltByOther = 1'b0;
    if(when_HazardSimplePlugin_l163) begin
      decode_arbitration_haltByOther = 1'b1;
    end
  end

  always @(*) begin
    decode_arbitration_removeIt = 1'b0;
    if(decode_arbitration_isFlushed) begin
      decode_arbitration_removeIt = 1'b1;
    end
  end

  assign decode_arbitration_flushIt = 1'b0;
  always @(*) begin
    decode_arbitration_flushNext = 1'b0;
    if(IBusCachedPlugin_predictionJumpInterface_valid) begin
      decode_arbitration_flushNext = 1'b1;
    end
  end

  always @(*) begin
    execute_arbitration_haltItself = 1'b0;
    if(when_DBusCachedPlugin_l359) begin
      execute_arbitration_haltItself = 1'b1;
    end
  end

  always @(*) begin
    execute_arbitration_haltByOther = 1'b0;
    if(when_DBusCachedPlugin_l375) begin
      execute_arbitration_haltByOther = 1'b1;
    end
  end

  always @(*) begin
    execute_arbitration_removeIt = 1'b0;
    if(execute_arbitration_isFlushed) begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  assign execute_arbitration_flushIt = 1'b0;
  assign execute_arbitration_flushNext = 1'b0;
  assign memory_arbitration_haltItself = 1'b0;
  assign memory_arbitration_haltByOther = 1'b0;
  always @(*) begin
    memory_arbitration_removeIt = 1'b0;
    if(memory_arbitration_isFlushed) begin
      memory_arbitration_removeIt = 1'b1;
    end
  end

  assign memory_arbitration_flushIt = 1'b0;
  always @(*) begin
    memory_arbitration_flushNext = 1'b0;
    if(BranchPlugin_jumpInterface_valid) begin
      memory_arbitration_flushNext = 1'b1;
    end
  end

  always @(*) begin
    writeBack_arbitration_haltItself = 1'b0;
    if(when_DBusCachedPlugin_l475) begin
      writeBack_arbitration_haltItself = 1'b1;
    end
  end

  assign writeBack_arbitration_haltByOther = 1'b0;
  always @(*) begin
    writeBack_arbitration_removeIt = 1'b0;
    if(writeBack_arbitration_isFlushed) begin
      writeBack_arbitration_removeIt = 1'b1;
    end
  end

  always @(*) begin
    writeBack_arbitration_flushIt = 1'b0;
    if(DBusCachedPlugin_redoBranch_valid) begin
      writeBack_arbitration_flushIt = 1'b1;
    end
  end

  always @(*) begin
    writeBack_arbitration_flushNext = 1'b0;
    if(DBusCachedPlugin_redoBranch_valid) begin
      writeBack_arbitration_flushNext = 1'b1;
    end
  end

  assign lastStageInstruction = writeBack_INSTRUCTION;
  assign lastStagePc = writeBack_PC;
  assign lastStageIsValid = writeBack_arbitration_isValid;
  assign lastStageIsFiring = writeBack_arbitration_isFiring;
  assign IBusCachedPlugin_fetcherHalt = 1'b0;
  assign IBusCachedPlugin_forceNoDecodeCond = 1'b0;
  always @(*) begin
    IBusCachedPlugin_incomingInstruction = 1'b0;
    if(when_Fetcher_l243) begin
      IBusCachedPlugin_incomingInstruction = 1'b1;
    end
  end

  assign BranchPlugin_inDebugNoFetchFlag = 1'b0;
  assign IBusCachedPlugin_externalFlush = ({writeBack_arbitration_flushNext,{memory_arbitration_flushNext,{execute_arbitration_flushNext,decode_arbitration_flushNext}}} != 4'b0000);
  assign IBusCachedPlugin_jump_pcLoad_valid = ({BranchPlugin_jumpInterface_valid,{DBusCachedPlugin_redoBranch_valid,IBusCachedPlugin_predictionJumpInterface_valid}} != 3'b000);
  assign _zz_IBusCachedPlugin_jump_pcLoad_payload = {IBusCachedPlugin_predictionJumpInterface_valid,{BranchPlugin_jumpInterface_valid,DBusCachedPlugin_redoBranch_valid}};
  assign _zz_IBusCachedPlugin_jump_pcLoad_payload_1 = (_zz_IBusCachedPlugin_jump_pcLoad_payload & (~ _zz__zz_IBusCachedPlugin_jump_pcLoad_payload_1));
  assign _zz_IBusCachedPlugin_jump_pcLoad_payload_2 = _zz_IBusCachedPlugin_jump_pcLoad_payload_1[1];
  assign _zz_IBusCachedPlugin_jump_pcLoad_payload_3 = _zz_IBusCachedPlugin_jump_pcLoad_payload_1[2];
  assign IBusCachedPlugin_jump_pcLoad_payload = _zz_IBusCachedPlugin_jump_pcLoad_payload_4;
  always @(*) begin
    IBusCachedPlugin_fetchPc_correction = 1'b0;
    if(IBusCachedPlugin_fetchPc_redo_valid) begin
      IBusCachedPlugin_fetchPc_correction = 1'b1;
    end
    if(IBusCachedPlugin_jump_pcLoad_valid) begin
      IBusCachedPlugin_fetchPc_correction = 1'b1;
    end
  end

  assign IBusCachedPlugin_fetchPc_output_fire = (IBusCachedPlugin_fetchPc_output_valid && IBusCachedPlugin_fetchPc_output_ready);
  assign IBusCachedPlugin_fetchPc_corrected = (IBusCachedPlugin_fetchPc_correction || IBusCachedPlugin_fetchPc_correctionReg);
  always @(*) begin
    IBusCachedPlugin_fetchPc_pcRegPropagate = 1'b0;
    if(IBusCachedPlugin_iBusRsp_stages_1_input_ready) begin
      IBusCachedPlugin_fetchPc_pcRegPropagate = 1'b1;
    end
  end

  assign when_Fetcher_l134 = (IBusCachedPlugin_fetchPc_correction || IBusCachedPlugin_fetchPc_pcRegPropagate);
  assign IBusCachedPlugin_fetchPc_output_fire_1 = (IBusCachedPlugin_fetchPc_output_valid && IBusCachedPlugin_fetchPc_output_ready);
  assign when_Fetcher_l134_1 = ((! IBusCachedPlugin_fetchPc_output_valid) && IBusCachedPlugin_fetchPc_output_ready);
  always @(*) begin
    IBusCachedPlugin_fetchPc_pc = (IBusCachedPlugin_fetchPc_pcReg + _zz_IBusCachedPlugin_fetchPc_pc);
    if(IBusCachedPlugin_fetchPc_redo_valid) begin
      IBusCachedPlugin_fetchPc_pc = IBusCachedPlugin_fetchPc_redo_payload;
    end
    if(IBusCachedPlugin_jump_pcLoad_valid) begin
      IBusCachedPlugin_fetchPc_pc = IBusCachedPlugin_jump_pcLoad_payload;
    end
    IBusCachedPlugin_fetchPc_pc[0] = 1'b0;
    IBusCachedPlugin_fetchPc_pc[1] = 1'b0;
  end

  always @(*) begin
    IBusCachedPlugin_fetchPc_flushed = 1'b0;
    if(IBusCachedPlugin_fetchPc_redo_valid) begin
      IBusCachedPlugin_fetchPc_flushed = 1'b1;
    end
    if(IBusCachedPlugin_jump_pcLoad_valid) begin
      IBusCachedPlugin_fetchPc_flushed = 1'b1;
    end
  end

  assign when_Fetcher_l161 = (IBusCachedPlugin_fetchPc_booted && ((IBusCachedPlugin_fetchPc_output_ready || IBusCachedPlugin_fetchPc_correction) || IBusCachedPlugin_fetchPc_pcRegPropagate));
  assign IBusCachedPlugin_fetchPc_output_valid = ((! IBusCachedPlugin_fetcherHalt) && IBusCachedPlugin_fetchPc_booted);
  assign IBusCachedPlugin_fetchPc_output_payload = IBusCachedPlugin_fetchPc_pc;
  always @(*) begin
    IBusCachedPlugin_iBusRsp_redoFetch = 1'b0;
    if(IBusCachedPlugin_rsp_redoFetch) begin
      IBusCachedPlugin_iBusRsp_redoFetch = 1'b1;
    end
  end

  assign IBusCachedPlugin_iBusRsp_stages_0_input_valid = IBusCachedPlugin_fetchPc_output_valid;
  assign IBusCachedPlugin_fetchPc_output_ready = IBusCachedPlugin_iBusRsp_stages_0_input_ready;
  assign IBusCachedPlugin_iBusRsp_stages_0_input_payload = IBusCachedPlugin_fetchPc_output_payload;
  always @(*) begin
    IBusCachedPlugin_iBusRsp_stages_0_halt = 1'b0;
    if(IBusCachedPlugin_cache_io_cpu_prefetch_haltIt) begin
      IBusCachedPlugin_iBusRsp_stages_0_halt = 1'b1;
    end
  end

  assign _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready = (! IBusCachedPlugin_iBusRsp_stages_0_halt);
  assign IBusCachedPlugin_iBusRsp_stages_0_input_ready = (IBusCachedPlugin_iBusRsp_stages_0_output_ready && _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_valid = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_payload = IBusCachedPlugin_iBusRsp_stages_0_input_payload;
  always @(*) begin
    IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b0;
    if(IBusCachedPlugin_mmuBus_busy) begin
      IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b1;
    end
  end

  assign _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready = (! IBusCachedPlugin_iBusRsp_stages_1_halt);
  assign IBusCachedPlugin_iBusRsp_stages_1_input_ready = (IBusCachedPlugin_iBusRsp_stages_1_output_ready && _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_valid = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_payload = IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  always @(*) begin
    IBusCachedPlugin_iBusRsp_stages_2_halt = 1'b0;
    if(when_IBusCachedPlugin_l267) begin
      IBusCachedPlugin_iBusRsp_stages_2_halt = 1'b1;
    end
  end

  assign _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready = (! IBusCachedPlugin_iBusRsp_stages_2_halt);
  assign IBusCachedPlugin_iBusRsp_stages_2_input_ready = (IBusCachedPlugin_iBusRsp_stages_2_output_ready && _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready);
  assign IBusCachedPlugin_iBusRsp_stages_2_output_valid = (IBusCachedPlugin_iBusRsp_stages_2_input_valid && _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready);
  assign IBusCachedPlugin_iBusRsp_stages_2_output_payload = IBusCachedPlugin_iBusRsp_stages_2_input_payload;
  assign IBusCachedPlugin_fetchPc_redo_valid = IBusCachedPlugin_iBusRsp_redoFetch;
  assign IBusCachedPlugin_fetchPc_redo_payload = IBusCachedPlugin_iBusRsp_stages_2_input_payload;
  assign IBusCachedPlugin_iBusRsp_flush = ((decode_arbitration_removeIt || (decode_arbitration_flushNext && (! decode_arbitration_isStuck))) || IBusCachedPlugin_iBusRsp_redoFetch);
  assign IBusCachedPlugin_iBusRsp_stages_0_output_ready = _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready;
  assign _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready = ((1'b0 && (! _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_1)) || IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_1 = _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_2;
  assign IBusCachedPlugin_iBusRsp_stages_1_input_valid = _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_1;
  assign IBusCachedPlugin_iBusRsp_stages_1_input_payload = IBusCachedPlugin_fetchPc_pcReg;
  assign IBusCachedPlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid)) || IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready);
  assign IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid = _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
  assign IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload = _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
  assign IBusCachedPlugin_iBusRsp_stages_2_input_valid = IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
  assign IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready = IBusCachedPlugin_iBusRsp_stages_2_input_ready;
  assign IBusCachedPlugin_iBusRsp_stages_2_input_payload = IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
  always @(*) begin
    IBusCachedPlugin_iBusRsp_readyForError = 1'b1;
    if(when_Fetcher_l323) begin
      IBusCachedPlugin_iBusRsp_readyForError = 1'b0;
    end
  end

  assign when_Fetcher_l243 = (IBusCachedPlugin_iBusRsp_stages_1_input_valid || IBusCachedPlugin_iBusRsp_stages_2_input_valid);
  assign when_Fetcher_l323 = (! IBusCachedPlugin_pcValids_0);
  assign when_Fetcher_l332 = (! (! IBusCachedPlugin_iBusRsp_stages_1_input_ready));
  assign when_Fetcher_l332_1 = (! (! IBusCachedPlugin_iBusRsp_stages_2_input_ready));
  assign when_Fetcher_l332_2 = (! execute_arbitration_isStuck);
  assign when_Fetcher_l332_3 = (! memory_arbitration_isStuck);
  assign when_Fetcher_l332_4 = (! writeBack_arbitration_isStuck);
  assign IBusCachedPlugin_pcValids_0 = IBusCachedPlugin_injector_nextPcCalc_valids_1;
  assign IBusCachedPlugin_pcValids_1 = IBusCachedPlugin_injector_nextPcCalc_valids_2;
  assign IBusCachedPlugin_pcValids_2 = IBusCachedPlugin_injector_nextPcCalc_valids_3;
  assign IBusCachedPlugin_pcValids_3 = IBusCachedPlugin_injector_nextPcCalc_valids_4;
  assign IBusCachedPlugin_iBusRsp_output_ready = (! decode_arbitration_isStuck);
  always @(*) begin
    decode_arbitration_isValid = IBusCachedPlugin_iBusRsp_output_valid;
    if(IBusCachedPlugin_forceNoDecodeCond) begin
      decode_arbitration_isValid = 1'b0;
    end
  end

  assign _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch = _zz__zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch[11];
  always @(*) begin
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[18] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[17] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[16] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[15] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[14] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[13] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[12] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[11] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[10] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[9] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[8] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[7] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[6] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[5] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[4] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[3] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[2] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[1] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[0] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
  end

  always @(*) begin
    IBusCachedPlugin_decodePrediction_cmd_hadBranch = ((decode_BRANCH_CTRL == BranchCtrlEnum_JAL) || ((decode_BRANCH_CTRL == BranchCtrlEnum_B) && _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_2[31]));
    if(_zz_7) begin
      IBusCachedPlugin_decodePrediction_cmd_hadBranch = 1'b0;
    end
  end

  assign _zz_3 = _zz__zz_3[19];
  always @(*) begin
    _zz_4[10] = _zz_3;
    _zz_4[9] = _zz_3;
    _zz_4[8] = _zz_3;
    _zz_4[7] = _zz_3;
    _zz_4[6] = _zz_3;
    _zz_4[5] = _zz_3;
    _zz_4[4] = _zz_3;
    _zz_4[3] = _zz_3;
    _zz_4[2] = _zz_3;
    _zz_4[1] = _zz_3;
    _zz_4[0] = _zz_3;
  end

  assign _zz_5 = _zz__zz_5[11];
  always @(*) begin
    _zz_6[18] = _zz_5;
    _zz_6[17] = _zz_5;
    _zz_6[16] = _zz_5;
    _zz_6[15] = _zz_5;
    _zz_6[14] = _zz_5;
    _zz_6[13] = _zz_5;
    _zz_6[12] = _zz_5;
    _zz_6[11] = _zz_5;
    _zz_6[10] = _zz_5;
    _zz_6[9] = _zz_5;
    _zz_6[8] = _zz_5;
    _zz_6[7] = _zz_5;
    _zz_6[6] = _zz_5;
    _zz_6[5] = _zz_5;
    _zz_6[4] = _zz_5;
    _zz_6[3] = _zz_5;
    _zz_6[2] = _zz_5;
    _zz_6[1] = _zz_5;
    _zz_6[0] = _zz_5;
  end

  always @(*) begin
    case(decode_BRANCH_CTRL)
      BranchCtrlEnum_JAL : begin
        _zz_7 = _zz__zz_7[1];
      end
      default : begin
        _zz_7 = _zz__zz_7_1[1];
      end
    endcase
  end

  assign IBusCachedPlugin_predictionJumpInterface_valid = (decode_arbitration_isValid && IBusCachedPlugin_decodePrediction_cmd_hadBranch);
  assign _zz_IBusCachedPlugin_predictionJumpInterface_payload = _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload[19];
  always @(*) begin
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[10] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[9] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[8] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[7] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[6] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[5] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[4] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[3] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[2] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[1] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[0] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
  end

  assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_2 = _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload_2[11];
  always @(*) begin
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[18] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[17] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[16] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[15] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[14] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[13] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[12] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[11] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[10] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[9] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[8] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[7] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[6] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[5] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[4] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[3] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[2] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[1] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[0] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
  end

  assign IBusCachedPlugin_predictionJumpInterface_payload = (decode_PC + ((decode_BRANCH_CTRL == BranchCtrlEnum_JAL) ? {{_zz_IBusCachedPlugin_predictionJumpInterface_payload_1,{{{_zz_IBusCachedPlugin_predictionJumpInterface_payload_4,decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_IBusCachedPlugin_predictionJumpInterface_payload_3,{{{_zz_IBusCachedPlugin_predictionJumpInterface_payload_5,_zz_IBusCachedPlugin_predictionJumpInterface_payload_6},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0}));
  assign iBus_cmd_valid = IBusCachedPlugin_cache_io_mem_cmd_valid;
  always @(*) begin
    iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
    iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
  end

  assign iBus_cmd_payload_size = IBusCachedPlugin_cache_io_mem_cmd_payload_size;
  assign IBusCachedPlugin_s0_tightlyCoupledHit = 1'b0;
  assign IBusCachedPlugin_cache_io_cpu_prefetch_isValid = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && (! IBusCachedPlugin_s0_tightlyCoupledHit));
  assign IBusCachedPlugin_cache_io_cpu_fetch_isValid = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && (! IBusCachedPlugin_s1_tightlyCoupledHit));
  assign IBusCachedPlugin_cache_io_cpu_fetch_isStuck = (! IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign IBusCachedPlugin_mmuBus_cmd_0_isValid = IBusCachedPlugin_cache_io_cpu_fetch_isValid;
  assign IBusCachedPlugin_mmuBus_cmd_0_isStuck = (! IBusCachedPlugin_iBusRsp_stages_1_input_ready);
  assign IBusCachedPlugin_mmuBus_cmd_0_virtualAddress = IBusCachedPlugin_iBusRsp_stages_1_input_payload;
  assign IBusCachedPlugin_mmuBus_cmd_0_bypassTranslation = 1'b0;
  assign IBusCachedPlugin_mmuBus_end = (IBusCachedPlugin_iBusRsp_stages_1_input_ready || IBusCachedPlugin_externalFlush);
  assign IBusCachedPlugin_cache_io_cpu_decode_isValid = (IBusCachedPlugin_iBusRsp_stages_2_input_valid && (! IBusCachedPlugin_s2_tightlyCoupledHit));
  assign IBusCachedPlugin_cache_io_cpu_decode_isStuck = (! IBusCachedPlugin_iBusRsp_stages_2_input_ready);
  assign IBusCachedPlugin_rsp_iBusRspOutputHalt = 1'b0;
  assign IBusCachedPlugin_rsp_issueDetected = 1'b0;
  always @(*) begin
    IBusCachedPlugin_rsp_redoFetch = 1'b0;
    if(when_IBusCachedPlugin_l239) begin
      IBusCachedPlugin_rsp_redoFetch = 1'b1;
    end
    if(when_IBusCachedPlugin_l250) begin
      IBusCachedPlugin_rsp_redoFetch = 1'b1;
    end
  end

  always @(*) begin
    IBusCachedPlugin_cache_io_cpu_fill_valid = (IBusCachedPlugin_rsp_redoFetch && (! IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling));
    if(when_IBusCachedPlugin_l250) begin
      IBusCachedPlugin_cache_io_cpu_fill_valid = 1'b1;
    end
  end

  assign when_IBusCachedPlugin_l239 = ((IBusCachedPlugin_cache_io_cpu_decode_isValid && IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling) && (! IBusCachedPlugin_rsp_issueDetected));
  assign when_IBusCachedPlugin_l250 = ((IBusCachedPlugin_cache_io_cpu_decode_isValid && IBusCachedPlugin_cache_io_cpu_decode_cacheMiss) && (! IBusCachedPlugin_rsp_issueDetected_1));
  assign when_IBusCachedPlugin_l267 = (IBusCachedPlugin_rsp_issueDetected_2 || IBusCachedPlugin_rsp_iBusRspOutputHalt);
  assign IBusCachedPlugin_iBusRsp_output_valid = IBusCachedPlugin_iBusRsp_stages_2_output_valid;
  assign IBusCachedPlugin_iBusRsp_stages_2_output_ready = IBusCachedPlugin_iBusRsp_output_ready;
  assign IBusCachedPlugin_iBusRsp_output_payload_rsp_inst = IBusCachedPlugin_cache_io_cpu_decode_data;
  assign IBusCachedPlugin_iBusRsp_output_payload_pc = IBusCachedPlugin_iBusRsp_stages_2_output_payload;
  assign IBusCachedPlugin_cache_io_flush = (decode_arbitration_isValid && decode_FLUSH_ALL);
  assign dataCache_1_io_mem_cmd_ready = (! dataCache_1_io_mem_cmd_rValid);
  assign dataCache_1_io_mem_cmd_s2mPipe_valid = (dataCache_1_io_mem_cmd_valid || dataCache_1_io_mem_cmd_rValid);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_wr = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_wr : dataCache_1_io_mem_cmd_payload_wr);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_uncached = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_uncached : dataCache_1_io_mem_cmd_payload_uncached);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_address = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_address : dataCache_1_io_mem_cmd_payload_address);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_data = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_data : dataCache_1_io_mem_cmd_payload_data);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_mask = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_mask : dataCache_1_io_mem_cmd_payload_mask);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_size = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_size : dataCache_1_io_mem_cmd_payload_size);
  assign dataCache_1_io_mem_cmd_s2mPipe_payload_last = (dataCache_1_io_mem_cmd_rValid ? dataCache_1_io_mem_cmd_rData_last : dataCache_1_io_mem_cmd_payload_last);
  assign dBus_cmd_valid = dataCache_1_io_mem_cmd_s2mPipe_valid;
  assign dataCache_1_io_mem_cmd_s2mPipe_ready = dBus_cmd_ready;
  assign dBus_cmd_payload_wr = dataCache_1_io_mem_cmd_s2mPipe_payload_wr;
  assign dBus_cmd_payload_uncached = dataCache_1_io_mem_cmd_s2mPipe_payload_uncached;
  assign dBus_cmd_payload_address = dataCache_1_io_mem_cmd_s2mPipe_payload_address;
  assign dBus_cmd_payload_data = dataCache_1_io_mem_cmd_s2mPipe_payload_data;
  assign dBus_cmd_payload_mask = dataCache_1_io_mem_cmd_s2mPipe_payload_mask;
  assign dBus_cmd_payload_size = dataCache_1_io_mem_cmd_s2mPipe_payload_size;
  assign dBus_cmd_payload_last = dataCache_1_io_mem_cmd_s2mPipe_payload_last;
  assign when_DBusCachedPlugin_l318 = ((DBusCachedPlugin_mmuBus_busy && decode_arbitration_isValid) && decode_MEMORY_ENABLE);
  assign execute_DBusCachedPlugin_size = execute_INSTRUCTION[13 : 12];
  assign dataCache_1_io_cpu_execute_isValid = (execute_arbitration_isValid && execute_MEMORY_ENABLE);
  assign dataCache_1_io_cpu_execute_address = execute_SRC_ADD;
  always @(*) begin
    case(execute_DBusCachedPlugin_size)
      2'b00 : begin
        _zz_execute_MEMORY_STORE_DATA_RF = {{{{{{{execute_RS2[7 : 0],execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]},execute_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_execute_MEMORY_STORE_DATA_RF = {{{execute_RS2[15 : 0],execute_RS2[15 : 0]},execute_RS2[15 : 0]},execute_RS2[15 : 0]};
      end
      2'b10 : begin
        _zz_execute_MEMORY_STORE_DATA_RF = {execute_RS2[31 : 0],execute_RS2[31 : 0]};
      end
      default : begin
        _zz_execute_MEMORY_STORE_DATA_RF = {execute_RS3[31 : 0],execute_RS2[31 : 0]};
      end
    endcase
  end

  assign dataCache_1_io_cpu_execute_args_size = {1'd0, execute_DBusCachedPlugin_size};
  assign dataCache_1_io_cpu_flush_valid = (execute_arbitration_isValid && execute_MEMORY_MANAGMENT);
  assign dataCache_1_io_cpu_flush_isStall = (dataCache_1_io_cpu_flush_valid && (! dataCache_1_io_cpu_flush_ready));
  assign when_DBusCachedPlugin_l359 = (dataCache_1_io_cpu_flush_isStall || dataCache_1_io_cpu_execute_haltIt);
  assign when_DBusCachedPlugin_l375 = (dataCache_1_io_cpu_execute_refilling && execute_arbitration_isValid);
  assign dataCache_1_io_cpu_memory_isValid = (memory_arbitration_isValid && memory_MEMORY_ENABLE);
  assign dataCache_1_io_cpu_memory_address = memory_REGFILE_WRITE_DATA;
  assign DBusCachedPlugin_mmuBus_cmd_0_isValid = dataCache_1_io_cpu_memory_isValid;
  assign DBusCachedPlugin_mmuBus_cmd_0_isStuck = memory_arbitration_isStuck;
  assign DBusCachedPlugin_mmuBus_cmd_0_virtualAddress = dataCache_1_io_cpu_memory_address;
  assign DBusCachedPlugin_mmuBus_cmd_0_bypassTranslation = 1'b0;
  assign DBusCachedPlugin_mmuBus_end = ((! memory_arbitration_isStuck) || memory_arbitration_removeIt);
  always @(*) begin
    dataCache_1_io_cpu_memory_mmuRsp_isIoAccess = DBusCachedPlugin_mmuBus_rsp_isIoAccess;
    if(when_DBusCachedPlugin_l402) begin
      dataCache_1_io_cpu_memory_mmuRsp_isIoAccess = 1'b1;
    end
  end

  assign when_DBusCachedPlugin_l402 = (1'b0 && (! dataCache_1_io_cpu_memory_isWrite));
  always @(*) begin
    dataCache_1_io_cpu_writeBack_isValid = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
    if(writeBack_arbitration_haltByOther) begin
      dataCache_1_io_cpu_writeBack_isValid = 1'b0;
    end
  end

  assign dataCache_1_io_cpu_writeBack_address = writeBack_REGFILE_WRITE_DATA;
  always @(*) begin
    dataCache_1_io_cpu_writeBack_storeData[63 : 0] = writeBack_MEMORY_STORE_DATA_RF;
    dataCache_1_io_cpu_writeBack_storeData[127 : 64] = writeBack_MEMORY_STORE_DATA_RF;
  end

  always @(*) begin
    DBusCachedPlugin_redoBranch_valid = 1'b0;
    if(when_DBusCachedPlugin_l455) begin
      if(dataCache_1_io_cpu_redo) begin
        DBusCachedPlugin_redoBranch_valid = 1'b1;
      end
    end
  end

  assign DBusCachedPlugin_redoBranch_payload = writeBack_PC;
  assign when_DBusCachedPlugin_l455 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
  assign when_DBusCachedPlugin_l475 = (dataCache_1_io_cpu_writeBack_isValid && dataCache_1_io_cpu_writeBack_haltIt);
  assign writeBack_DBusCachedPlugin_rspSplits_0 = dataCache_1_io_cpu_writeBack_data[7 : 0];
  assign writeBack_DBusCachedPlugin_rspSplits_1 = dataCache_1_io_cpu_writeBack_data[15 : 8];
  assign writeBack_DBusCachedPlugin_rspSplits_2 = dataCache_1_io_cpu_writeBack_data[23 : 16];
  assign writeBack_DBusCachedPlugin_rspSplits_3 = dataCache_1_io_cpu_writeBack_data[31 : 24];
  assign writeBack_DBusCachedPlugin_rspSplits_4 = dataCache_1_io_cpu_writeBack_data[39 : 32];
  assign writeBack_DBusCachedPlugin_rspSplits_5 = dataCache_1_io_cpu_writeBack_data[47 : 40];
  assign writeBack_DBusCachedPlugin_rspSplits_6 = dataCache_1_io_cpu_writeBack_data[55 : 48];
  assign writeBack_DBusCachedPlugin_rspSplits_7 = dataCache_1_io_cpu_writeBack_data[63 : 56];
  assign writeBack_DBusCachedPlugin_rspSplits_8 = dataCache_1_io_cpu_writeBack_data[71 : 64];
  assign writeBack_DBusCachedPlugin_rspSplits_9 = dataCache_1_io_cpu_writeBack_data[79 : 72];
  assign writeBack_DBusCachedPlugin_rspSplits_10 = dataCache_1_io_cpu_writeBack_data[87 : 80];
  assign writeBack_DBusCachedPlugin_rspSplits_11 = dataCache_1_io_cpu_writeBack_data[95 : 88];
  assign writeBack_DBusCachedPlugin_rspSplits_12 = dataCache_1_io_cpu_writeBack_data[103 : 96];
  assign writeBack_DBusCachedPlugin_rspSplits_13 = dataCache_1_io_cpu_writeBack_data[111 : 104];
  assign writeBack_DBusCachedPlugin_rspSplits_14 = dataCache_1_io_cpu_writeBack_data[119 : 112];
  assign writeBack_DBusCachedPlugin_rspSplits_15 = dataCache_1_io_cpu_writeBack_data[127 : 120];
  always @(*) begin
    writeBack_DBusCachedPlugin_rspShifted[7 : 0] = _zz_writeBack_DBusCachedPlugin_rspShifted;
    writeBack_DBusCachedPlugin_rspShifted[15 : 8] = _zz_writeBack_DBusCachedPlugin_rspShifted_2;
    writeBack_DBusCachedPlugin_rspShifted[23 : 16] = _zz_writeBack_DBusCachedPlugin_rspShifted_4;
    writeBack_DBusCachedPlugin_rspShifted[31 : 24] = _zz_writeBack_DBusCachedPlugin_rspShifted_6;
    writeBack_DBusCachedPlugin_rspShifted[39 : 32] = _zz_writeBack_DBusCachedPlugin_rspShifted_8;
    writeBack_DBusCachedPlugin_rspShifted[47 : 40] = _zz_writeBack_DBusCachedPlugin_rspShifted_10;
    writeBack_DBusCachedPlugin_rspShifted[55 : 48] = _zz_writeBack_DBusCachedPlugin_rspShifted_12;
    writeBack_DBusCachedPlugin_rspShifted[63 : 56] = _zz_writeBack_DBusCachedPlugin_rspShifted_14;
    writeBack_DBusCachedPlugin_rspShifted[71 : 64] = writeBack_DBusCachedPlugin_rspSplits_8;
    writeBack_DBusCachedPlugin_rspShifted[79 : 72] = writeBack_DBusCachedPlugin_rspSplits_9;
    writeBack_DBusCachedPlugin_rspShifted[87 : 80] = writeBack_DBusCachedPlugin_rspSplits_10;
    writeBack_DBusCachedPlugin_rspShifted[95 : 88] = writeBack_DBusCachedPlugin_rspSplits_11;
    writeBack_DBusCachedPlugin_rspShifted[103 : 96] = writeBack_DBusCachedPlugin_rspSplits_12;
    writeBack_DBusCachedPlugin_rspShifted[111 : 104] = writeBack_DBusCachedPlugin_rspSplits_13;
    writeBack_DBusCachedPlugin_rspShifted[119 : 112] = writeBack_DBusCachedPlugin_rspSplits_14;
    writeBack_DBusCachedPlugin_rspShifted[127 : 120] = writeBack_DBusCachedPlugin_rspSplits_15;
  end

  assign writeBack_DBusCachedPlugin_rspRf = writeBack_DBusCachedPlugin_rspShifted[63 : 0];
  assign switch_Misc_l211 = writeBack_INSTRUCTION[13 : 12];
  assign _zz_writeBack_DBusCachedPlugin_rspFormated = (writeBack_DBusCachedPlugin_rspRf[7] && (! writeBack_INSTRUCTION[14]));
  always @(*) begin
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[63 : 32] = 32'h0;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[31] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[30] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[29] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[28] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[27] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[26] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[25] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[24] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[23] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[22] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[21] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[20] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[19] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[18] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[17] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[16] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[15] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[14] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[13] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[12] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[11] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[10] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[9] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[8] = _zz_writeBack_DBusCachedPlugin_rspFormated;
    _zz_writeBack_DBusCachedPlugin_rspFormated_1[7 : 0] = writeBack_DBusCachedPlugin_rspRf[7 : 0];
  end

  assign _zz_writeBack_DBusCachedPlugin_rspFormated_2 = (writeBack_DBusCachedPlugin_rspRf[15] && (! writeBack_INSTRUCTION[14]));
  always @(*) begin
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[63 : 32] = 32'h0;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[31] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[30] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[29] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[28] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[27] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[26] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[25] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[24] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[23] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[22] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[21] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[20] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[19] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[18] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[17] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[16] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    _zz_writeBack_DBusCachedPlugin_rspFormated_3[15 : 0] = writeBack_DBusCachedPlugin_rspRf[15 : 0];
  end

  always @(*) begin
    _zz_writeBack_DBusCachedPlugin_rspFormated_4[63 : 32] = 32'h0;
    _zz_writeBack_DBusCachedPlugin_rspFormated_4[31 : 0] = writeBack_DBusCachedPlugin_rspRf[31 : 0];
  end

  always @(*) begin
    case(switch_Misc_l211)
      2'b00 : begin
        writeBack_DBusCachedPlugin_rspFormated = _zz_writeBack_DBusCachedPlugin_rspFormated_1;
      end
      2'b01 : begin
        writeBack_DBusCachedPlugin_rspFormated = _zz_writeBack_DBusCachedPlugin_rspFormated_3;
      end
      2'b10 : begin
        writeBack_DBusCachedPlugin_rspFormated = _zz_writeBack_DBusCachedPlugin_rspFormated_4;
      end
      default : begin
        writeBack_DBusCachedPlugin_rspFormated = writeBack_DBusCachedPlugin_rspRf;
      end
    endcase
  end

  assign when_DBusCachedPlugin_l502 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
  assign IBusCachedPlugin_mmuBus_rsp_physicalAddress = IBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
  assign IBusCachedPlugin_mmuBus_rsp_allowRead = 1'b1;
  assign IBusCachedPlugin_mmuBus_rsp_allowWrite = 1'b1;
  assign IBusCachedPlugin_mmuBus_rsp_allowExecute = 1'b1;
  assign IBusCachedPlugin_mmuBus_rsp_isIoAccess = (((IBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 28] != 4'b1000) && (IBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 16] != 16'h0042)) && (IBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 16] != 16'h0041));
  assign IBusCachedPlugin_mmuBus_rsp_isPaging = 1'b0;
  assign IBusCachedPlugin_mmuBus_rsp_exception = 1'b0;
  assign IBusCachedPlugin_mmuBus_rsp_refilling = 1'b0;
  assign IBusCachedPlugin_mmuBus_busy = 1'b0;
  assign DBusCachedPlugin_mmuBus_rsp_physicalAddress = DBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
  assign DBusCachedPlugin_mmuBus_rsp_allowRead = 1'b1;
  assign DBusCachedPlugin_mmuBus_rsp_allowWrite = 1'b1;
  assign DBusCachedPlugin_mmuBus_rsp_allowExecute = 1'b1;
  assign DBusCachedPlugin_mmuBus_rsp_isIoAccess = (((DBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 28] != 4'b1000) && (DBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 16] != 16'h0042)) && (DBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 16] != 16'h0041));
  assign DBusCachedPlugin_mmuBus_rsp_isPaging = 1'b0;
  assign DBusCachedPlugin_mmuBus_rsp_exception = 1'b0;
  assign DBusCachedPlugin_mmuBus_rsp_refilling = 1'b0;
  assign DBusCachedPlugin_mmuBus_busy = 1'b0;
  assign _zz_decode_IS_Goblin2c_1 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000004);
  assign _zz_decode_IS_Goblin2c_2 = ((decode_INSTRUCTION & 32'h00000014) == 32'h00000004);
  assign _zz_decode_IS_Goblin2c_3 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000040);
  assign _zz_decode_IS_Goblin2c_4 = ((decode_INSTRUCTION & 32'h00000070) == 32'h00000020);
  assign _zz_decode_IS_Goblin2c_5 = ((decode_INSTRUCTION & 32'h00000048) == 32'h00000048);
  assign _zz_decode_IS_Goblin2c_6 = ((decode_INSTRUCTION & 32'h04003014) == 32'h04001010);
  assign _zz_decode_IS_Goblin2c_7 = ((decode_INSTRUCTION & 32'h20000050) == 32'h00000050);
  assign _zz_decode_IS_Goblin2c_8 = ((decode_INSTRUCTION & 32'h04000000) == 32'h04000000);
  assign _zz_decode_IS_Goblin2c_9 = ((decode_INSTRUCTION & 32'h02000000) == 32'h02000000);
  assign _zz_decode_IS_Goblin2c = {(|{_zz_decode_IS_Goblin2c_5,(_zz__zz_decode_IS_Goblin2c == _zz__zz_decode_IS_Goblin2c_1)}),{(|(_zz__zz_decode_IS_Goblin2c_2 == _zz__zz_decode_IS_Goblin2c_3)),{(|_zz_decode_IS_Goblin2c_7),{(|_zz__zz_decode_IS_Goblin2c_4),{_zz__zz_decode_IS_Goblin2c_5,{_zz__zz_decode_IS_Goblin2c_6,_zz__zz_decode_IS_Goblin2c_8}}}}}};
  assign _zz_decode_SRC1_CTRL_2 = _zz_decode_IS_Goblin2c[2 : 1];
  assign _zz_decode_SRC1_CTRL_1 = _zz_decode_SRC1_CTRL_2;
  assign _zz_decode_ALU_CTRL_2 = _zz_decode_IS_Goblin2c[7 : 6];
  assign _zz_decode_ALU_CTRL_1 = _zz_decode_ALU_CTRL_2;
  assign _zz_decode_SRC2_CTRL_2 = _zz_decode_IS_Goblin2c[9 : 8];
  assign _zz_decode_SRC2_CTRL_1 = _zz_decode_SRC2_CTRL_2;
  assign _zz_decode_SRC3_CTRL_2 = _zz_decode_IS_Goblin2c[17 : 17];
  assign _zz_decode_SRC3_CTRL_1 = _zz_decode_SRC3_CTRL_2;
  assign _zz_decode_ALU_BITWISE_CTRL_2 = _zz_decode_IS_Goblin2c[22 : 21];
  assign _zz_decode_ALU_BITWISE_CTRL_1 = _zz_decode_ALU_BITWISE_CTRL_2;
  assign _zz_decode_SHIFT_CTRL_2 = _zz_decode_IS_Goblin2c[26 : 25];
  assign _zz_decode_SHIFT_CTRL_1 = _zz_decode_SHIFT_CTRL_2;
  assign _zz_decode_CG6Ctrl_2 = _zz_decode_IS_Goblin2c[30 : 28];
  assign _zz_decode_CG6Ctrl_1 = _zz_decode_CG6Ctrl_2;
  assign _zz_decode_CG6Ctrlminmax_2 = _zz_decode_IS_Goblin2c[31 : 31];
  assign _zz_decode_CG6Ctrlminmax_1 = _zz_decode_CG6Ctrlminmax_2;
  assign _zz_decode_CG6Ctrlsignextend_2 = _zz_decode_IS_Goblin2c[32 : 32];
  assign _zz_decode_CG6Ctrlsignextend_1 = _zz_decode_CG6Ctrlsignextend_2;
  assign _zz_decode_CG6Ctrlternary_2 = _zz_decode_IS_Goblin2c[34 : 33];
  assign _zz_decode_CG6Ctrlternary_1 = _zz_decode_CG6Ctrlternary_2;
  assign _zz_decode_GoblinCtrlpdpikadd8_2 = _zz_decode_IS_Goblin2c[36 : 36];
  assign _zz_decode_GoblinCtrlpdpikadd8_1 = _zz_decode_GoblinCtrlpdpikadd8_2;
  assign _zz_decode_BRANCH_CTRL_2 = _zz_decode_IS_Goblin2c[39 : 38];
  assign _zz_decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_2;
  assign when_RegFileOddEvenPlugin_l69 = (decode_INSTRUCTION[11 : 7] == 5'h0);
  assign decode_RegFileOddEvenPlugin_regFileReadAddress1 = decode_INSTRUCTION[19 : 15];
  assign decode_RegFileOddEvenPlugin_regFileReadAddress2 = decode_INSTRUCTION[24 : 20];
  assign decode_RegFileOddEvenPlugin_regFileReadAddress3 = ((decode_INSTRUCTION[6 : 0] == 7'h77) ? decode_INSTRUCTION[11 : 7] : (((decode_INSTRUCTION & 32'h0010707f) == 32'h00003023) ? (decode_INSTRUCTION[24 : 20] ^ 5'h01) : decode_INSTRUCTION[31 : 27]));
  assign decode_RegFileOddEvenPlugin_rfra1o = (decode_RegFileOddEvenPlugin_regFileReadAddress1 % 2'b10);
  assign decode_RegFileOddEvenPlugin_rfra2o = (decode_RegFileOddEvenPlugin_regFileReadAddress2 % 2'b10);
  assign decode_RegFileOddEvenPlugin_rfra3o = (decode_RegFileOddEvenPlugin_regFileReadAddress3 % 2'b10);
  assign _zz_decode_RegFileOddEvenPlugin_rs1Data = (decode_RegFileOddEvenPlugin_regFileReadAddress1 >>> 1);
  assign _zz_decode_RegFileOddEvenPlugin_rs1Data_1 = (decode_RegFileOddEvenPlugin_regFileReadAddress1 >>> 1);
  assign decode_RegFileOddEvenPlugin_rs1Data = ((decode_RegFileOddEvenPlugin_rfra1o == 5'h0) ? _zz_RegFileOddEvenPlugin_regFileEven_port0 : _zz_RegFileOddEvenPlugin_regFileOdd_port0);
  assign _zz_decode_RegFileOddEvenPlugin_rs2Data = (decode_RegFileOddEvenPlugin_regFileReadAddress2 >>> 1);
  assign _zz_decode_RegFileOddEvenPlugin_rs2Data_1 = (decode_RegFileOddEvenPlugin_regFileReadAddress2 >>> 1);
  assign decode_RegFileOddEvenPlugin_rs2Data = ((decode_RegFileOddEvenPlugin_rfra2o == 5'h0) ? _zz_RegFileOddEvenPlugin_regFileEven_port1 : _zz_RegFileOddEvenPlugin_regFileOdd_port1);
  assign _zz_decode_RegFileOddEvenPlugin_rs3Data = (decode_RegFileOddEvenPlugin_regFileReadAddress3 >>> 1);
  assign _zz_decode_RegFileOddEvenPlugin_rs3Data_1 = (decode_RegFileOddEvenPlugin_regFileReadAddress3 >>> 1);
  assign decode_RegFileOddEvenPlugin_rs3Data = ((decode_RegFileOddEvenPlugin_rfra3o == 5'h0) ? _zz_RegFileOddEvenPlugin_regFileEven_port2 : _zz_RegFileOddEvenPlugin_regFileOdd_port2);
  assign writeBack_RegFileOddEvenPlugin_rdIndex = _zz_writeBack_RegFileOddEvenPlugin_rdIndex[11 : 7];
  always @(*) begin
    lastStageRegFileWrite_valid = (((writeBack_RegFileOddEvenPlugin_rdIndex[0 : 0] == 1'b0) && _zz_lastStageRegFileWrite_valid_1) && writeBack_arbitration_isFiring);
    if(_zz_8) begin
      lastStageRegFileWrite_valid = 1'b1;
    end
  end

  always @(*) begin
    lastStageRegFileWrite_payload_address = (writeBack_RegFileOddEvenPlugin_rdIndex >>> 1);
    if(_zz_8) begin
      lastStageRegFileWrite_payload_address = 4'b0000;
    end
  end

  always @(*) begin
    lastStageRegFileWrite_payload_data = _zz_decode_RS3_5;
    if(_zz_8) begin
      lastStageRegFileWrite_payload_data = 32'h0;
    end
  end

  assign lastStageRegFileWrite_valid_1 = ((((writeBack_RegFileOddEvenPlugin_rdIndex[0 : 0] == 1'b1) && _zz_lastStageRegFileWrite_valid_1) || _zz_lastStageRegFileWrite_valid) && writeBack_arbitration_isFiring);
  assign lastStageRegFileWrite_payload_address_1 = (writeBack_RegFileOddEvenPlugin_rdIndex >>> 1);
  assign lastStageRegFileWrite_payload_data_1 = (((writeBack_RegFileOddEvenPlugin_rdIndex[0 : 0] == 1'b0) && _zz_lastStageRegFileWrite_valid) ? _zz_decode_RS3_4 : _zz_decode_RS3_5);
  always @(*) begin
    case(execute_ALU_BITWISE_CTRL)
      AluBitwiseCtrlEnum_AND_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
      end
      AluBitwiseCtrlEnum_OR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
      end
      default : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
      end
    endcase
  end

  always @(*) begin
    case(execute_ALU_CTRL)
      AluCtrlEnum_BITWISE : begin
        _zz_execute_REGFILE_WRITE_DATA = execute_IntAluPlugin_bitwise;
      end
      AluCtrlEnum_SLT_SLTU : begin
        _zz_execute_REGFILE_WRITE_DATA = {31'd0, _zz__zz_execute_REGFILE_WRITE_DATA};
      end
      default : begin
        _zz_execute_REGFILE_WRITE_DATA = execute_SRC_ADD_SUB;
      end
    endcase
  end

  always @(*) begin
    case(execute_SRC1_CTRL)
      Src1CtrlEnum_RS : begin
        _zz_execute_SRC1 = execute_RS1;
      end
      Src1CtrlEnum_PC_INCREMENT : begin
        _zz_execute_SRC1 = {29'd0, _zz__zz_execute_SRC1};
      end
      Src1CtrlEnum_IMU : begin
        _zz_execute_SRC1 = {execute_INSTRUCTION[31 : 12],12'h0};
      end
      default : begin
        _zz_execute_SRC1 = {27'd0, _zz__zz_execute_SRC1_1};
      end
    endcase
  end

  assign _zz_execute_SRC2_1 = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_SRC2_2[19] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[18] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[17] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[16] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[15] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[14] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[13] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[12] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[11] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[10] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[9] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[8] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[7] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[6] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[5] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[4] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[3] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[2] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[1] = _zz_execute_SRC2_1;
    _zz_execute_SRC2_2[0] = _zz_execute_SRC2_1;
  end

  assign _zz_execute_SRC2_3 = _zz__zz_execute_SRC2_3[11];
  always @(*) begin
    _zz_execute_SRC2_4[19] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[18] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[17] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[16] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[15] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[14] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[13] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[12] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[11] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[10] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[9] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[8] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[7] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[6] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[5] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[4] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[3] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[2] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[1] = _zz_execute_SRC2_3;
    _zz_execute_SRC2_4[0] = _zz_execute_SRC2_3;
  end

  always @(*) begin
    case(execute_SRC2_CTRL)
      Src2CtrlEnum_RS : begin
        _zz_execute_SRC2_5 = execute_RS2;
      end
      Src2CtrlEnum_IMI : begin
        _zz_execute_SRC2_5 = {_zz_execute_SRC2_2,execute_INSTRUCTION[31 : 20]};
      end
      Src2CtrlEnum_IMS : begin
        _zz_execute_SRC2_5 = {_zz_execute_SRC2_4,{execute_INSTRUCTION[31 : 25],execute_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_execute_SRC2_5 = _zz_execute_SRC2;
      end
    endcase
  end

  assign _zz_execute_SRC3 = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_SRC3_1[19] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[18] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[17] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[16] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[15] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[14] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[13] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[12] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[11] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[10] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[9] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[8] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[7] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[6] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[5] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[4] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[3] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[2] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[1] = _zz_execute_SRC3;
    _zz_execute_SRC3_1[0] = _zz_execute_SRC3;
  end

  always @(*) begin
    case(execute_SRC3_CTRL)
      Src3CtrlEnum_RS : begin
        _zz_execute_SRC3_2 = execute_RS3;
      end
      default : begin
        _zz_execute_SRC3_2 = {_zz_execute_SRC3_1,execute_INSTRUCTION[31 : 20]};
      end
    endcase
  end

  always @(*) begin
    execute_SrcPlugin_addSub = _zz_execute_SrcPlugin_addSub;
    if(execute_SRC2_FORCE_ZERO) begin
      execute_SrcPlugin_addSub = execute_SRC1;
    end
  end

  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign execute_MulPlugin_a = execute_RS1;
  assign execute_MulPlugin_b = execute_RS2;
  assign switch_MulPlugin_l87 = execute_INSTRUCTION[13 : 12];
  always @(*) begin
    case(switch_MulPlugin_l87)
      2'b01 : begin
        execute_MulPlugin_aSigned = 1'b1;
      end
      2'b10 : begin
        execute_MulPlugin_aSigned = 1'b1;
      end
      default : begin
        execute_MulPlugin_aSigned = 1'b0;
      end
    endcase
  end

  always @(*) begin
    case(switch_MulPlugin_l87)
      2'b01 : begin
        execute_MulPlugin_bSigned = 1'b1;
      end
      2'b10 : begin
        execute_MulPlugin_bSigned = 1'b0;
      end
      default : begin
        execute_MulPlugin_bSigned = 1'b0;
      end
    endcase
  end

  assign execute_MulPlugin_aULow = execute_MulPlugin_a[15 : 0];
  assign execute_MulPlugin_bULow = execute_MulPlugin_b[15 : 0];
  assign execute_MulPlugin_aSLow = {1'b0,execute_MulPlugin_a[15 : 0]};
  assign execute_MulPlugin_bSLow = {1'b0,execute_MulPlugin_b[15 : 0]};
  assign execute_MulPlugin_aHigh = {(execute_MulPlugin_aSigned && execute_MulPlugin_a[31]),execute_MulPlugin_a[31 : 16]};
  assign execute_MulPlugin_bHigh = {(execute_MulPlugin_bSigned && execute_MulPlugin_b[31]),execute_MulPlugin_b[31 : 16]};
  assign writeBack_MulPlugin_result = ($signed(_zz_writeBack_MulPlugin_result) + $signed(_zz_writeBack_MulPlugin_result_1));
  assign when_MulPlugin_l147 = (writeBack_arbitration_isValid && writeBack_IS_MUL);
  assign switch_MulPlugin_l148 = writeBack_INSTRUCTION[13 : 12];
  assign execute_FullBarrelShifterPlugin_amplitude = execute_SRC2[4 : 0];
  always @(*) begin
    _zz_execute_FullBarrelShifterPlugin_reversed[0] = execute_SRC1[31];
    _zz_execute_FullBarrelShifterPlugin_reversed[1] = execute_SRC1[30];
    _zz_execute_FullBarrelShifterPlugin_reversed[2] = execute_SRC1[29];
    _zz_execute_FullBarrelShifterPlugin_reversed[3] = execute_SRC1[28];
    _zz_execute_FullBarrelShifterPlugin_reversed[4] = execute_SRC1[27];
    _zz_execute_FullBarrelShifterPlugin_reversed[5] = execute_SRC1[26];
    _zz_execute_FullBarrelShifterPlugin_reversed[6] = execute_SRC1[25];
    _zz_execute_FullBarrelShifterPlugin_reversed[7] = execute_SRC1[24];
    _zz_execute_FullBarrelShifterPlugin_reversed[8] = execute_SRC1[23];
    _zz_execute_FullBarrelShifterPlugin_reversed[9] = execute_SRC1[22];
    _zz_execute_FullBarrelShifterPlugin_reversed[10] = execute_SRC1[21];
    _zz_execute_FullBarrelShifterPlugin_reversed[11] = execute_SRC1[20];
    _zz_execute_FullBarrelShifterPlugin_reversed[12] = execute_SRC1[19];
    _zz_execute_FullBarrelShifterPlugin_reversed[13] = execute_SRC1[18];
    _zz_execute_FullBarrelShifterPlugin_reversed[14] = execute_SRC1[17];
    _zz_execute_FullBarrelShifterPlugin_reversed[15] = execute_SRC1[16];
    _zz_execute_FullBarrelShifterPlugin_reversed[16] = execute_SRC1[15];
    _zz_execute_FullBarrelShifterPlugin_reversed[17] = execute_SRC1[14];
    _zz_execute_FullBarrelShifterPlugin_reversed[18] = execute_SRC1[13];
    _zz_execute_FullBarrelShifterPlugin_reversed[19] = execute_SRC1[12];
    _zz_execute_FullBarrelShifterPlugin_reversed[20] = execute_SRC1[11];
    _zz_execute_FullBarrelShifterPlugin_reversed[21] = execute_SRC1[10];
    _zz_execute_FullBarrelShifterPlugin_reversed[22] = execute_SRC1[9];
    _zz_execute_FullBarrelShifterPlugin_reversed[23] = execute_SRC1[8];
    _zz_execute_FullBarrelShifterPlugin_reversed[24] = execute_SRC1[7];
    _zz_execute_FullBarrelShifterPlugin_reversed[25] = execute_SRC1[6];
    _zz_execute_FullBarrelShifterPlugin_reversed[26] = execute_SRC1[5];
    _zz_execute_FullBarrelShifterPlugin_reversed[27] = execute_SRC1[4];
    _zz_execute_FullBarrelShifterPlugin_reversed[28] = execute_SRC1[3];
    _zz_execute_FullBarrelShifterPlugin_reversed[29] = execute_SRC1[2];
    _zz_execute_FullBarrelShifterPlugin_reversed[30] = execute_SRC1[1];
    _zz_execute_FullBarrelShifterPlugin_reversed[31] = execute_SRC1[0];
  end

  assign execute_FullBarrelShifterPlugin_reversed = ((execute_SHIFT_CTRL == ShiftCtrlEnum_SLL_1) ? _zz_execute_FullBarrelShifterPlugin_reversed : execute_SRC1);
  always @(*) begin
    _zz_decode_RS3_6[0] = memory_SHIFT_RIGHT[31];
    _zz_decode_RS3_6[1] = memory_SHIFT_RIGHT[30];
    _zz_decode_RS3_6[2] = memory_SHIFT_RIGHT[29];
    _zz_decode_RS3_6[3] = memory_SHIFT_RIGHT[28];
    _zz_decode_RS3_6[4] = memory_SHIFT_RIGHT[27];
    _zz_decode_RS3_6[5] = memory_SHIFT_RIGHT[26];
    _zz_decode_RS3_6[6] = memory_SHIFT_RIGHT[25];
    _zz_decode_RS3_6[7] = memory_SHIFT_RIGHT[24];
    _zz_decode_RS3_6[8] = memory_SHIFT_RIGHT[23];
    _zz_decode_RS3_6[9] = memory_SHIFT_RIGHT[22];
    _zz_decode_RS3_6[10] = memory_SHIFT_RIGHT[21];
    _zz_decode_RS3_6[11] = memory_SHIFT_RIGHT[20];
    _zz_decode_RS3_6[12] = memory_SHIFT_RIGHT[19];
    _zz_decode_RS3_6[13] = memory_SHIFT_RIGHT[18];
    _zz_decode_RS3_6[14] = memory_SHIFT_RIGHT[17];
    _zz_decode_RS3_6[15] = memory_SHIFT_RIGHT[16];
    _zz_decode_RS3_6[16] = memory_SHIFT_RIGHT[15];
    _zz_decode_RS3_6[17] = memory_SHIFT_RIGHT[14];
    _zz_decode_RS3_6[18] = memory_SHIFT_RIGHT[13];
    _zz_decode_RS3_6[19] = memory_SHIFT_RIGHT[12];
    _zz_decode_RS3_6[20] = memory_SHIFT_RIGHT[11];
    _zz_decode_RS3_6[21] = memory_SHIFT_RIGHT[10];
    _zz_decode_RS3_6[22] = memory_SHIFT_RIGHT[9];
    _zz_decode_RS3_6[23] = memory_SHIFT_RIGHT[8];
    _zz_decode_RS3_6[24] = memory_SHIFT_RIGHT[7];
    _zz_decode_RS3_6[25] = memory_SHIFT_RIGHT[6];
    _zz_decode_RS3_6[26] = memory_SHIFT_RIGHT[5];
    _zz_decode_RS3_6[27] = memory_SHIFT_RIGHT[4];
    _zz_decode_RS3_6[28] = memory_SHIFT_RIGHT[3];
    _zz_decode_RS3_6[29] = memory_SHIFT_RIGHT[2];
    _zz_decode_RS3_6[30] = memory_SHIFT_RIGHT[1];
    _zz_decode_RS3_6[31] = memory_SHIFT_RIGHT[0];
  end

  always @(*) begin
    case(execute_CG6Ctrlminmax)
      CG6CtrlminmaxEnum_CTRL_MAXU : begin
        execute_CG6Plugin_val_minmax = ((execute_SRC2 < execute_SRC1) ? execute_SRC1 : execute_SRC2);
      end
      default : begin
        execute_CG6Plugin_val_minmax = ((execute_SRC1 < execute_SRC2) ? execute_SRC1 : execute_SRC2);
      end
    endcase
  end

  always @(*) begin
    case(execute_CG6Ctrlsignextend)
      CG6CtrlsignextendEnum_CTRL_SEXTdotB : begin
        execute_CG6Plugin_val_signextend = {(execute_SRC1[7] ? 24'hffffff : 24'h0),execute_SRC1[7 : 0]};
      end
      default : begin
        execute_CG6Plugin_val_signextend = {16'h0,execute_SRC1[15 : 0]};
      end
    endcase
  end

  assign _zz_execute_CG6Plugin_val_ternary = (execute_SRC2 & 32'h0000003f);
  assign _zz_execute_CG6Plugin_val_ternary_1 = ((32'h00000020 <= _zz_execute_CG6Plugin_val_ternary) ? _zz__zz_execute_CG6Plugin_val_ternary_1 : _zz_execute_CG6Plugin_val_ternary);
  assign _zz_execute_CG6Plugin_val_ternary_2 = ((_zz_execute_CG6Plugin_val_ternary_1 == _zz_execute_CG6Plugin_val_ternary) ? execute_SRC1 : execute_SRC3);
  always @(*) begin
    case(execute_CG6Ctrlternary)
      CG6CtrlternaryEnum_CTRL_CMIX : begin
        execute_CG6Plugin_val_ternary = ((execute_SRC1 & execute_SRC2) | (execute_SRC3 & (~ execute_SRC2)));
      end
      CG6CtrlternaryEnum_CTRL_CMOV : begin
        execute_CG6Plugin_val_ternary = ((execute_SRC2 != 32'h0) ? execute_SRC1 : execute_SRC3);
      end
      default : begin
        execute_CG6Plugin_val_ternary = ((_zz_execute_CG6Plugin_val_ternary_1 == 32'h0) ? _zz_execute_CG6Plugin_val_ternary_2 : (_zz_execute_CG6Plugin_val_ternary_3 | _zz_execute_CG6Plugin_val_ternary_4));
      end
    endcase
  end

  always @(*) begin
    case(execute_CG6Ctrl)
      CG6CtrlEnum_CTRL_SH2ADD : begin
        _zz_execute_CG6_FINAL_OUTPUT = _zz__zz_execute_CG6_FINAL_OUTPUT;
      end
      CG6CtrlEnum_CTRL_minmax : begin
        _zz_execute_CG6_FINAL_OUTPUT = execute_CG6Plugin_val_minmax;
      end
      CG6CtrlEnum_CTRL_signextend : begin
        _zz_execute_CG6_FINAL_OUTPUT = execute_CG6Plugin_val_signextend;
      end
      CG6CtrlEnum_CTRL_ternary : begin
        _zz_execute_CG6_FINAL_OUTPUT = execute_CG6Plugin_val_ternary;
      end
      default : begin
        _zz_execute_CG6_FINAL_OUTPUT = {{{execute_SRC1[7 : 0],execute_SRC1[15 : 8]},execute_SRC1[23 : 16]},execute_SRC1[31 : 24]};
      end
    endcase
  end

  assign when_CG6_l489 = (memory_arbitration_isValid && memory_IS_CG6);
  assign _zz_when_UInt_l119 = ({1'b0,execute_SRC1[7 : 0]} + {1'b0,execute_SRC2[7 : 0]});
  assign when_UInt_l119 = (|_zz_when_UInt_l119[8 : 8]);
  always @(*) begin
    if(when_UInt_l119) begin
      _zz_execute_GoblinPlugin_val_pdpikadd8 = 8'hff;
    end else begin
      _zz_execute_GoblinPlugin_val_pdpikadd8 = _zz_when_UInt_l119[7 : 0];
    end
  end

  assign _zz_when_UInt_l119_1 = ({1'b0,execute_SRC1[15 : 8]} + {1'b0,execute_SRC2[15 : 8]});
  assign when_UInt_l119_1 = (|_zz_when_UInt_l119_1[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_1) begin
      _zz_execute_GoblinPlugin_val_pdpikadd8_1 = 8'hff;
    end else begin
      _zz_execute_GoblinPlugin_val_pdpikadd8_1 = _zz_when_UInt_l119_1[7 : 0];
    end
  end

  assign _zz_when_UInt_l119_2 = ({1'b0,execute_SRC1[23 : 16]} + {1'b0,execute_SRC2[23 : 16]});
  assign when_UInt_l119_2 = (|_zz_when_UInt_l119_2[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_2) begin
      _zz_execute_GoblinPlugin_val_pdpikadd8_2 = 8'hff;
    end else begin
      _zz_execute_GoblinPlugin_val_pdpikadd8_2 = _zz_when_UInt_l119_2[7 : 0];
    end
  end

  assign _zz_when_UInt_l119_3 = ({1'b0,execute_SRC1[31 : 24]} + {1'b0,execute_SRC2[31 : 24]});
  assign when_UInt_l119_3 = (|_zz_when_UInt_l119_3[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_3) begin
      _zz_execute_GoblinPlugin_val_pdpikadd8_3 = 8'hff;
    end else begin
      _zz_execute_GoblinPlugin_val_pdpikadd8_3 = _zz_when_UInt_l119_3[7 : 0];
    end
  end

  assign _zz_execute_GoblinPlugin_val_pdpikadd8_4 = {1'b0,execute_SRC1[7 : 0]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_5 = {1'b0,execute_SRC2[7 : 0]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_6 = ($signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_6) - $signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_6_1));
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_7 = {1'b0,execute_SRC1[15 : 8]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_8 = {1'b0,execute_SRC2[15 : 8]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_9 = ($signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_9) - $signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_9_1));
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_10 = {1'b0,execute_SRC1[23 : 16]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_11 = {1'b0,execute_SRC2[23 : 16]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_12 = ($signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_12) - $signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_12_1));
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_13 = {1'b0,execute_SRC1[31 : 24]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_14 = {1'b0,execute_SRC2[31 : 24]};
  assign _zz_execute_GoblinPlugin_val_pdpikadd8_15 = ($signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_15) - $signed(_zz__zz_execute_GoblinPlugin_val_pdpikadd8_15_1));
  always @(*) begin
    case(execute_GoblinCtrlpdpikadd8)
      GoblinCtrlpdpikadd8Enum_CTRL_UKADD8 : begin
        execute_GoblinPlugin_val_pdpikadd8 = {{{_zz_execute_GoblinPlugin_val_pdpikadd8_16,_zz_execute_GoblinPlugin_val_pdpikadd8_18},_zz_execute_GoblinPlugin_val_pdpikadd8_20},_zz_execute_GoblinPlugin_val_pdpikadd8_22};
      end
      default : begin
        execute_GoblinPlugin_val_pdpikadd8 = {{{(_zz_execute_GoblinPlugin_val_pdpikadd8_24 ? _zz_execute_GoblinPlugin_val_pdpikadd8_25 : _zz_execute_GoblinPlugin_val_pdpikadd8_26),(_zz_execute_GoblinPlugin_val_pdpikadd8_28 ? _zz_execute_GoblinPlugin_val_pdpikadd8_29 : _zz_execute_GoblinPlugin_val_pdpikadd8_30)},((_zz_execute_GoblinPlugin_val_pdpikadd8_32 == _zz_execute_GoblinPlugin_val_pdpikadd8_33) ? 8'h0 : (_zz_execute_GoblinPlugin_val_pdpikadd8_34 ? _zz_execute_GoblinPlugin_val_pdpikadd8_35 : _zz_execute_GoblinPlugin_val_pdpikadd8_36))},((_zz_execute_GoblinPlugin_val_pdpikadd8_38 == 1'b1) ? 8'h0 : ((_zz_execute_GoblinPlugin_val_pdpikadd8_39 == _zz_execute_GoblinPlugin_val_pdpikadd8_40) ? 8'hff : _zz_execute_GoblinPlugin_val_pdpikadd8_41))};
      end
    endcase
  end

  assign when_Goblin_l591 = (memory_arbitration_isValid && memory_IS_Goblin);
  assign _zz_execute_Goblin2c_INTERMEDIATE_UFMA8VxV64 = ((execute_INSTRUCTION[26] == 1'b1) ? execute_SRC2[7 : 0] : execute_SRC2[31 : 24]);
  assign _zz_memory_Goblin2c_FINAL_OUTPUT = memory_Goblin2c_INTERMEDIATE_UFMA8VxV64[63 : 32];
  assign _zz_memory_Goblin2c_FINAL_OUTPUT_1 = ({1'b0,memory_Goblin2c_INTERMEDIATE_UFMA8VxV64[7 : 0]} + {1'b0,_zz_memory_Goblin2c_FINAL_OUTPUT[7 : 0]});
  assign when_UInt_l119_4 = (|_zz_memory_Goblin2c_FINAL_OUTPUT_1[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_4) begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_2 = 8'hff;
    end else begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_2 = _zz_memory_Goblin2c_FINAL_OUTPUT_1[7 : 0];
    end
  end

  assign _zz_memory_Goblin2c_FINAL_OUTPUT_3 = ({1'b0,memory_Goblin2c_INTERMEDIATE_UFMA8VxV64[15 : 8]} + {1'b0,_zz_memory_Goblin2c_FINAL_OUTPUT[15 : 8]});
  assign when_UInt_l119_5 = (|_zz_memory_Goblin2c_FINAL_OUTPUT_3[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_5) begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_4 = 8'hff;
    end else begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_4 = _zz_memory_Goblin2c_FINAL_OUTPUT_3[7 : 0];
    end
  end

  assign _zz_memory_Goblin2c_FINAL_OUTPUT_5 = ({1'b0,memory_Goblin2c_INTERMEDIATE_UFMA8VxV64[23 : 16]} + {1'b0,_zz_memory_Goblin2c_FINAL_OUTPUT[23 : 16]});
  assign when_UInt_l119_6 = (|_zz_memory_Goblin2c_FINAL_OUTPUT_5[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_6) begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_6 = 8'hff;
    end else begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_6 = _zz_memory_Goblin2c_FINAL_OUTPUT_5[7 : 0];
    end
  end

  assign _zz_memory_Goblin2c_FINAL_OUTPUT_7 = ({1'b0,memory_Goblin2c_INTERMEDIATE_UFMA8VxV64[31 : 24]} + {1'b0,_zz_memory_Goblin2c_FINAL_OUTPUT[31 : 24]});
  assign when_UInt_l119_7 = (|_zz_memory_Goblin2c_FINAL_OUTPUT_7[8 : 8]);
  always @(*) begin
    if(when_UInt_l119_7) begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_8 = 8'hff;
    end else begin
      _zz_memory_Goblin2c_FINAL_OUTPUT_8 = _zz_memory_Goblin2c_FINAL_OUTPUT_7[7 : 0];
    end
  end

  assign when_Goblin2c_l115 = (writeBack_arbitration_isValid && writeBack_IS_Goblin2c);
  always @(*) begin
    HazardSimplePlugin_src0Hazard = 1'b0;
    if(when_HazardSimplePlugin_l91) begin
      if(when_HazardSimplePlugin_l92) begin
        if(when_HazardSimplePlugin_l93) begin
          HazardSimplePlugin_src0Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l91_1) begin
      if(when_HazardSimplePlugin_l92_1) begin
        if(when_HazardSimplePlugin_l93_1) begin
          HazardSimplePlugin_src0Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l91_2) begin
      if(when_HazardSimplePlugin_l92_2) begin
        if(when_HazardSimplePlugin_l93_2) begin
          HazardSimplePlugin_src0Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l152) begin
      HazardSimplePlugin_src0Hazard = 1'b0;
    end
  end

  always @(*) begin
    HazardSimplePlugin_src1Hazard = 1'b0;
    if(when_HazardSimplePlugin_l91) begin
      if(when_HazardSimplePlugin_l92) begin
        if(when_HazardSimplePlugin_l96) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
        if(when_HazardSimplePlugin_l99) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l91_1) begin
      if(when_HazardSimplePlugin_l92_1) begin
        if(when_HazardSimplePlugin_l96_1) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
        if(when_HazardSimplePlugin_l99_1) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l91_2) begin
      if(when_HazardSimplePlugin_l92_2) begin
        if(when_HazardSimplePlugin_l96_2) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
        if(when_HazardSimplePlugin_l99_2) begin
          HazardSimplePlugin_src1Hazard = 1'b1;
        end
      end
    end
    if(when_HazardSimplePlugin_l155) begin
      HazardSimplePlugin_src1Hazard = 1'b0;
    end
  end

  always @(*) begin
    HazardSimplePlugin_src2Hazard = 1'b0;
    if(when_HazardSimplePlugin_l158) begin
      HazardSimplePlugin_src2Hazard = 1'b0;
    end
  end

  assign HazardSimplePlugin_notAES = ((! ((_zz_writeBack_RegFileOddEvenPlugin_rdIndex & 32'h3200707f) == 32'h32000033)) && (! ((_zz_writeBack_RegFileOddEvenPlugin_rdIndex & 32'h3a00707f) == 32'h30000033)));
  assign HazardSimplePlugin_rdIndex = (HazardSimplePlugin_notAES ? _zz_writeBack_RegFileOddEvenPlugin_rdIndex[11 : 7] : _zz_writeBack_RegFileOddEvenPlugin_rdIndex[19 : 15]);
  assign HazardSimplePlugin_regFileReadAddress3 = ((decode_INSTRUCTION[6 : 0] == 7'h77) ? decode_INSTRUCTION[11 : 7] : decode_INSTRUCTION[31 : 27]);
  assign HazardSimplePlugin_writeBackWrites_valid = (_zz_lastStageRegFileWrite_valid_1 && writeBack_arbitration_isFiring);
  assign HazardSimplePlugin_writeBackWrites_payload_address = HazardSimplePlugin_rdIndex;
  assign HazardSimplePlugin_writeBackWrites_payload_data = _zz_decode_RS3_5;
  assign HazardSimplePlugin_addr0Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[19 : 15]);
  assign HazardSimplePlugin_addr1Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[24 : 20]);
  assign HazardSimplePlugin_addr2Match = (HazardSimplePlugin_writeBackBuffer_payload_address == HazardSimplePlugin_regFileReadAddress3);
  assign _zz_when_HazardSimplePlugin_l79 = ((((writeBack_INSTRUCTION & 32'he400707f) == 32'ha0000077) || ((writeBack_INSTRUCTION & 32'h000070ff) == 32'h00003003)) || ((writeBack_INSTRUCTION & 32'h000070ff) == 32'h00007003));
  assign _zz_when_HazardSimplePlugin_l64 = (((! ((writeBack_INSTRUCTION & 32'h3200707f) == 32'h32000033)) && (! ((writeBack_INSTRUCTION & 32'h3a00707f) == 32'h30000033))) ? writeBack_INSTRUCTION[11 : 7] : writeBack_INSTRUCTION[19 : 15]);
  assign _zz_when_HazardSimplePlugin_l79_1 = (_zz_when_HazardSimplePlugin_l79 ? (_zz_when_HazardSimplePlugin_l64 ^ 5'h01) : 5'h0);
  assign _zz_when_HazardSimplePlugin_l70 = ((decode_INSTRUCTION[6 : 0] == 7'h77) ? decode_INSTRUCTION[11 : 7] : (((decode_INSTRUCTION & 32'h0010707f) == 32'h00003023) ? (decode_INSTRUCTION[24 : 20] ^ 5'h01) : decode_INSTRUCTION[31 : 27]));
  assign when_HazardSimplePlugin_l63 = 1'b1;
  assign when_HazardSimplePlugin_l64 = ((_zz_when_HazardSimplePlugin_l64 != 5'h0) && (_zz_when_HazardSimplePlugin_l64 == decode_INSTRUCTION[19 : 15]));
  assign when_HazardSimplePlugin_l67 = ((_zz_when_HazardSimplePlugin_l64 != 5'h0) && (_zz_when_HazardSimplePlugin_l64 == decode_INSTRUCTION[24 : 20]));
  assign when_HazardSimplePlugin_l70 = ((_zz_when_HazardSimplePlugin_l64 != 5'h0) && (_zz_when_HazardSimplePlugin_l64 == _zz_when_HazardSimplePlugin_l70));
  assign when_HazardSimplePlugin_l79 = ((_zz_when_HazardSimplePlugin_l79_1 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_1 == decode_INSTRUCTION[19 : 15]));
  assign when_HazardSimplePlugin_l82 = ((_zz_when_HazardSimplePlugin_l79_1 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_1 == decode_INSTRUCTION[24 : 20]));
  assign when_HazardSimplePlugin_l85 = ((_zz_when_HazardSimplePlugin_l79_1 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_1 == _zz_when_HazardSimplePlugin_l70));
  assign when_HazardSimplePlugin_l61 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l76 = ((writeBack_arbitration_isValid && _zz_when_HazardSimplePlugin_l79) && writeBack_REGFILE_WRITE_VALID_ODD);
  assign when_HazardSimplePlugin_l91 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l92 = (1'b0 || (! when_HazardSimplePlugin_l63));
  assign when_HazardSimplePlugin_l93 = (when_HazardSimplePlugin_l64 || when_HazardSimplePlugin_l79);
  assign when_HazardSimplePlugin_l96 = (when_HazardSimplePlugin_l67 || when_HazardSimplePlugin_l82);
  assign when_HazardSimplePlugin_l99 = (when_HazardSimplePlugin_l70 || when_HazardSimplePlugin_l85);
  assign _zz_when_HazardSimplePlugin_l79_2 = ((((memory_INSTRUCTION & 32'he400707f) == 32'ha0000077) || ((memory_INSTRUCTION & 32'h000070ff) == 32'h00003003)) || ((memory_INSTRUCTION & 32'h000070ff) == 32'h00007003));
  assign _zz_when_HazardSimplePlugin_l64_1 = (((! ((memory_INSTRUCTION & 32'h3200707f) == 32'h32000033)) && (! ((memory_INSTRUCTION & 32'h3a00707f) == 32'h30000033))) ? memory_INSTRUCTION[11 : 7] : memory_INSTRUCTION[19 : 15]);
  assign _zz_when_HazardSimplePlugin_l79_3 = (_zz_when_HazardSimplePlugin_l79_2 ? (_zz_when_HazardSimplePlugin_l64_1 ^ 5'h01) : 5'h0);
  assign _zz_when_HazardSimplePlugin_l70_1 = ((decode_INSTRUCTION[6 : 0] == 7'h77) ? decode_INSTRUCTION[11 : 7] : (((decode_INSTRUCTION & 32'h0010707f) == 32'h00003023) ? (decode_INSTRUCTION[24 : 20] ^ 5'h01) : decode_INSTRUCTION[31 : 27]));
  assign when_HazardSimplePlugin_l64_1 = ((_zz_when_HazardSimplePlugin_l64_1 != 5'h0) && (_zz_when_HazardSimplePlugin_l64_1 == decode_INSTRUCTION[19 : 15]));
  assign when_HazardSimplePlugin_l67_1 = ((_zz_when_HazardSimplePlugin_l64_1 != 5'h0) && (_zz_when_HazardSimplePlugin_l64_1 == decode_INSTRUCTION[24 : 20]));
  assign when_HazardSimplePlugin_l70_1 = ((_zz_when_HazardSimplePlugin_l64_1 != 5'h0) && (_zz_when_HazardSimplePlugin_l64_1 == _zz_when_HazardSimplePlugin_l70_1));
  assign when_HazardSimplePlugin_l79_1 = ((_zz_when_HazardSimplePlugin_l79_3 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_3 == decode_INSTRUCTION[19 : 15]));
  assign when_HazardSimplePlugin_l82_1 = ((_zz_when_HazardSimplePlugin_l79_3 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_3 == decode_INSTRUCTION[24 : 20]));
  assign when_HazardSimplePlugin_l85_1 = ((_zz_when_HazardSimplePlugin_l79_3 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_3 == _zz_when_HazardSimplePlugin_l70_1));
  assign when_HazardSimplePlugin_l61_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l76_1 = ((memory_arbitration_isValid && _zz_when_HazardSimplePlugin_l79_2) && memory_REGFILE_WRITE_VALID_ODD);
  assign when_HazardSimplePlugin_l91_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l92_1 = (1'b0 || (! memory_BYPASSABLE_MEMORY_STAGE));
  assign when_HazardSimplePlugin_l93_1 = (when_HazardSimplePlugin_l64_1 || when_HazardSimplePlugin_l79_1);
  assign when_HazardSimplePlugin_l96_1 = (when_HazardSimplePlugin_l67_1 || when_HazardSimplePlugin_l82_1);
  assign when_HazardSimplePlugin_l99_1 = (when_HazardSimplePlugin_l70_1 || when_HazardSimplePlugin_l85_1);
  assign _zz_when_HazardSimplePlugin_l79_4 = ((((execute_INSTRUCTION & 32'he400707f) == 32'ha0000077) || ((execute_INSTRUCTION & 32'h000070ff) == 32'h00003003)) || ((execute_INSTRUCTION & 32'h000070ff) == 32'h00007003));
  assign _zz_when_HazardSimplePlugin_l64_2 = (((! ((execute_INSTRUCTION & 32'h3200707f) == 32'h32000033)) && (! ((execute_INSTRUCTION & 32'h3a00707f) == 32'h30000033))) ? execute_INSTRUCTION[11 : 7] : execute_INSTRUCTION[19 : 15]);
  assign _zz_when_HazardSimplePlugin_l79_5 = (_zz_when_HazardSimplePlugin_l79_4 ? (_zz_when_HazardSimplePlugin_l64_2 ^ 5'h01) : 5'h0);
  assign _zz_when_HazardSimplePlugin_l70_2 = ((decode_INSTRUCTION[6 : 0] == 7'h77) ? decode_INSTRUCTION[11 : 7] : (((decode_INSTRUCTION & 32'h0010707f) == 32'h00003023) ? (decode_INSTRUCTION[24 : 20] ^ 5'h01) : decode_INSTRUCTION[31 : 27]));
  assign when_HazardSimplePlugin_l64_2 = ((_zz_when_HazardSimplePlugin_l64_2 != 5'h0) && (_zz_when_HazardSimplePlugin_l64_2 == decode_INSTRUCTION[19 : 15]));
  assign when_HazardSimplePlugin_l67_2 = ((_zz_when_HazardSimplePlugin_l64_2 != 5'h0) && (_zz_when_HazardSimplePlugin_l64_2 == decode_INSTRUCTION[24 : 20]));
  assign when_HazardSimplePlugin_l70_2 = ((_zz_when_HazardSimplePlugin_l64_2 != 5'h0) && (_zz_when_HazardSimplePlugin_l64_2 == _zz_when_HazardSimplePlugin_l70_2));
  assign when_HazardSimplePlugin_l79_2 = ((_zz_when_HazardSimplePlugin_l79_5 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_5 == decode_INSTRUCTION[19 : 15]));
  assign when_HazardSimplePlugin_l82_2 = ((_zz_when_HazardSimplePlugin_l79_5 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_5 == decode_INSTRUCTION[24 : 20]));
  assign when_HazardSimplePlugin_l85_2 = ((_zz_when_HazardSimplePlugin_l79_5 != 5'h0) && (_zz_when_HazardSimplePlugin_l79_5 == _zz_when_HazardSimplePlugin_l70_2));
  assign when_HazardSimplePlugin_l61_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l76_2 = ((execute_arbitration_isValid && _zz_when_HazardSimplePlugin_l79_4) && execute_REGFILE_WRITE_VALID_ODD);
  assign when_HazardSimplePlugin_l91_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
  assign when_HazardSimplePlugin_l92_2 = (1'b0 || (! execute_BYPASSABLE_EXECUTE_STAGE));
  assign when_HazardSimplePlugin_l93_2 = (when_HazardSimplePlugin_l64_2 || when_HazardSimplePlugin_l79_2);
  assign when_HazardSimplePlugin_l96_2 = (when_HazardSimplePlugin_l67_2 || when_HazardSimplePlugin_l82_2);
  assign when_HazardSimplePlugin_l99_2 = (when_HazardSimplePlugin_l70_2 || when_HazardSimplePlugin_l85_2);
  assign when_HazardSimplePlugin_l152 = (! decode_RS1_USE);
  assign when_HazardSimplePlugin_l155 = (! decode_RS2_USE);
  assign when_HazardSimplePlugin_l158 = (! decode_RS3_USE);
  assign when_HazardSimplePlugin_l163 = (decode_arbitration_isValid && ((HazardSimplePlugin_src0Hazard || HazardSimplePlugin_src1Hazard) || HazardSimplePlugin_src2Hazard));
  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign switch_Misc_l211_1 = execute_INSTRUCTION[14 : 12];
  always @(*) begin
    casez(switch_Misc_l211_1)
      3'b000 : begin
        _zz_execute_BRANCH_COND_RESULT = execute_BranchPlugin_eq;
      end
      3'b001 : begin
        _zz_execute_BRANCH_COND_RESULT = (! execute_BranchPlugin_eq);
      end
      3'b1?1 : begin
        _zz_execute_BRANCH_COND_RESULT = (! execute_SRC_LESS);
      end
      default : begin
        _zz_execute_BRANCH_COND_RESULT = execute_SRC_LESS;
      end
    endcase
  end

  always @(*) begin
    case(execute_BRANCH_CTRL)
      BranchCtrlEnum_INC : begin
        _zz_execute_BRANCH_COND_RESULT_1 = 1'b0;
      end
      BranchCtrlEnum_JAL : begin
        _zz_execute_BRANCH_COND_RESULT_1 = 1'b1;
      end
      BranchCtrlEnum_JALR : begin
        _zz_execute_BRANCH_COND_RESULT_1 = 1'b1;
      end
      default : begin
        _zz_execute_BRANCH_COND_RESULT_1 = _zz_execute_BRANCH_COND_RESULT;
      end
    endcase
  end

  assign _zz_execute_BranchPlugin_missAlignedTarget = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_BranchPlugin_missAlignedTarget_1[19] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[18] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[17] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[16] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[15] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[14] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[13] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[12] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[11] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[10] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[9] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[8] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[7] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[6] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[5] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[4] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[3] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[2] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[1] = _zz_execute_BranchPlugin_missAlignedTarget;
    _zz_execute_BranchPlugin_missAlignedTarget_1[0] = _zz_execute_BranchPlugin_missAlignedTarget;
  end

  assign _zz_execute_BranchPlugin_missAlignedTarget_2 = _zz__zz_execute_BranchPlugin_missAlignedTarget_2[19];
  always @(*) begin
    _zz_execute_BranchPlugin_missAlignedTarget_3[10] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[9] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[8] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[7] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[6] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[5] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[4] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[3] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[2] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[1] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    _zz_execute_BranchPlugin_missAlignedTarget_3[0] = _zz_execute_BranchPlugin_missAlignedTarget_2;
  end

  assign _zz_execute_BranchPlugin_missAlignedTarget_4 = _zz__zz_execute_BranchPlugin_missAlignedTarget_4[11];
  always @(*) begin
    _zz_execute_BranchPlugin_missAlignedTarget_5[18] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[17] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[16] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[15] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[14] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[13] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[12] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[11] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[10] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[9] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[8] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[7] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[6] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[5] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[4] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[3] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[2] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[1] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    _zz_execute_BranchPlugin_missAlignedTarget_5[0] = _zz_execute_BranchPlugin_missAlignedTarget_4;
  end

  always @(*) begin
    case(execute_BRANCH_CTRL)
      BranchCtrlEnum_JALR : begin
        _zz_execute_BranchPlugin_missAlignedTarget_6 = (_zz__zz_execute_BranchPlugin_missAlignedTarget_6[1] ^ execute_RS1[1]);
      end
      BranchCtrlEnum_JAL : begin
        _zz_execute_BranchPlugin_missAlignedTarget_6 = _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1[1];
      end
      default : begin
        _zz_execute_BranchPlugin_missAlignedTarget_6 = _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2[1];
      end
    endcase
  end

  assign execute_BranchPlugin_missAlignedTarget = (execute_BRANCH_COND_RESULT && _zz_execute_BranchPlugin_missAlignedTarget_6);
  always @(*) begin
    case(execute_BRANCH_CTRL)
      BranchCtrlEnum_JALR : begin
        execute_BranchPlugin_branch_src1 = execute_RS1;
      end
      default : begin
        execute_BranchPlugin_branch_src1 = execute_PC;
      end
    endcase
  end

  assign _zz_execute_BranchPlugin_branch_src2 = execute_INSTRUCTION[31];
  always @(*) begin
    _zz_execute_BranchPlugin_branch_src2_1[19] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[18] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[17] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[16] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[15] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[14] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[13] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[12] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[11] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[10] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[9] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[8] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[7] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[6] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[5] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[4] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[3] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[2] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[1] = _zz_execute_BranchPlugin_branch_src2;
    _zz_execute_BranchPlugin_branch_src2_1[0] = _zz_execute_BranchPlugin_branch_src2;
  end

  always @(*) begin
    case(execute_BRANCH_CTRL)
      BranchCtrlEnum_JALR : begin
        execute_BranchPlugin_branch_src2 = {_zz_execute_BranchPlugin_branch_src2_1,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        execute_BranchPlugin_branch_src2 = ((execute_BRANCH_CTRL == BranchCtrlEnum_JAL) ? {{_zz_execute_BranchPlugin_branch_src2_3,{{{_zz_execute_BranchPlugin_branch_src2_6,execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_execute_BranchPlugin_branch_src2_5,{{{_zz_execute_BranchPlugin_branch_src2_7,_zz_execute_BranchPlugin_branch_src2_8},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0});
        if(execute_PREDICTION_HAD_BRANCHED2) begin
          execute_BranchPlugin_branch_src2 = {29'd0, _zz_execute_BranchPlugin_branch_src2_9};
        end
      end
    endcase
  end

  assign _zz_execute_BranchPlugin_branch_src2_2 = _zz__zz_execute_BranchPlugin_branch_src2_2[19];
  always @(*) begin
    _zz_execute_BranchPlugin_branch_src2_3[10] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[9] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[8] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[7] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[6] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[5] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[4] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[3] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[2] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[1] = _zz_execute_BranchPlugin_branch_src2_2;
    _zz_execute_BranchPlugin_branch_src2_3[0] = _zz_execute_BranchPlugin_branch_src2_2;
  end

  assign _zz_execute_BranchPlugin_branch_src2_4 = _zz__zz_execute_BranchPlugin_branch_src2_4[11];
  always @(*) begin
    _zz_execute_BranchPlugin_branch_src2_5[18] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[17] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[16] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[15] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[14] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[13] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[12] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[11] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[10] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[9] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[8] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[7] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[6] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[5] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[4] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[3] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[2] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[1] = _zz_execute_BranchPlugin_branch_src2_4;
    _zz_execute_BranchPlugin_branch_src2_5[0] = _zz_execute_BranchPlugin_branch_src2_4;
  end

  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign BranchPlugin_jumpInterface_valid = ((memory_arbitration_isValid && memory_BRANCH_DO) && (! 1'b0));
  assign BranchPlugin_jumpInterface_payload = memory_BRANCH_CALC;
  assign IBusCachedPlugin_decodePrediction_rsp_wasWrong = BranchPlugin_jumpInterface_valid;
  assign when_Pipeline_l124 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_1 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_2 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_3 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_4 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_5 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_6 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_7 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_8 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_9 = (! execute_arbitration_isStuck);
  assign _zz_decode_to_execute_SRC1_CTRL_1 = decode_SRC1_CTRL;
  assign _zz_decode_SRC1_CTRL = _zz_decode_SRC1_CTRL_1;
  assign when_Pipeline_l124_10 = (! execute_arbitration_isStuck);
  assign _zz_execute_SRC1_CTRL = decode_to_execute_SRC1_CTRL;
  assign when_Pipeline_l124_11 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_12 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_13 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_14 = (! writeBack_arbitration_isStuck);
  assign _zz_decode_to_execute_ALU_CTRL_1 = decode_ALU_CTRL;
  assign _zz_decode_ALU_CTRL = _zz_decode_ALU_CTRL_1;
  assign when_Pipeline_l124_15 = (! execute_arbitration_isStuck);
  assign _zz_execute_ALU_CTRL = decode_to_execute_ALU_CTRL;
  assign _zz_decode_to_execute_SRC2_CTRL_1 = decode_SRC2_CTRL;
  assign _zz_decode_SRC2_CTRL = _zz_decode_SRC2_CTRL_1;
  assign when_Pipeline_l124_16 = (! execute_arbitration_isStuck);
  assign _zz_execute_SRC2_CTRL = decode_to_execute_SRC2_CTRL;
  assign when_Pipeline_l124_17 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_18 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_19 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_20 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_21 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_22 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_23 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_24 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_25 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_26 = (! writeBack_arbitration_isStuck);
  assign _zz_decode_to_execute_SRC3_CTRL_1 = decode_SRC3_CTRL;
  assign _zz_decode_SRC3_CTRL = _zz_decode_SRC3_CTRL_1;
  assign when_Pipeline_l124_27 = (! execute_arbitration_isStuck);
  assign _zz_execute_SRC3_CTRL = decode_to_execute_SRC3_CTRL;
  assign when_Pipeline_l124_28 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_29 = (! execute_arbitration_isStuck);
  assign _zz_decode_to_execute_ALU_BITWISE_CTRL_1 = decode_ALU_BITWISE_CTRL;
  assign _zz_decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL_1;
  assign when_Pipeline_l124_30 = (! execute_arbitration_isStuck);
  assign _zz_execute_ALU_BITWISE_CTRL = decode_to_execute_ALU_BITWISE_CTRL;
  assign when_Pipeline_l124_31 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_32 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_33 = (! writeBack_arbitration_isStuck);
  assign _zz_decode_to_execute_SHIFT_CTRL_1 = decode_SHIFT_CTRL;
  assign _zz_execute_to_memory_SHIFT_CTRL_1 = execute_SHIFT_CTRL;
  assign _zz_decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL_1;
  assign when_Pipeline_l124_34 = (! execute_arbitration_isStuck);
  assign _zz_execute_SHIFT_CTRL = decode_to_execute_SHIFT_CTRL;
  assign when_Pipeline_l124_35 = (! memory_arbitration_isStuck);
  assign _zz_memory_SHIFT_CTRL = execute_to_memory_SHIFT_CTRL;
  assign when_Pipeline_l124_36 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_37 = (! memory_arbitration_isStuck);
  assign _zz_decode_to_execute_CG6Ctrl_1 = decode_CG6Ctrl;
  assign _zz_decode_CG6Ctrl = _zz_decode_CG6Ctrl_1;
  assign when_Pipeline_l124_38 = (! execute_arbitration_isStuck);
  assign _zz_execute_CG6Ctrl = decode_to_execute_CG6Ctrl;
  assign _zz_decode_to_execute_CG6Ctrlminmax_1 = decode_CG6Ctrlminmax;
  assign _zz_decode_CG6Ctrlminmax = _zz_decode_CG6Ctrlminmax_1;
  assign when_Pipeline_l124_39 = (! execute_arbitration_isStuck);
  assign _zz_execute_CG6Ctrlminmax = decode_to_execute_CG6Ctrlminmax;
  assign _zz_decode_to_execute_CG6Ctrlsignextend_1 = decode_CG6Ctrlsignextend;
  assign _zz_decode_CG6Ctrlsignextend = _zz_decode_CG6Ctrlsignextend_1;
  assign when_Pipeline_l124_40 = (! execute_arbitration_isStuck);
  assign _zz_execute_CG6Ctrlsignextend = decode_to_execute_CG6Ctrlsignextend;
  assign _zz_decode_to_execute_CG6Ctrlternary_1 = decode_CG6Ctrlternary;
  assign _zz_decode_CG6Ctrlternary = _zz_decode_CG6Ctrlternary_1;
  assign when_Pipeline_l124_41 = (! execute_arbitration_isStuck);
  assign _zz_execute_CG6Ctrlternary = decode_to_execute_CG6Ctrlternary;
  assign when_Pipeline_l124_42 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_43 = (! memory_arbitration_isStuck);
  assign _zz_decode_to_execute_GoblinCtrlpdpikadd8_1 = decode_GoblinCtrlpdpikadd8;
  assign _zz_decode_GoblinCtrlpdpikadd8 = _zz_decode_GoblinCtrlpdpikadd8_1;
  assign when_Pipeline_l124_44 = (! execute_arbitration_isStuck);
  assign _zz_execute_GoblinCtrlpdpikadd8 = decode_to_execute_GoblinCtrlpdpikadd8;
  assign when_Pipeline_l124_45 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_46 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_47 = (! writeBack_arbitration_isStuck);
  assign _zz_decode_to_execute_BRANCH_CTRL_1 = decode_BRANCH_CTRL;
  assign _zz_decode_BRANCH_CTRL_1 = _zz_decode_BRANCH_CTRL;
  assign when_Pipeline_l124_48 = (! execute_arbitration_isStuck);
  assign _zz_execute_BRANCH_CTRL = decode_to_execute_BRANCH_CTRL;
  assign when_Pipeline_l124_49 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_50 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_51 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_52 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_53 = (! execute_arbitration_isStuck);
  assign when_Pipeline_l124_54 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_55 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_56 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_57 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_58 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_59 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_60 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_61 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_62 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_63 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_64 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_65 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_66 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_67 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_68 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_69 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_70 = (! memory_arbitration_isStuck);
  assign when_Pipeline_l124_71 = (! writeBack_arbitration_isStuck);
  assign when_Pipeline_l124_72 = (! writeBack_arbitration_isStuck);
  assign decode_arbitration_isFlushed = (({writeBack_arbitration_flushNext,{memory_arbitration_flushNext,execute_arbitration_flushNext}} != 3'b000) || ({writeBack_arbitration_flushIt,{memory_arbitration_flushIt,{execute_arbitration_flushIt,decode_arbitration_flushIt}}} != 4'b0000));
  assign execute_arbitration_isFlushed = (({writeBack_arbitration_flushNext,memory_arbitration_flushNext} != 2'b00) || ({writeBack_arbitration_flushIt,{memory_arbitration_flushIt,execute_arbitration_flushIt}} != 3'b000));
  assign memory_arbitration_isFlushed = ((writeBack_arbitration_flushNext != 1'b0) || ({writeBack_arbitration_flushIt,memory_arbitration_flushIt} != 2'b00));
  assign writeBack_arbitration_isFlushed = (1'b0 || (writeBack_arbitration_flushIt != 1'b0));
  assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
  assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
  assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
  assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
  assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
  assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
  assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
  assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
  assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
  assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
  assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
  assign when_Pipeline_l151 = ((! execute_arbitration_isStuck) || execute_arbitration_removeIt);
  assign when_Pipeline_l154 = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign when_Pipeline_l151_1 = ((! memory_arbitration_isStuck) || memory_arbitration_removeIt);
  assign when_Pipeline_l154_1 = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign when_Pipeline_l151_2 = ((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt);
  assign when_Pipeline_l154_2 = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign iBusWishbone_ADR = {_zz_iBusWishbone_ADR_1,_zz_iBusWishbone_ADR};
  assign iBusWishbone_CTI = ((_zz_iBusWishbone_ADR == 2'b11) ? 3'b111 : 3'b010);
  assign iBusWishbone_BTE = 2'b00;
  assign iBusWishbone_SEL = 4'b1111;
  assign iBusWishbone_WE = 1'b0;
  assign iBusWishbone_DAT_MOSI = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
  always @(*) begin
    iBusWishbone_CYC = 1'b0;
    if(when_InstructionCache_l239) begin
      iBusWishbone_CYC = 1'b1;
    end
  end

  always @(*) begin
    iBusWishbone_STB = 1'b0;
    if(when_InstructionCache_l239) begin
      iBusWishbone_STB = 1'b1;
    end
  end

  assign when_InstructionCache_l239 = (iBus_cmd_valid || (_zz_iBusWishbone_ADR != 2'b00));
  assign iBus_cmd_ready = (iBus_cmd_valid && iBusWishbone_ACK);
  assign iBus_rsp_valid = _zz_iBus_rsp_valid;
  assign iBus_rsp_payload_data = iBusWishbone_DAT_MISO_regNext;
  assign iBus_rsp_payload_error = 1'b0;
  assign _zz_dBus_cmd_ready_3 = (dBus_cmd_payload_size == 3'b100);
  assign _zz_dBus_cmd_ready = dBus_cmd_valid;
  assign _zz_dBus_cmd_ready_1 = dBus_cmd_payload_wr;
  assign _zz_dBus_cmd_ready_2 = ((! _zz_dBus_cmd_ready_3) || 1'b1);
  assign dBus_cmd_ready = ((_zz_dBus_cmd_ready && dBusWishbone_ACK) && (_zz_dBus_cmd_ready_1 || _zz_dBus_cmd_ready_2));
  assign dBusWishbone_ADR = ((_zz_dBus_cmd_ready_3 ? {dBus_cmd_payload_address[31 : 4],4'b0000} : {dBus_cmd_payload_address[31 : 4],4'b0000}) >>> 4);
  assign dBusWishbone_CTI = (_zz_dBus_cmd_ready_3 ? (_zz_dBus_cmd_ready_2 ? 3'b111 : 3'b010) : 3'b000);
  assign dBusWishbone_BTE = 2'b00;
  assign dBusWishbone_SEL = (_zz_dBus_cmd_ready_1 ? dBus_cmd_payload_mask : 16'hffff);
  assign dBusWishbone_WE = _zz_dBus_cmd_ready_1;
  assign dBusWishbone_DAT_MOSI = dBus_cmd_payload_data;
  assign dBusWishbone_CYC = _zz_dBus_cmd_ready;
  assign dBusWishbone_STB = _zz_dBus_cmd_ready;
  assign dBus_rsp_valid = _zz_dBus_rsp_valid;
  assign dBus_rsp_payload_data = dBusWishbone_DAT_MISO_regNext;
  assign dBus_rsp_payload_error = 1'b0;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      IBusCachedPlugin_fetchPc_pcReg <= 32'h00410000;
      IBusCachedPlugin_fetchPc_correctionReg <= 1'b0;
      IBusCachedPlugin_fetchPc_booted <= 1'b0;
      IBusCachedPlugin_fetchPc_inc <= 1'b0;
      _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_2 <= 1'b0;
      _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      IBusCachedPlugin_rspCounter <= 32'h0;
      dataCache_1_io_mem_cmd_rValid <= 1'b0;
      dBus_rsp_regNext_valid <= 1'b0;
      DBusCachedPlugin_rspCounter <= 32'h0;
      _zz_8 <= 1'b1;
      HazardSimplePlugin_writeBackBuffer_valid <= 1'b0;
      execute_arbitration_isValid <= 1'b0;
      memory_arbitration_isValid <= 1'b0;
      writeBack_arbitration_isValid <= 1'b0;
      _zz_iBusWishbone_ADR <= 2'b00;
      _zz_iBus_rsp_valid <= 1'b0;
      _zz_dBus_rsp_valid <= 1'b0;
    end else begin
      if(IBusCachedPlugin_fetchPc_correction) begin
        IBusCachedPlugin_fetchPc_correctionReg <= 1'b1;
      end
      if(IBusCachedPlugin_fetchPc_output_fire) begin
        IBusCachedPlugin_fetchPc_correctionReg <= 1'b0;
      end
      IBusCachedPlugin_fetchPc_booted <= 1'b1;
      if(when_Fetcher_l134) begin
        IBusCachedPlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusCachedPlugin_fetchPc_output_fire_1) begin
        IBusCachedPlugin_fetchPc_inc <= 1'b1;
      end
      if(when_Fetcher_l134_1) begin
        IBusCachedPlugin_fetchPc_inc <= 1'b0;
      end
      if(when_Fetcher_l161) begin
        IBusCachedPlugin_fetchPc_pcReg <= IBusCachedPlugin_fetchPc_pc;
      end
      if(IBusCachedPlugin_iBusRsp_flush) begin
        _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_2 <= 1'b0;
      end
      if(_zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready) begin
        _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready_2 <= (IBusCachedPlugin_iBusRsp_stages_0_output_valid && (! 1'b0));
      end
      if(IBusCachedPlugin_iBusRsp_flush) begin
        _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
      end
      if(IBusCachedPlugin_iBusRsp_stages_1_output_ready) begin
        _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= (IBusCachedPlugin_iBusRsp_stages_1_output_valid && (! IBusCachedPlugin_iBusRsp_flush));
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if(when_Fetcher_l332) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if(when_Fetcher_l332_1) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= IBusCachedPlugin_injector_nextPcCalc_valids_0;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if(when_Fetcher_l332_2) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= IBusCachedPlugin_injector_nextPcCalc_valids_1;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      end
      if(when_Fetcher_l332_3) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= IBusCachedPlugin_injector_nextPcCalc_valids_2;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      end
      if(when_Fetcher_l332_4) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= IBusCachedPlugin_injector_nextPcCalc_valids_3;
      end
      if(IBusCachedPlugin_fetchPc_flushed) begin
        IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
      end
      if(iBus_rsp_valid) begin
        IBusCachedPlugin_rspCounter <= (IBusCachedPlugin_rspCounter + 32'h00000001);
      end
      if(dataCache_1_io_mem_cmd_valid) begin
        dataCache_1_io_mem_cmd_rValid <= 1'b1;
      end
      if(dataCache_1_io_mem_cmd_s2mPipe_ready) begin
        dataCache_1_io_mem_cmd_rValid <= 1'b0;
      end
      dBus_rsp_regNext_valid <= dBus_rsp_valid;
      if(dBus_rsp_valid) begin
        DBusCachedPlugin_rspCounter <= (DBusCachedPlugin_rspCounter + 32'h00000001);
      end
      _zz_8 <= 1'b0;
      HazardSimplePlugin_writeBackBuffer_valid <= HazardSimplePlugin_writeBackWrites_valid;
      if(when_Pipeline_l151) begin
        execute_arbitration_isValid <= 1'b0;
      end
      if(when_Pipeline_l154) begin
        execute_arbitration_isValid <= decode_arbitration_isValid;
      end
      if(when_Pipeline_l151_1) begin
        memory_arbitration_isValid <= 1'b0;
      end
      if(when_Pipeline_l154_1) begin
        memory_arbitration_isValid <= execute_arbitration_isValid;
      end
      if(when_Pipeline_l151_2) begin
        writeBack_arbitration_isValid <= 1'b0;
      end
      if(when_Pipeline_l154_2) begin
        writeBack_arbitration_isValid <= memory_arbitration_isValid;
      end
      if(when_InstructionCache_l239) begin
        if(iBusWishbone_ACK) begin
          _zz_iBusWishbone_ADR <= (_zz_iBusWishbone_ADR + 2'b01);
        end
      end
      _zz_iBus_rsp_valid <= (iBusWishbone_CYC && iBusWishbone_ACK);
      _zz_dBus_rsp_valid <= ((_zz_dBus_cmd_ready && (! dBusWishbone_WE)) && dBusWishbone_ACK);
    end
  end

  always @(posedge clk) begin
    if(IBusCachedPlugin_iBusRsp_stages_1_output_ready) begin
      _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload <= IBusCachedPlugin_iBusRsp_stages_1_output_payload;
    end
    if(IBusCachedPlugin_iBusRsp_stages_1_input_ready) begin
      IBusCachedPlugin_s1_tightlyCoupledHit <= IBusCachedPlugin_s0_tightlyCoupledHit;
    end
    if(IBusCachedPlugin_iBusRsp_stages_2_input_ready) begin
      IBusCachedPlugin_s2_tightlyCoupledHit <= IBusCachedPlugin_s1_tightlyCoupledHit;
    end
    if(dataCache_1_io_mem_cmd_ready) begin
      dataCache_1_io_mem_cmd_rData_wr <= dataCache_1_io_mem_cmd_payload_wr;
      dataCache_1_io_mem_cmd_rData_uncached <= dataCache_1_io_mem_cmd_payload_uncached;
      dataCache_1_io_mem_cmd_rData_address <= dataCache_1_io_mem_cmd_payload_address;
      dataCache_1_io_mem_cmd_rData_data <= dataCache_1_io_mem_cmd_payload_data;
      dataCache_1_io_mem_cmd_rData_mask <= dataCache_1_io_mem_cmd_payload_mask;
      dataCache_1_io_mem_cmd_rData_size <= dataCache_1_io_mem_cmd_payload_size;
      dataCache_1_io_mem_cmd_rData_last <= dataCache_1_io_mem_cmd_payload_last;
    end
    dBus_rsp_regNext_payload_aggregated <= dBus_rsp_payload_aggregated;
    dBus_rsp_regNext_payload_last <= dBus_rsp_payload_last;
    dBus_rsp_regNext_payload_data <= dBus_rsp_payload_data;
    dBus_rsp_regNext_payload_error <= dBus_rsp_payload_error;
    HazardSimplePlugin_writeBackBuffer_payload_address <= HazardSimplePlugin_writeBackWrites_payload_address;
    HazardSimplePlugin_writeBackBuffer_payload_data <= HazardSimplePlugin_writeBackWrites_payload_data;
    if(when_Pipeline_l124) begin
      decode_to_execute_PC <= decode_PC;
    end
    if(when_Pipeline_l124_1) begin
      execute_to_memory_PC <= _zz_execute_SRC2;
    end
    if(when_Pipeline_l124_2) begin
      memory_to_writeBack_PC <= memory_PC;
    end
    if(when_Pipeline_l124_3) begin
      decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
    end
    if(when_Pipeline_l124_4) begin
      execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
    end
    if(when_Pipeline_l124_5) begin
      memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
    end
    if(when_Pipeline_l124_6) begin
      decode_to_execute_FORMAL_PC_NEXT <= _zz_decode_to_execute_FORMAL_PC_NEXT;
    end
    if(when_Pipeline_l124_7) begin
      execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
    end
    if(when_Pipeline_l124_8) begin
      memory_to_writeBack_FORMAL_PC_NEXT <= _zz_memory_to_writeBack_FORMAL_PC_NEXT;
    end
    if(when_Pipeline_l124_9) begin
      decode_to_execute_MEMORY_FORCE_CONSTISTENCY <= decode_MEMORY_FORCE_CONSTISTENCY;
    end
    if(when_Pipeline_l124_10) begin
      decode_to_execute_SRC1_CTRL <= _zz_decode_to_execute_SRC1_CTRL;
    end
    if(when_Pipeline_l124_11) begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if(when_Pipeline_l124_12) begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if(when_Pipeline_l124_13) begin
      execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
    end
    if(when_Pipeline_l124_14) begin
      memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
    end
    if(when_Pipeline_l124_15) begin
      decode_to_execute_ALU_CTRL <= _zz_decode_to_execute_ALU_CTRL;
    end
    if(when_Pipeline_l124_16) begin
      decode_to_execute_SRC2_CTRL <= _zz_decode_to_execute_SRC2_CTRL;
    end
    if(when_Pipeline_l124_17) begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if(when_Pipeline_l124_18) begin
      execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
    end
    if(when_Pipeline_l124_19) begin
      memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
    end
    if(when_Pipeline_l124_20) begin
      decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
    end
    if(when_Pipeline_l124_21) begin
      decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
    end
    if(when_Pipeline_l124_22) begin
      execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
    end
    if(when_Pipeline_l124_23) begin
      decode_to_execute_MEMORY_WR <= decode_MEMORY_WR;
    end
    if(when_Pipeline_l124_24) begin
      decode_to_execute_REGFILE_WRITE_VALID_ODD <= decode_REGFILE_WRITE_VALID_ODD;
    end
    if(when_Pipeline_l124_25) begin
      execute_to_memory_REGFILE_WRITE_VALID_ODD <= execute_REGFILE_WRITE_VALID_ODD;
    end
    if(when_Pipeline_l124_26) begin
      memory_to_writeBack_REGFILE_WRITE_VALID_ODD <= memory_REGFILE_WRITE_VALID_ODD;
    end
    if(when_Pipeline_l124_27) begin
      decode_to_execute_SRC3_CTRL <= _zz_decode_to_execute_SRC3_CTRL;
    end
    if(when_Pipeline_l124_28) begin
      decode_to_execute_MEMORY_MANAGMENT <= decode_MEMORY_MANAGMENT;
    end
    if(when_Pipeline_l124_29) begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if(when_Pipeline_l124_30) begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_decode_to_execute_ALU_BITWISE_CTRL;
    end
    if(when_Pipeline_l124_31) begin
      decode_to_execute_IS_MUL <= decode_IS_MUL;
    end
    if(when_Pipeline_l124_32) begin
      execute_to_memory_IS_MUL <= execute_IS_MUL;
    end
    if(when_Pipeline_l124_33) begin
      memory_to_writeBack_IS_MUL <= memory_IS_MUL;
    end
    if(when_Pipeline_l124_34) begin
      decode_to_execute_SHIFT_CTRL <= _zz_decode_to_execute_SHIFT_CTRL;
    end
    if(when_Pipeline_l124_35) begin
      execute_to_memory_SHIFT_CTRL <= _zz_execute_to_memory_SHIFT_CTRL;
    end
    if(when_Pipeline_l124_36) begin
      decode_to_execute_IS_CG6 <= decode_IS_CG6;
    end
    if(when_Pipeline_l124_37) begin
      execute_to_memory_IS_CG6 <= execute_IS_CG6;
    end
    if(when_Pipeline_l124_38) begin
      decode_to_execute_CG6Ctrl <= _zz_decode_to_execute_CG6Ctrl;
    end
    if(when_Pipeline_l124_39) begin
      decode_to_execute_CG6Ctrlminmax <= _zz_decode_to_execute_CG6Ctrlminmax;
    end
    if(when_Pipeline_l124_40) begin
      decode_to_execute_CG6Ctrlsignextend <= _zz_decode_to_execute_CG6Ctrlsignextend;
    end
    if(when_Pipeline_l124_41) begin
      decode_to_execute_CG6Ctrlternary <= _zz_decode_to_execute_CG6Ctrlternary;
    end
    if(when_Pipeline_l124_42) begin
      decode_to_execute_IS_Goblin <= decode_IS_Goblin;
    end
    if(when_Pipeline_l124_43) begin
      execute_to_memory_IS_Goblin <= execute_IS_Goblin;
    end
    if(when_Pipeline_l124_44) begin
      decode_to_execute_GoblinCtrlpdpikadd8 <= _zz_decode_to_execute_GoblinCtrlpdpikadd8;
    end
    if(when_Pipeline_l124_45) begin
      decode_to_execute_IS_Goblin2c <= decode_IS_Goblin2c;
    end
    if(when_Pipeline_l124_46) begin
      execute_to_memory_IS_Goblin2c <= execute_IS_Goblin2c;
    end
    if(when_Pipeline_l124_47) begin
      memory_to_writeBack_IS_Goblin2c <= memory_IS_Goblin2c;
    end
    if(when_Pipeline_l124_48) begin
      decode_to_execute_BRANCH_CTRL <= _zz_decode_to_execute_BRANCH_CTRL;
    end
    if(when_Pipeline_l124_49) begin
      decode_to_execute_RS1 <= decode_RS1;
    end
    if(when_Pipeline_l124_50) begin
      decode_to_execute_RS2 <= decode_RS2;
    end
    if(when_Pipeline_l124_51) begin
      decode_to_execute_RS3 <= decode_RS3;
    end
    if(when_Pipeline_l124_52) begin
      decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
    end
    if(when_Pipeline_l124_53) begin
      decode_to_execute_PREDICTION_HAD_BRANCHED2 <= decode_PREDICTION_HAD_BRANCHED2;
    end
    if(when_Pipeline_l124_54) begin
      execute_to_memory_MEMORY_STORE_DATA_RF <= execute_MEMORY_STORE_DATA_RF;
    end
    if(when_Pipeline_l124_55) begin
      memory_to_writeBack_MEMORY_STORE_DATA_RF <= memory_MEMORY_STORE_DATA_RF;
    end
    if(when_Pipeline_l124_56) begin
      execute_to_memory_REGFILE_WRITE_DATA <= _zz_decode_RS3_1;
    end
    if(when_Pipeline_l124_57) begin
      memory_to_writeBack_REGFILE_WRITE_DATA <= _zz_decode_RS3_3;
    end
    if(when_Pipeline_l124_58) begin
      execute_to_memory_REGFILE_WRITE_DATA_ODD <= _zz_decode_RS3;
    end
    if(when_Pipeline_l124_59) begin
      memory_to_writeBack_REGFILE_WRITE_DATA_ODD <= _zz_decode_RS3_2;
    end
    if(when_Pipeline_l124_60) begin
      execute_to_memory_MUL_LL <= execute_MUL_LL;
    end
    if(when_Pipeline_l124_61) begin
      execute_to_memory_MUL_LH <= execute_MUL_LH;
    end
    if(when_Pipeline_l124_62) begin
      execute_to_memory_MUL_HL <= execute_MUL_HL;
    end
    if(when_Pipeline_l124_63) begin
      execute_to_memory_MUL_HH <= execute_MUL_HH;
    end
    if(when_Pipeline_l124_64) begin
      memory_to_writeBack_MUL_HH <= memory_MUL_HH;
    end
    if(when_Pipeline_l124_65) begin
      execute_to_memory_SHIFT_RIGHT <= execute_SHIFT_RIGHT;
    end
    if(when_Pipeline_l124_66) begin
      execute_to_memory_CG6_FINAL_OUTPUT <= execute_CG6_FINAL_OUTPUT;
    end
    if(when_Pipeline_l124_67) begin
      execute_to_memory_Goblin_FINAL_OUTPUT <= execute_Goblin_FINAL_OUTPUT;
    end
    if(when_Pipeline_l124_68) begin
      execute_to_memory_Goblin2c_INTERMEDIATE_UFMA8VxV64 <= execute_Goblin2c_INTERMEDIATE_UFMA8VxV64;
    end
    if(when_Pipeline_l124_69) begin
      execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
    end
    if(when_Pipeline_l124_70) begin
      execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
    end
    if(when_Pipeline_l124_71) begin
      memory_to_writeBack_MUL_LOW <= memory_MUL_LOW;
    end
    if(when_Pipeline_l124_72) begin
      memory_to_writeBack_Goblin2c_FINAL_OUTPUT <= memory_Goblin2c_FINAL_OUTPUT;
    end
    iBusWishbone_DAT_MISO_regNext <= iBusWishbone_DAT_MISO;
    dBusWishbone_DAT_MISO_regNext <= dBusWishbone_DAT_MISO;
  end


endmodule

module DataCache (
  input               io_cpu_execute_isValid,
  input      [31:0]   io_cpu_execute_address,
  output reg          io_cpu_execute_haltIt,
  input               io_cpu_execute_args_wr,
  input      [2:0]    io_cpu_execute_args_size,
  input               io_cpu_execute_args_totalyConsistent,
  output              io_cpu_execute_refilling,
  input               io_cpu_memory_isValid,
  input               io_cpu_memory_isStuck,
  output              io_cpu_memory_isWrite,
  input      [31:0]   io_cpu_memory_address,
  input      [31:0]   io_cpu_memory_mmuRsp_physicalAddress,
  input               io_cpu_memory_mmuRsp_isIoAccess,
  input               io_cpu_memory_mmuRsp_isPaging,
  input               io_cpu_memory_mmuRsp_allowRead,
  input               io_cpu_memory_mmuRsp_allowWrite,
  input               io_cpu_memory_mmuRsp_allowExecute,
  input               io_cpu_memory_mmuRsp_exception,
  input               io_cpu_memory_mmuRsp_refilling,
  input               io_cpu_memory_mmuRsp_bypassTranslation,
  input               io_cpu_writeBack_isValid,
  input               io_cpu_writeBack_isStuck,
  input               io_cpu_writeBack_isFiring,
  input               io_cpu_writeBack_isUser,
  output reg          io_cpu_writeBack_haltIt,
  output              io_cpu_writeBack_isWrite,
  input      [127:0]  io_cpu_writeBack_storeData,
  output reg [127:0]  io_cpu_writeBack_data,
  input      [31:0]   io_cpu_writeBack_address,
  output              io_cpu_writeBack_mmuException,
  output              io_cpu_writeBack_unalignedAccess,
  output              io_cpu_writeBack_accessError,
  output              io_cpu_writeBack_keepMemRspData,
  input               io_cpu_writeBack_fence_SW,
  input               io_cpu_writeBack_fence_SR,
  input               io_cpu_writeBack_fence_SO,
  input               io_cpu_writeBack_fence_SI,
  input               io_cpu_writeBack_fence_PW,
  input               io_cpu_writeBack_fence_PR,
  input               io_cpu_writeBack_fence_PO,
  input               io_cpu_writeBack_fence_PI,
  input      [3:0]    io_cpu_writeBack_fence_FM,
  output              io_cpu_writeBack_exclusiveOk,
  output reg          io_cpu_redo,
  input               io_cpu_flush_valid,
  output              io_cpu_flush_ready,
  output reg          io_mem_cmd_valid,
  input               io_mem_cmd_ready,
  output reg          io_mem_cmd_payload_wr,
  output              io_mem_cmd_payload_uncached,
  output reg [31:0]   io_mem_cmd_payload_address,
  output     [127:0]  io_mem_cmd_payload_data,
  output     [15:0]   io_mem_cmd_payload_mask,
  output reg [2:0]    io_mem_cmd_payload_size,
  output              io_mem_cmd_payload_last,
  input               io_mem_rsp_valid,
  input      [4:0]    io_mem_rsp_payload_aggregated,
  input               io_mem_rsp_payload_last,
  input      [127:0]  io_mem_rsp_payload_data,
  input               io_mem_rsp_payload_error,
  input               clk,
  input               reset
);

  reg        [26:0]   _zz_ways_0_tags_port0;
  reg        [127:0]  _zz_ways_0_data_port0;
  reg        [26:0]   _zz_ways_1_tags_port0;
  reg        [127:0]  _zz_ways_1_data_port0;
  wire       [26:0]   _zz_ways_0_tags_port;
  wire       [26:0]   _zz_ways_1_tags_port;
  wire       [0:0]    _zz_when;
  wire       [2:0]    _zz_loader_waysAllocator;
  reg                 _zz_1;
  reg                 _zz_2;
  reg                 _zz_3;
  reg                 _zz_4;
  wire                haltCpu;
  reg                 tagsReadCmd_valid;
  reg        [2:0]    tagsReadCmd_payload;
  reg                 tagsWriteCmd_valid;
  reg        [1:0]    tagsWriteCmd_payload_way;
  reg        [2:0]    tagsWriteCmd_payload_address;
  reg                 tagsWriteCmd_payload_data_valid;
  reg                 tagsWriteCmd_payload_data_error;
  reg        [24:0]   tagsWriteCmd_payload_data_address;
  reg                 tagsWriteLastCmd_valid;
  reg        [1:0]    tagsWriteLastCmd_payload_way;
  reg        [2:0]    tagsWriteLastCmd_payload_address;
  reg                 tagsWriteLastCmd_payload_data_valid;
  reg                 tagsWriteLastCmd_payload_data_error;
  reg        [24:0]   tagsWriteLastCmd_payload_data_address;
  reg                 dataReadCmd_valid;
  reg        [2:0]    dataReadCmd_payload;
  reg                 dataWriteCmd_valid;
  reg        [1:0]    dataWriteCmd_payload_way;
  reg        [2:0]    dataWriteCmd_payload_address;
  reg        [127:0]  dataWriteCmd_payload_data;
  reg        [15:0]   dataWriteCmd_payload_mask;
  wire                _zz_ways_0_tagsReadRsp_valid;
  wire                ways_0_tagsReadRsp_valid;
  wire                ways_0_tagsReadRsp_error;
  wire       [24:0]   ways_0_tagsReadRsp_address;
  wire       [26:0]   _zz_ways_0_tagsReadRsp_valid_1;
  wire                _zz_ways_0_dataReadRspMem;
  wire       [127:0]  ways_0_dataReadRspMem;
  wire       [127:0]  ways_0_dataReadRsp;
  wire                when_DataCache_l636;
  wire                when_DataCache_l639;
  wire                _zz_ways_1_tagsReadRsp_valid;
  wire                ways_1_tagsReadRsp_valid;
  wire                ways_1_tagsReadRsp_error;
  wire       [24:0]   ways_1_tagsReadRsp_address;
  wire       [26:0]   _zz_ways_1_tagsReadRsp_valid_1;
  wire                _zz_ways_1_dataReadRspMem;
  wire       [127:0]  ways_1_dataReadRspMem;
  wire       [127:0]  ways_1_dataReadRsp;
  wire                when_DataCache_l636_1;
  wire                when_DataCache_l639_1;
  wire                when_DataCache_l658;
  wire                rspSync;
  wire                rspLast;
  reg                 memCmdSent;
  wire                io_mem_cmd_fire;
  wire                when_DataCache_l680;
  reg        [15:0]   _zz_stage0_mask;
  wire       [15:0]   stage0_mask;
  reg        [1:0]    stage0_dataColisions;
  wire       [2:0]    _zz_stage0_dataColisions;
  wire       [15:0]   _zz_stage0_dataColisions_1;
  wire       [1:0]    stage0_wayInvalidate;
  wire                stage0_isAmo;
  wire                when_DataCache_l765;
  reg                 stageA_request_wr;
  reg        [2:0]    stageA_request_size;
  reg                 stageA_request_totalyConsistent;
  wire                when_DataCache_l765_1;
  reg        [15:0]   stageA_mask;
  wire                stageA_isAmo;
  wire                stageA_isLrsc;
  wire       [1:0]    stageA_wayHits;
  wire                when_DataCache_l765_2;
  reg        [1:0]    stageA_wayInvalidate;
  wire                when_DataCache_l765_3;
  reg        [1:0]    stage0_dataColisions_regNextWhen;
  reg        [1:0]    _zz_stageA_dataColisions;
  wire       [2:0]    _zz_stageA_dataColisions_1;
  wire       [15:0]   _zz_stageA_dataColisions_2;
  wire       [1:0]    stageA_dataColisions;
  wire                when_DataCache_l816;
  reg                 stageB_request_wr;
  reg        [2:0]    stageB_request_size;
  reg                 stageB_request_totalyConsistent;
  reg                 stageB_mmuRspFreeze;
  wire                when_DataCache_l818;
  reg        [31:0]   stageB_mmuRsp_physicalAddress;
  reg                 stageB_mmuRsp_isIoAccess;
  reg                 stageB_mmuRsp_isPaging;
  reg                 stageB_mmuRsp_allowRead;
  reg                 stageB_mmuRsp_allowWrite;
  reg                 stageB_mmuRsp_allowExecute;
  reg                 stageB_mmuRsp_exception;
  reg                 stageB_mmuRsp_refilling;
  reg                 stageB_mmuRsp_bypassTranslation;
  wire                when_DataCache_l815;
  reg                 stageB_tagsReadRsp_0_valid;
  reg                 stageB_tagsReadRsp_0_error;
  reg        [24:0]   stageB_tagsReadRsp_0_address;
  wire                when_DataCache_l815_1;
  reg                 stageB_tagsReadRsp_1_valid;
  reg                 stageB_tagsReadRsp_1_error;
  reg        [24:0]   stageB_tagsReadRsp_1_address;
  wire                when_DataCache_l815_2;
  reg        [127:0]  stageB_dataReadRsp_0;
  wire                when_DataCache_l815_3;
  reg        [127:0]  stageB_dataReadRsp_1;
  wire                when_DataCache_l814;
  reg        [1:0]    stageB_wayInvalidate;
  wire                stageB_consistancyHazard;
  wire                when_DataCache_l814_1;
  reg        [1:0]    stageB_dataColisions;
  wire                stageB_unaligned;
  wire                when_DataCache_l814_2;
  reg        [1:0]    stageB_waysHitsBeforeInvalidate;
  wire       [1:0]    stageB_waysHits;
  wire                stageB_waysHit;
  wire       [127:0]  stageB_dataMux;
  wire                when_DataCache_l814_3;
  reg        [15:0]   stageB_mask;
  reg                 stageB_loaderValid;
  wire       [127:0]  stageB_ioMemRspMuxed;
  reg                 stageB_flusher_waitDone;
  wire                stageB_flusher_hold;
  reg        [3:0]    stageB_flusher_counter;
  wire                when_DataCache_l844;
  wire                when_DataCache_l850;
  reg                 stageB_flusher_start;
  wire                stageB_isAmo;
  wire                stageB_isAmoCached;
  wire                stageB_isExternalLsrc;
  wire                stageB_isExternalAmo;
  wire       [127:0]  stageB_requestDataBypass;
  reg                 stageB_cpuWriteToCache;
  wire                when_DataCache_l914;
  wire                stageB_badPermissions;
  wire                stageB_loadStoreFault;
  wire                stageB_bypassCache;
  wire                when_DataCache_l983;
  wire                when_DataCache_l992;
  wire                when_DataCache_l997;
  wire                when_DataCache_l1008;
  wire                when_DataCache_l1020;
  wire                when_DataCache_l979;
  wire                when_DataCache_l1054;
  wire                when_DataCache_l1063;
  reg                 loader_valid;
  reg                 loader_counter_willIncrement;
  wire                loader_counter_willClear;
  wire                loader_counter_willOverflowIfInc;
  wire                loader_counter_willOverflow;
  reg        [1:0]    loader_waysAllocator;
  reg                 loader_error;
  wire                loader_kill;
  reg                 loader_killReg;
  wire                when_DataCache_l1078;
  wire                loader_done;
  wire                when_DataCache_l1106;
  reg                 loader_valid_regNext;
  wire                when_DataCache_l1110;
  wire                when_DataCache_l1113;
  reg [26:0] ways_0_tags [0:7];
  reg [7:0] ways_0_data_symbol0 [0:7];
  reg [7:0] ways_0_data_symbol1 [0:7];
  reg [7:0] ways_0_data_symbol2 [0:7];
  reg [7:0] ways_0_data_symbol3 [0:7];
  reg [7:0] ways_0_data_symbol4 [0:7];
  reg [7:0] ways_0_data_symbol5 [0:7];
  reg [7:0] ways_0_data_symbol6 [0:7];
  reg [7:0] ways_0_data_symbol7 [0:7];
  reg [7:0] ways_0_data_symbol8 [0:7];
  reg [7:0] ways_0_data_symbol9 [0:7];
  reg [7:0] ways_0_data_symbol10 [0:7];
  reg [7:0] ways_0_data_symbol11 [0:7];
  reg [7:0] ways_0_data_symbol12 [0:7];
  reg [7:0] ways_0_data_symbol13 [0:7];
  reg [7:0] ways_0_data_symbol14 [0:7];
  reg [7:0] ways_0_data_symbol15 [0:7];
  reg [7:0] _zz_ways_0_datasymbol_read;
  reg [7:0] _zz_ways_0_datasymbol_read_1;
  reg [7:0] _zz_ways_0_datasymbol_read_2;
  reg [7:0] _zz_ways_0_datasymbol_read_3;
  reg [7:0] _zz_ways_0_datasymbol_read_4;
  reg [7:0] _zz_ways_0_datasymbol_read_5;
  reg [7:0] _zz_ways_0_datasymbol_read_6;
  reg [7:0] _zz_ways_0_datasymbol_read_7;
  reg [7:0] _zz_ways_0_datasymbol_read_8;
  reg [7:0] _zz_ways_0_datasymbol_read_9;
  reg [7:0] _zz_ways_0_datasymbol_read_10;
  reg [7:0] _zz_ways_0_datasymbol_read_11;
  reg [7:0] _zz_ways_0_datasymbol_read_12;
  reg [7:0] _zz_ways_0_datasymbol_read_13;
  reg [7:0] _zz_ways_0_datasymbol_read_14;
  reg [7:0] _zz_ways_0_datasymbol_read_15;
  reg [26:0] ways_1_tags [0:7];
  reg [7:0] ways_1_data_symbol0 [0:7];
  reg [7:0] ways_1_data_symbol1 [0:7];
  reg [7:0] ways_1_data_symbol2 [0:7];
  reg [7:0] ways_1_data_symbol3 [0:7];
  reg [7:0] ways_1_data_symbol4 [0:7];
  reg [7:0] ways_1_data_symbol5 [0:7];
  reg [7:0] ways_1_data_symbol6 [0:7];
  reg [7:0] ways_1_data_symbol7 [0:7];
  reg [7:0] ways_1_data_symbol8 [0:7];
  reg [7:0] ways_1_data_symbol9 [0:7];
  reg [7:0] ways_1_data_symbol10 [0:7];
  reg [7:0] ways_1_data_symbol11 [0:7];
  reg [7:0] ways_1_data_symbol12 [0:7];
  reg [7:0] ways_1_data_symbol13 [0:7];
  reg [7:0] ways_1_data_symbol14 [0:7];
  reg [7:0] ways_1_data_symbol15 [0:7];
  reg [7:0] _zz_ways_1_datasymbol_read;
  reg [7:0] _zz_ways_1_datasymbol_read_1;
  reg [7:0] _zz_ways_1_datasymbol_read_2;
  reg [7:0] _zz_ways_1_datasymbol_read_3;
  reg [7:0] _zz_ways_1_datasymbol_read_4;
  reg [7:0] _zz_ways_1_datasymbol_read_5;
  reg [7:0] _zz_ways_1_datasymbol_read_6;
  reg [7:0] _zz_ways_1_datasymbol_read_7;
  reg [7:0] _zz_ways_1_datasymbol_read_8;
  reg [7:0] _zz_ways_1_datasymbol_read_9;
  reg [7:0] _zz_ways_1_datasymbol_read_10;
  reg [7:0] _zz_ways_1_datasymbol_read_11;
  reg [7:0] _zz_ways_1_datasymbol_read_12;
  reg [7:0] _zz_ways_1_datasymbol_read_13;
  reg [7:0] _zz_ways_1_datasymbol_read_14;
  reg [7:0] _zz_ways_1_datasymbol_read_15;

  assign _zz_when = 1'b1;
  assign _zz_loader_waysAllocator = {loader_waysAllocator,loader_waysAllocator[1]};
  assign _zz_ways_0_tags_port = {tagsWriteCmd_payload_data_address,{tagsWriteCmd_payload_data_error,tagsWriteCmd_payload_data_valid}};
  assign _zz_ways_1_tags_port = {tagsWriteCmd_payload_data_address,{tagsWriteCmd_payload_data_error,tagsWriteCmd_payload_data_valid}};
  always @(posedge clk) begin
    if(_zz_ways_0_tagsReadRsp_valid) begin
      _zz_ways_0_tags_port0 <= ways_0_tags[tagsReadCmd_payload];
    end
  end

  always @(posedge clk) begin
    if(_zz_4) begin
      ways_0_tags[tagsWriteCmd_payload_address] <= _zz_ways_0_tags_port;
    end
  end

  always @(*) begin
    _zz_ways_0_data_port0 = {_zz_ways_0_datasymbol_read_15, _zz_ways_0_datasymbol_read_14, _zz_ways_0_datasymbol_read_13, _zz_ways_0_datasymbol_read_12, _zz_ways_0_datasymbol_read_11, _zz_ways_0_datasymbol_read_10, _zz_ways_0_datasymbol_read_9, _zz_ways_0_datasymbol_read_8, _zz_ways_0_datasymbol_read_7, _zz_ways_0_datasymbol_read_6, _zz_ways_0_datasymbol_read_5, _zz_ways_0_datasymbol_read_4, _zz_ways_0_datasymbol_read_3, _zz_ways_0_datasymbol_read_2, _zz_ways_0_datasymbol_read_1, _zz_ways_0_datasymbol_read};
  end
  always @(posedge clk) begin
    if(_zz_ways_0_dataReadRspMem) begin
      _zz_ways_0_datasymbol_read <= ways_0_data_symbol0[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_1 <= ways_0_data_symbol1[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_2 <= ways_0_data_symbol2[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_3 <= ways_0_data_symbol3[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_4 <= ways_0_data_symbol4[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_5 <= ways_0_data_symbol5[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_6 <= ways_0_data_symbol6[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_7 <= ways_0_data_symbol7[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_8 <= ways_0_data_symbol8[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_9 <= ways_0_data_symbol9[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_10 <= ways_0_data_symbol10[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_11 <= ways_0_data_symbol11[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_12 <= ways_0_data_symbol12[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_13 <= ways_0_data_symbol13[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_14 <= ways_0_data_symbol14[dataReadCmd_payload];
      _zz_ways_0_datasymbol_read_15 <= ways_0_data_symbol15[dataReadCmd_payload];
    end
  end

  always @(posedge clk) begin
    if(dataWriteCmd_payload_mask[0] && _zz_3) begin
      ways_0_data_symbol0[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[7 : 0];
    end
    if(dataWriteCmd_payload_mask[1] && _zz_3) begin
      ways_0_data_symbol1[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[15 : 8];
    end
    if(dataWriteCmd_payload_mask[2] && _zz_3) begin
      ways_0_data_symbol2[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[23 : 16];
    end
    if(dataWriteCmd_payload_mask[3] && _zz_3) begin
      ways_0_data_symbol3[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[31 : 24];
    end
    if(dataWriteCmd_payload_mask[4] && _zz_3) begin
      ways_0_data_symbol4[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[39 : 32];
    end
    if(dataWriteCmd_payload_mask[5] && _zz_3) begin
      ways_0_data_symbol5[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[47 : 40];
    end
    if(dataWriteCmd_payload_mask[6] && _zz_3) begin
      ways_0_data_symbol6[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[55 : 48];
    end
    if(dataWriteCmd_payload_mask[7] && _zz_3) begin
      ways_0_data_symbol7[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[63 : 56];
    end
    if(dataWriteCmd_payload_mask[8] && _zz_3) begin
      ways_0_data_symbol8[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[71 : 64];
    end
    if(dataWriteCmd_payload_mask[9] && _zz_3) begin
      ways_0_data_symbol9[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[79 : 72];
    end
    if(dataWriteCmd_payload_mask[10] && _zz_3) begin
      ways_0_data_symbol10[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[87 : 80];
    end
    if(dataWriteCmd_payload_mask[11] && _zz_3) begin
      ways_0_data_symbol11[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[95 : 88];
    end
    if(dataWriteCmd_payload_mask[12] && _zz_3) begin
      ways_0_data_symbol12[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[103 : 96];
    end
    if(dataWriteCmd_payload_mask[13] && _zz_3) begin
      ways_0_data_symbol13[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[111 : 104];
    end
    if(dataWriteCmd_payload_mask[14] && _zz_3) begin
      ways_0_data_symbol14[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[119 : 112];
    end
    if(dataWriteCmd_payload_mask[15] && _zz_3) begin
      ways_0_data_symbol15[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[127 : 120];
    end
  end

  always @(posedge clk) begin
    if(_zz_ways_1_tagsReadRsp_valid) begin
      _zz_ways_1_tags_port0 <= ways_1_tags[tagsReadCmd_payload];
    end
  end

  always @(posedge clk) begin
    if(_zz_2) begin
      ways_1_tags[tagsWriteCmd_payload_address] <= _zz_ways_1_tags_port;
    end
  end

  always @(*) begin
    _zz_ways_1_data_port0 = {_zz_ways_1_datasymbol_read_15, _zz_ways_1_datasymbol_read_14, _zz_ways_1_datasymbol_read_13, _zz_ways_1_datasymbol_read_12, _zz_ways_1_datasymbol_read_11, _zz_ways_1_datasymbol_read_10, _zz_ways_1_datasymbol_read_9, _zz_ways_1_datasymbol_read_8, _zz_ways_1_datasymbol_read_7, _zz_ways_1_datasymbol_read_6, _zz_ways_1_datasymbol_read_5, _zz_ways_1_datasymbol_read_4, _zz_ways_1_datasymbol_read_3, _zz_ways_1_datasymbol_read_2, _zz_ways_1_datasymbol_read_1, _zz_ways_1_datasymbol_read};
  end
  always @(posedge clk) begin
    if(_zz_ways_1_dataReadRspMem) begin
      _zz_ways_1_datasymbol_read <= ways_1_data_symbol0[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_1 <= ways_1_data_symbol1[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_2 <= ways_1_data_symbol2[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_3 <= ways_1_data_symbol3[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_4 <= ways_1_data_symbol4[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_5 <= ways_1_data_symbol5[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_6 <= ways_1_data_symbol6[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_7 <= ways_1_data_symbol7[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_8 <= ways_1_data_symbol8[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_9 <= ways_1_data_symbol9[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_10 <= ways_1_data_symbol10[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_11 <= ways_1_data_symbol11[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_12 <= ways_1_data_symbol12[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_13 <= ways_1_data_symbol13[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_14 <= ways_1_data_symbol14[dataReadCmd_payload];
      _zz_ways_1_datasymbol_read_15 <= ways_1_data_symbol15[dataReadCmd_payload];
    end
  end

  always @(posedge clk) begin
    if(dataWriteCmd_payload_mask[0] && _zz_1) begin
      ways_1_data_symbol0[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[7 : 0];
    end
    if(dataWriteCmd_payload_mask[1] && _zz_1) begin
      ways_1_data_symbol1[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[15 : 8];
    end
    if(dataWriteCmd_payload_mask[2] && _zz_1) begin
      ways_1_data_symbol2[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[23 : 16];
    end
    if(dataWriteCmd_payload_mask[3] && _zz_1) begin
      ways_1_data_symbol3[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[31 : 24];
    end
    if(dataWriteCmd_payload_mask[4] && _zz_1) begin
      ways_1_data_symbol4[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[39 : 32];
    end
    if(dataWriteCmd_payload_mask[5] && _zz_1) begin
      ways_1_data_symbol5[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[47 : 40];
    end
    if(dataWriteCmd_payload_mask[6] && _zz_1) begin
      ways_1_data_symbol6[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[55 : 48];
    end
    if(dataWriteCmd_payload_mask[7] && _zz_1) begin
      ways_1_data_symbol7[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[63 : 56];
    end
    if(dataWriteCmd_payload_mask[8] && _zz_1) begin
      ways_1_data_symbol8[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[71 : 64];
    end
    if(dataWriteCmd_payload_mask[9] && _zz_1) begin
      ways_1_data_symbol9[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[79 : 72];
    end
    if(dataWriteCmd_payload_mask[10] && _zz_1) begin
      ways_1_data_symbol10[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[87 : 80];
    end
    if(dataWriteCmd_payload_mask[11] && _zz_1) begin
      ways_1_data_symbol11[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[95 : 88];
    end
    if(dataWriteCmd_payload_mask[12] && _zz_1) begin
      ways_1_data_symbol12[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[103 : 96];
    end
    if(dataWriteCmd_payload_mask[13] && _zz_1) begin
      ways_1_data_symbol13[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[111 : 104];
    end
    if(dataWriteCmd_payload_mask[14] && _zz_1) begin
      ways_1_data_symbol14[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[119 : 112];
    end
    if(dataWriteCmd_payload_mask[15] && _zz_1) begin
      ways_1_data_symbol15[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[127 : 120];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(when_DataCache_l639_1) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    _zz_2 = 1'b0;
    if(when_DataCache_l636_1) begin
      _zz_2 = 1'b1;
    end
  end

  always @(*) begin
    _zz_3 = 1'b0;
    if(when_DataCache_l639) begin
      _zz_3 = 1'b1;
    end
  end

  always @(*) begin
    _zz_4 = 1'b0;
    if(when_DataCache_l636) begin
      _zz_4 = 1'b1;
    end
  end

  assign haltCpu = 1'b0;
  assign _zz_ways_0_tagsReadRsp_valid = (tagsReadCmd_valid && (! io_cpu_memory_isStuck));
  assign _zz_ways_0_tagsReadRsp_valid_1 = _zz_ways_0_tags_port0;
  assign ways_0_tagsReadRsp_valid = _zz_ways_0_tagsReadRsp_valid_1[0];
  assign ways_0_tagsReadRsp_error = _zz_ways_0_tagsReadRsp_valid_1[1];
  assign ways_0_tagsReadRsp_address = _zz_ways_0_tagsReadRsp_valid_1[26 : 2];
  assign _zz_ways_0_dataReadRspMem = (dataReadCmd_valid && (! io_cpu_memory_isStuck));
  assign ways_0_dataReadRspMem = _zz_ways_0_data_port0;
  assign ways_0_dataReadRsp = ways_0_dataReadRspMem[127 : 0];
  assign when_DataCache_l636 = (tagsWriteCmd_valid && tagsWriteCmd_payload_way[0]);
  assign when_DataCache_l639 = (dataWriteCmd_valid && dataWriteCmd_payload_way[0]);
  assign _zz_ways_1_tagsReadRsp_valid = (tagsReadCmd_valid && (! io_cpu_memory_isStuck));
  assign _zz_ways_1_tagsReadRsp_valid_1 = _zz_ways_1_tags_port0;
  assign ways_1_tagsReadRsp_valid = _zz_ways_1_tagsReadRsp_valid_1[0];
  assign ways_1_tagsReadRsp_error = _zz_ways_1_tagsReadRsp_valid_1[1];
  assign ways_1_tagsReadRsp_address = _zz_ways_1_tagsReadRsp_valid_1[26 : 2];
  assign _zz_ways_1_dataReadRspMem = (dataReadCmd_valid && (! io_cpu_memory_isStuck));
  assign ways_1_dataReadRspMem = _zz_ways_1_data_port0;
  assign ways_1_dataReadRsp = ways_1_dataReadRspMem[127 : 0];
  assign when_DataCache_l636_1 = (tagsWriteCmd_valid && tagsWriteCmd_payload_way[1]);
  assign when_DataCache_l639_1 = (dataWriteCmd_valid && dataWriteCmd_payload_way[1]);
  always @(*) begin
    tagsReadCmd_valid = 1'b0;
    if(when_DataCache_l658) begin
      tagsReadCmd_valid = 1'b1;
    end
  end

  always @(*) begin
    tagsReadCmd_payload = 3'bxxx;
    if(when_DataCache_l658) begin
      tagsReadCmd_payload = io_cpu_execute_address[6 : 4];
    end
  end

  always @(*) begin
    dataReadCmd_valid = 1'b0;
    if(when_DataCache_l658) begin
      dataReadCmd_valid = 1'b1;
    end
  end

  always @(*) begin
    dataReadCmd_payload = 3'bxxx;
    if(when_DataCache_l658) begin
      dataReadCmd_payload = io_cpu_execute_address[6 : 4];
    end
  end

  always @(*) begin
    tagsWriteCmd_valid = 1'b0;
    if(when_DataCache_l844) begin
      tagsWriteCmd_valid = 1'b1;
    end
    if(when_DataCache_l1054) begin
      tagsWriteCmd_valid = 1'b0;
    end
    if(loader_done) begin
      tagsWriteCmd_valid = 1'b1;
    end
  end

  always @(*) begin
    tagsWriteCmd_payload_way = 2'bxx;
    if(when_DataCache_l844) begin
      tagsWriteCmd_payload_way = 2'b11;
    end
    if(loader_done) begin
      tagsWriteCmd_payload_way = loader_waysAllocator;
    end
  end

  always @(*) begin
    tagsWriteCmd_payload_address = 3'bxxx;
    if(when_DataCache_l844) begin
      tagsWriteCmd_payload_address = stageB_flusher_counter[2:0];
    end
    if(loader_done) begin
      tagsWriteCmd_payload_address = stageB_mmuRsp_physicalAddress[6 : 4];
    end
  end

  always @(*) begin
    tagsWriteCmd_payload_data_valid = 1'bx;
    if(when_DataCache_l844) begin
      tagsWriteCmd_payload_data_valid = 1'b0;
    end
    if(loader_done) begin
      tagsWriteCmd_payload_data_valid = (! (loader_kill || loader_killReg));
    end
  end

  always @(*) begin
    tagsWriteCmd_payload_data_error = 1'bx;
    if(loader_done) begin
      tagsWriteCmd_payload_data_error = (loader_error || (io_mem_rsp_valid && io_mem_rsp_payload_error));
    end
  end

  always @(*) begin
    tagsWriteCmd_payload_data_address = 25'bxxxxxxxxxxxxxxxxxxxxxxxxx;
    if(loader_done) begin
      tagsWriteCmd_payload_data_address = stageB_mmuRsp_physicalAddress[31 : 7];
    end
  end

  always @(*) begin
    dataWriteCmd_valid = 1'b0;
    if(stageB_cpuWriteToCache) begin
      if(when_DataCache_l914) begin
        dataWriteCmd_valid = 1'b1;
      end
    end
    if(when_DataCache_l1054) begin
      dataWriteCmd_valid = 1'b0;
    end
    if(when_DataCache_l1078) begin
      dataWriteCmd_valid = 1'b1;
    end
  end

  always @(*) begin
    dataWriteCmd_payload_way = 2'bxx;
    if(stageB_cpuWriteToCache) begin
      dataWriteCmd_payload_way = stageB_waysHits;
    end
    if(when_DataCache_l1078) begin
      dataWriteCmd_payload_way = loader_waysAllocator;
    end
  end

  always @(*) begin
    dataWriteCmd_payload_address = 3'bxxx;
    if(stageB_cpuWriteToCache) begin
      dataWriteCmd_payload_address = stageB_mmuRsp_physicalAddress[6 : 4];
    end
    if(when_DataCache_l1078) begin
      dataWriteCmd_payload_address = stageB_mmuRsp_physicalAddress[6 : 4];
    end
  end

  always @(*) begin
    dataWriteCmd_payload_data = 128'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    if(stageB_cpuWriteToCache) begin
      dataWriteCmd_payload_data[127 : 0] = stageB_requestDataBypass;
    end
    if(when_DataCache_l1078) begin
      dataWriteCmd_payload_data = io_mem_rsp_payload_data;
    end
  end

  always @(*) begin
    dataWriteCmd_payload_mask = 16'bxxxxxxxxxxxxxxxx;
    if(stageB_cpuWriteToCache) begin
      dataWriteCmd_payload_mask = 16'h0;
      if(_zz_when[0]) begin
        dataWriteCmd_payload_mask[15 : 0] = stageB_mask;
      end
    end
    if(when_DataCache_l1078) begin
      dataWriteCmd_payload_mask = 16'hffff;
    end
  end

  assign when_DataCache_l658 = (io_cpu_execute_isValid && (! io_cpu_memory_isStuck));
  always @(*) begin
    io_cpu_execute_haltIt = 1'b0;
    if(when_DataCache_l844) begin
      io_cpu_execute_haltIt = 1'b1;
    end
  end

  assign rspSync = 1'b1;
  assign rspLast = 1'b1;
  assign io_mem_cmd_fire = (io_mem_cmd_valid && io_mem_cmd_ready);
  assign when_DataCache_l680 = (! io_cpu_writeBack_isStuck);
  always @(*) begin
    _zz_stage0_mask = 16'bxxxxxxxxxxxxxxxx;
    case(io_cpu_execute_args_size)
      3'b000 : begin
        _zz_stage0_mask = 16'h0001;
      end
      3'b001 : begin
        _zz_stage0_mask = 16'h0003;
      end
      3'b010 : begin
        _zz_stage0_mask = 16'h000f;
      end
      3'b011 : begin
        _zz_stage0_mask = 16'h00ff;
      end
      3'b100 : begin
        _zz_stage0_mask = 16'hffff;
      end
      default : begin
      end
    endcase
  end

  assign stage0_mask = (_zz_stage0_mask <<< io_cpu_execute_address[3 : 0]);
  assign _zz_stage0_dataColisions = (io_cpu_execute_address[6 : 4] >>> 0);
  assign _zz_stage0_dataColisions_1 = dataWriteCmd_payload_mask[15 : 0];
  always @(*) begin
    stage0_dataColisions[0] = (((dataWriteCmd_valid && dataWriteCmd_payload_way[0]) && (dataWriteCmd_payload_address == _zz_stage0_dataColisions)) && ((stage0_mask & _zz_stage0_dataColisions_1) != 16'h0));
    stage0_dataColisions[1] = (((dataWriteCmd_valid && dataWriteCmd_payload_way[1]) && (dataWriteCmd_payload_address == _zz_stage0_dataColisions)) && ((stage0_mask & _zz_stage0_dataColisions_1) != 16'h0));
  end

  assign stage0_wayInvalidate = 2'b00;
  assign stage0_isAmo = 1'b0;
  assign when_DataCache_l765 = (! io_cpu_memory_isStuck);
  assign when_DataCache_l765_1 = (! io_cpu_memory_isStuck);
  assign io_cpu_memory_isWrite = stageA_request_wr;
  assign stageA_isAmo = 1'b0;
  assign stageA_isLrsc = 1'b0;
  assign stageA_wayHits = {((io_cpu_memory_mmuRsp_physicalAddress[31 : 7] == ways_1_tagsReadRsp_address) && ways_1_tagsReadRsp_valid),((io_cpu_memory_mmuRsp_physicalAddress[31 : 7] == ways_0_tagsReadRsp_address) && ways_0_tagsReadRsp_valid)};
  assign when_DataCache_l765_2 = (! io_cpu_memory_isStuck);
  assign when_DataCache_l765_3 = (! io_cpu_memory_isStuck);
  assign _zz_stageA_dataColisions_1 = (io_cpu_memory_address[6 : 4] >>> 0);
  assign _zz_stageA_dataColisions_2 = dataWriteCmd_payload_mask[15 : 0];
  always @(*) begin
    _zz_stageA_dataColisions[0] = (((dataWriteCmd_valid && dataWriteCmd_payload_way[0]) && (dataWriteCmd_payload_address == _zz_stageA_dataColisions_1)) && ((stageA_mask & _zz_stageA_dataColisions_2) != 16'h0));
    _zz_stageA_dataColisions[1] = (((dataWriteCmd_valid && dataWriteCmd_payload_way[1]) && (dataWriteCmd_payload_address == _zz_stageA_dataColisions_1)) && ((stageA_mask & _zz_stageA_dataColisions_2) != 16'h0));
  end

  assign stageA_dataColisions = (stage0_dataColisions_regNextWhen | _zz_stageA_dataColisions);
  assign when_DataCache_l816 = (! io_cpu_writeBack_isStuck);
  always @(*) begin
    stageB_mmuRspFreeze = 1'b0;
    if(when_DataCache_l1113) begin
      stageB_mmuRspFreeze = 1'b1;
    end
  end

  assign when_DataCache_l818 = ((! io_cpu_writeBack_isStuck) && (! stageB_mmuRspFreeze));
  assign when_DataCache_l815 = (! io_cpu_writeBack_isStuck);
  assign when_DataCache_l815_1 = (! io_cpu_writeBack_isStuck);
  assign when_DataCache_l815_2 = (! io_cpu_writeBack_isStuck);
  assign when_DataCache_l815_3 = (! io_cpu_writeBack_isStuck);
  assign when_DataCache_l814 = (! io_cpu_writeBack_isStuck);
  assign stageB_consistancyHazard = 1'b0;
  assign when_DataCache_l814_1 = (! io_cpu_writeBack_isStuck);
  assign stageB_unaligned = 1'b0;
  assign when_DataCache_l814_2 = (! io_cpu_writeBack_isStuck);
  assign stageB_waysHits = (stageB_waysHitsBeforeInvalidate & (~ stageB_wayInvalidate));
  assign stageB_waysHit = (|stageB_waysHits);
  assign stageB_dataMux = (stageB_waysHits[0] ? stageB_dataReadRsp_0 : stageB_dataReadRsp_1);
  assign when_DataCache_l814_3 = (! io_cpu_writeBack_isStuck);
  always @(*) begin
    stageB_loaderValid = 1'b0;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(!when_DataCache_l979) begin
          if(!when_DataCache_l992) begin
            if(io_mem_cmd_ready) begin
              stageB_loaderValid = 1'b1;
            end
          end
        end
      end
    end
    if(when_DataCache_l1054) begin
      stageB_loaderValid = 1'b0;
    end
  end

  assign stageB_ioMemRspMuxed = io_mem_rsp_payload_data[127 : 0];
  always @(*) begin
    io_cpu_writeBack_haltIt = 1'b1;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(when_DataCache_l979) begin
          if(when_DataCache_l983) begin
            io_cpu_writeBack_haltIt = 1'b0;
          end
        end else begin
          if(when_DataCache_l992) begin
            if(when_DataCache_l997) begin
              io_cpu_writeBack_haltIt = 1'b0;
            end
          end
        end
      end
    end
    if(when_DataCache_l1054) begin
      io_cpu_writeBack_haltIt = 1'b0;
    end
  end

  assign stageB_flusher_hold = 1'b0;
  assign when_DataCache_l844 = (! stageB_flusher_counter[3]);
  assign when_DataCache_l850 = (! stageB_flusher_hold);
  assign io_cpu_flush_ready = (stageB_flusher_waitDone && stageB_flusher_counter[3]);
  assign stageB_isAmo = 1'b0;
  assign stageB_isAmoCached = 1'b0;
  assign stageB_isExternalLsrc = 1'b0;
  assign stageB_isExternalAmo = 1'b0;
  assign stageB_requestDataBypass = io_cpu_writeBack_storeData;
  always @(*) begin
    stageB_cpuWriteToCache = 1'b0;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(!when_DataCache_l979) begin
          if(when_DataCache_l992) begin
            stageB_cpuWriteToCache = 1'b1;
          end
        end
      end
    end
  end

  assign when_DataCache_l914 = (stageB_request_wr && stageB_waysHit);
  assign stageB_badPermissions = (((! stageB_mmuRsp_allowWrite) && stageB_request_wr) || ((! stageB_mmuRsp_allowRead) && ((! stageB_request_wr) || stageB_isAmo)));
  assign stageB_loadStoreFault = (io_cpu_writeBack_isValid && (stageB_mmuRsp_exception || stageB_badPermissions));
  always @(*) begin
    io_cpu_redo = 1'b0;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(!when_DataCache_l979) begin
          if(when_DataCache_l992) begin
            if(when_DataCache_l1008) begin
              io_cpu_redo = 1'b1;
            end
          end
        end
      end
    end
    if(when_DataCache_l1063) begin
      io_cpu_redo = 1'b1;
    end
    if(when_DataCache_l1110) begin
      io_cpu_redo = 1'b1;
    end
  end

  assign io_cpu_writeBack_accessError = 1'b0;
  assign io_cpu_writeBack_mmuException = (stageB_loadStoreFault && 1'b0);
  assign io_cpu_writeBack_unalignedAccess = (io_cpu_writeBack_isValid && stageB_unaligned);
  assign io_cpu_writeBack_isWrite = stageB_request_wr;
  always @(*) begin
    io_mem_cmd_valid = 1'b0;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(when_DataCache_l979) begin
          io_mem_cmd_valid = (! memCmdSent);
        end else begin
          if(when_DataCache_l992) begin
            if(stageB_request_wr) begin
              io_mem_cmd_valid = 1'b1;
            end
          end else begin
            if(when_DataCache_l1020) begin
              io_mem_cmd_valid = 1'b1;
            end
          end
        end
      end
    end
    if(when_DataCache_l1054) begin
      io_mem_cmd_valid = 1'b0;
    end
  end

  always @(*) begin
    io_mem_cmd_payload_address = stageB_mmuRsp_physicalAddress;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(!when_DataCache_l979) begin
          if(!when_DataCache_l992) begin
            io_mem_cmd_payload_address[3 : 0] = 4'b0000;
          end
        end
      end
    end
  end

  assign io_mem_cmd_payload_last = 1'b1;
  always @(*) begin
    io_mem_cmd_payload_wr = stageB_request_wr;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(!when_DataCache_l979) begin
          if(!when_DataCache_l992) begin
            io_mem_cmd_payload_wr = 1'b0;
          end
        end
      end
    end
  end

  assign io_mem_cmd_payload_mask = stageB_mask;
  assign io_mem_cmd_payload_data = stageB_requestDataBypass;
  assign io_mem_cmd_payload_uncached = stageB_mmuRsp_isIoAccess;
  always @(*) begin
    io_mem_cmd_payload_size = stageB_request_size;
    if(io_cpu_writeBack_isValid) begin
      if(!stageB_isExternalAmo) begin
        if(!when_DataCache_l979) begin
          if(!when_DataCache_l992) begin
            io_mem_cmd_payload_size = 3'b100;
          end
        end
      end
    end
  end

  assign stageB_bypassCache = ((stageB_mmuRsp_isIoAccess || stageB_isExternalLsrc) || stageB_isExternalAmo);
  assign io_cpu_writeBack_keepMemRspData = 1'b0;
  assign when_DataCache_l983 = ((! stageB_request_wr) ? (io_mem_rsp_valid && rspSync) : io_mem_cmd_ready);
  assign when_DataCache_l992 = (stageB_waysHit || (stageB_request_wr && (! stageB_isAmoCached)));
  assign when_DataCache_l997 = ((! stageB_request_wr) || io_mem_cmd_ready);
  assign when_DataCache_l1008 = (((! stageB_request_wr) || stageB_isAmoCached) && ((stageB_dataColisions & stageB_waysHits) != 2'b00));
  assign when_DataCache_l1020 = (! memCmdSent);
  assign when_DataCache_l979 = (stageB_mmuRsp_isIoAccess || stageB_isExternalLsrc);
  always @(*) begin
    if(stageB_bypassCache) begin
      io_cpu_writeBack_data = stageB_ioMemRspMuxed;
    end else begin
      io_cpu_writeBack_data = stageB_dataMux;
    end
  end

  assign when_DataCache_l1054 = ((((stageB_consistancyHazard || stageB_mmuRsp_refilling) || io_cpu_writeBack_accessError) || io_cpu_writeBack_mmuException) || io_cpu_writeBack_unalignedAccess);
  assign when_DataCache_l1063 = (io_cpu_writeBack_isValid && (stageB_mmuRsp_refilling || stageB_consistancyHazard));
  always @(*) begin
    loader_counter_willIncrement = 1'b0;
    if(when_DataCache_l1078) begin
      loader_counter_willIncrement = 1'b1;
    end
  end

  assign loader_counter_willClear = 1'b0;
  assign loader_counter_willOverflowIfInc = 1'b1;
  assign loader_counter_willOverflow = (loader_counter_willOverflowIfInc && loader_counter_willIncrement);
  assign loader_kill = 1'b0;
  assign when_DataCache_l1078 = ((loader_valid && io_mem_rsp_valid) && rspLast);
  assign loader_done = loader_counter_willOverflow;
  assign when_DataCache_l1106 = (! loader_valid);
  assign when_DataCache_l1110 = (loader_valid && (! loader_valid_regNext));
  assign io_cpu_execute_refilling = loader_valid;
  assign when_DataCache_l1113 = (stageB_loaderValid || loader_valid);
  always @(posedge clk) begin
    tagsWriteLastCmd_valid <= tagsWriteCmd_valid;
    tagsWriteLastCmd_payload_way <= tagsWriteCmd_payload_way;
    tagsWriteLastCmd_payload_address <= tagsWriteCmd_payload_address;
    tagsWriteLastCmd_payload_data_valid <= tagsWriteCmd_payload_data_valid;
    tagsWriteLastCmd_payload_data_error <= tagsWriteCmd_payload_data_error;
    tagsWriteLastCmd_payload_data_address <= tagsWriteCmd_payload_data_address;
    if(when_DataCache_l765) begin
      stageA_request_wr <= io_cpu_execute_args_wr;
      stageA_request_size <= io_cpu_execute_args_size;
      stageA_request_totalyConsistent <= io_cpu_execute_args_totalyConsistent;
    end
    if(when_DataCache_l765_1) begin
      stageA_mask <= stage0_mask;
    end
    if(when_DataCache_l765_2) begin
      stageA_wayInvalidate <= stage0_wayInvalidate;
    end
    if(when_DataCache_l765_3) begin
      stage0_dataColisions_regNextWhen <= stage0_dataColisions;
    end
    if(when_DataCache_l816) begin
      stageB_request_wr <= stageA_request_wr;
      stageB_request_size <= stageA_request_size;
      stageB_request_totalyConsistent <= stageA_request_totalyConsistent;
    end
    if(when_DataCache_l818) begin
      stageB_mmuRsp_physicalAddress <= io_cpu_memory_mmuRsp_physicalAddress;
      stageB_mmuRsp_isIoAccess <= io_cpu_memory_mmuRsp_isIoAccess;
      stageB_mmuRsp_isPaging <= io_cpu_memory_mmuRsp_isPaging;
      stageB_mmuRsp_allowRead <= io_cpu_memory_mmuRsp_allowRead;
      stageB_mmuRsp_allowWrite <= io_cpu_memory_mmuRsp_allowWrite;
      stageB_mmuRsp_allowExecute <= io_cpu_memory_mmuRsp_allowExecute;
      stageB_mmuRsp_exception <= io_cpu_memory_mmuRsp_exception;
      stageB_mmuRsp_refilling <= io_cpu_memory_mmuRsp_refilling;
      stageB_mmuRsp_bypassTranslation <= io_cpu_memory_mmuRsp_bypassTranslation;
    end
    if(when_DataCache_l815) begin
      stageB_tagsReadRsp_0_valid <= ways_0_tagsReadRsp_valid;
      stageB_tagsReadRsp_0_error <= ways_0_tagsReadRsp_error;
      stageB_tagsReadRsp_0_address <= ways_0_tagsReadRsp_address;
    end
    if(when_DataCache_l815_1) begin
      stageB_tagsReadRsp_1_valid <= ways_1_tagsReadRsp_valid;
      stageB_tagsReadRsp_1_error <= ways_1_tagsReadRsp_error;
      stageB_tagsReadRsp_1_address <= ways_1_tagsReadRsp_address;
    end
    if(when_DataCache_l815_2) begin
      stageB_dataReadRsp_0 <= ways_0_dataReadRsp;
    end
    if(when_DataCache_l815_3) begin
      stageB_dataReadRsp_1 <= ways_1_dataReadRsp;
    end
    if(when_DataCache_l814) begin
      stageB_wayInvalidate <= stageA_wayInvalidate;
    end
    if(when_DataCache_l814_1) begin
      stageB_dataColisions <= stageA_dataColisions;
    end
    if(when_DataCache_l814_2) begin
      stageB_waysHitsBeforeInvalidate <= stageA_wayHits;
    end
    if(when_DataCache_l814_3) begin
      stageB_mask <= stageA_mask;
    end
    loader_valid_regNext <= loader_valid;
  end

  always @(posedge clk or posedge reset) begin
    if(reset) begin
      memCmdSent <= 1'b0;
      stageB_flusher_waitDone <= 1'b0;
      stageB_flusher_counter <= 4'b0000;
      stageB_flusher_start <= 1'b1;
      loader_valid <= 1'b0;
      loader_waysAllocator <= 2'b01;
      loader_error <= 1'b0;
      loader_killReg <= 1'b0;
    end else begin
      if(io_mem_cmd_fire) begin
        memCmdSent <= 1'b1;
      end
      if(when_DataCache_l680) begin
        memCmdSent <= 1'b0;
      end
      if(io_cpu_flush_ready) begin
        stageB_flusher_waitDone <= 1'b0;
      end
      if(when_DataCache_l844) begin
        if(when_DataCache_l850) begin
          stageB_flusher_counter <= (stageB_flusher_counter + 4'b0001);
        end
      end
      stageB_flusher_start <= (((((((! stageB_flusher_waitDone) && (! stageB_flusher_start)) && io_cpu_flush_valid) && (! io_cpu_execute_isValid)) && (! io_cpu_memory_isValid)) && (! io_cpu_writeBack_isValid)) && (! io_cpu_redo));
      if(stageB_flusher_start) begin
        stageB_flusher_waitDone <= 1'b1;
        stageB_flusher_counter <= 4'b0000;
      end
      `ifndef SYNTHESIS
        `ifdef FORMAL
          assert((! ((io_cpu_writeBack_isValid && (! io_cpu_writeBack_haltIt)) && io_cpu_writeBack_isStuck))); // DataCache.scala:L1065
        `else
          if(!(! ((io_cpu_writeBack_isValid && (! io_cpu_writeBack_haltIt)) && io_cpu_writeBack_isStuck))) begin
            $display("ERROR writeBack stuck by another plugin is not allowed"); // DataCache.scala:L1065
          end
        `endif
      `endif
      if(stageB_loaderValid) begin
        loader_valid <= 1'b1;
      end
      if(loader_kill) begin
        loader_killReg <= 1'b1;
      end
      if(when_DataCache_l1078) begin
        loader_error <= (loader_error || io_mem_rsp_payload_error);
      end
      if(loader_done) begin
        loader_valid <= 1'b0;
        loader_error <= 1'b0;
        loader_killReg <= 1'b0;
      end
      if(when_DataCache_l1106) begin
        loader_waysAllocator <= _zz_loader_waysAllocator[1:0];
      end
    end
  end


endmodule

module InstructionCache (
  input               io_flush,
  input               io_cpu_prefetch_isValid,
  output reg          io_cpu_prefetch_haltIt,
  input      [31:0]   io_cpu_prefetch_pc,
  input               io_cpu_fetch_isValid,
  input               io_cpu_fetch_isStuck,
  input               io_cpu_fetch_isRemoved,
  input      [31:0]   io_cpu_fetch_pc,
  output     [31:0]   io_cpu_fetch_data,
  input      [31:0]   io_cpu_fetch_mmuRsp_physicalAddress,
  input               io_cpu_fetch_mmuRsp_isIoAccess,
  input               io_cpu_fetch_mmuRsp_isPaging,
  input               io_cpu_fetch_mmuRsp_allowRead,
  input               io_cpu_fetch_mmuRsp_allowWrite,
  input               io_cpu_fetch_mmuRsp_allowExecute,
  input               io_cpu_fetch_mmuRsp_exception,
  input               io_cpu_fetch_mmuRsp_refilling,
  input               io_cpu_fetch_mmuRsp_bypassTranslation,
  output     [31:0]   io_cpu_fetch_physicalAddress,
  input               io_cpu_decode_isValid,
  input               io_cpu_decode_isStuck,
  input      [31:0]   io_cpu_decode_pc,
  output     [31:0]   io_cpu_decode_physicalAddress,
  output     [31:0]   io_cpu_decode_data,
  output              io_cpu_decode_cacheMiss,
  output              io_cpu_decode_error,
  output              io_cpu_decode_mmuRefilling,
  output              io_cpu_decode_mmuException,
  input               io_cpu_decode_isUser,
  input               io_cpu_fill_valid,
  input      [31:0]   io_cpu_fill_payload,
  output              io_mem_cmd_valid,
  input               io_mem_cmd_ready,
  output     [31:0]   io_mem_cmd_payload_address,
  output     [2:0]    io_mem_cmd_payload_size,
  input               io_mem_rsp_valid,
  input      [31:0]   io_mem_rsp_payload_data,
  input               io_mem_rsp_payload_error,
  input               clk,
  input               reset
);

  reg        [31:0]   _zz_banks_0_port1;
  reg        [25:0]   _zz_ways_0_tags_port1;
  wire       [25:0]   _zz_ways_0_tags_port;
  reg                 _zz_1;
  reg                 _zz_2;
  reg                 lineLoader_fire;
  reg                 lineLoader_valid;
  (* keep , syn_keep *) reg        [31:0]   lineLoader_address /* synthesis syn_keep = 1 */ ;
  reg                 lineLoader_hadError;
  reg                 lineLoader_flushPending;
  reg        [4:0]    lineLoader_flushCounter;
  wire                when_InstructionCache_l338;
  reg                 _zz_when_InstructionCache_l342;
  wire                when_InstructionCache_l342;
  wire                when_InstructionCache_l351;
  reg                 lineLoader_cmdSent;
  wire                io_mem_cmd_fire;
  wire                when_Utils_l513;
  reg                 lineLoader_wayToAllocate_willIncrement;
  wire                lineLoader_wayToAllocate_willClear;
  wire                lineLoader_wayToAllocate_willOverflowIfInc;
  wire                lineLoader_wayToAllocate_willOverflow;
  (* keep , syn_keep *) reg        [1:0]    lineLoader_wordIndex /* synthesis syn_keep = 1 */ ;
  wire                lineLoader_write_tag_0_valid;
  wire       [3:0]    lineLoader_write_tag_0_payload_address;
  wire                lineLoader_write_tag_0_payload_data_valid;
  wire                lineLoader_write_tag_0_payload_data_error;
  wire       [23:0]   lineLoader_write_tag_0_payload_data_address;
  wire                lineLoader_write_data_0_valid;
  wire       [5:0]    lineLoader_write_data_0_payload_address;
  wire       [31:0]   lineLoader_write_data_0_payload_data;
  wire                when_InstructionCache_l401;
  wire       [5:0]    _zz_fetchStage_read_banksValue_0_dataMem;
  wire                _zz_fetchStage_read_banksValue_0_dataMem_1;
  wire       [31:0]   fetchStage_read_banksValue_0_dataMem;
  wire       [31:0]   fetchStage_read_banksValue_0_data;
  wire       [3:0]    _zz_fetchStage_read_waysValues_0_tag_valid;
  wire                _zz_fetchStage_read_waysValues_0_tag_valid_1;
  wire                fetchStage_read_waysValues_0_tag_valid;
  wire                fetchStage_read_waysValues_0_tag_error;
  wire       [23:0]   fetchStage_read_waysValues_0_tag_address;
  wire       [25:0]   _zz_fetchStage_read_waysValues_0_tag_valid_2;
  wire                fetchStage_hit_hits_0;
  wire                fetchStage_hit_valid;
  wire                fetchStage_hit_error;
  wire       [31:0]   fetchStage_hit_data;
  wire       [31:0]   fetchStage_hit_word;
  wire                when_InstructionCache_l435;
  reg        [31:0]   io_cpu_fetch_data_regNextWhen;
  wire                when_InstructionCache_l459;
  reg        [31:0]   decodeStage_mmuRsp_physicalAddress;
  reg                 decodeStage_mmuRsp_isIoAccess;
  reg                 decodeStage_mmuRsp_isPaging;
  reg                 decodeStage_mmuRsp_allowRead;
  reg                 decodeStage_mmuRsp_allowWrite;
  reg                 decodeStage_mmuRsp_allowExecute;
  reg                 decodeStage_mmuRsp_exception;
  reg                 decodeStage_mmuRsp_refilling;
  reg                 decodeStage_mmuRsp_bypassTranslation;
  wire                when_InstructionCache_l459_1;
  reg                 decodeStage_hit_valid;
  wire                when_InstructionCache_l459_2;
  reg                 decodeStage_hit_error;
  reg [31:0] banks_0 [0:63];
  reg [25:0] ways_0_tags [0:15];

  assign _zz_ways_0_tags_port = {lineLoader_write_tag_0_payload_data_address,{lineLoader_write_tag_0_payload_data_error,lineLoader_write_tag_0_payload_data_valid}};
  always @(posedge clk) begin
    if(_zz_1) begin
      banks_0[lineLoader_write_data_0_payload_address] <= lineLoader_write_data_0_payload_data;
    end
  end

  always @(posedge clk) begin
    if(_zz_fetchStage_read_banksValue_0_dataMem_1) begin
      _zz_banks_0_port1 <= banks_0[_zz_fetchStage_read_banksValue_0_dataMem];
    end
  end

  always @(posedge clk) begin
    if(_zz_2) begin
      ways_0_tags[lineLoader_write_tag_0_payload_address] <= _zz_ways_0_tags_port;
    end
  end

  always @(posedge clk) begin
    if(_zz_fetchStage_read_waysValues_0_tag_valid_1) begin
      _zz_ways_0_tags_port1 <= ways_0_tags[_zz_fetchStage_read_waysValues_0_tag_valid];
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(lineLoader_write_data_0_valid) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    _zz_2 = 1'b0;
    if(lineLoader_write_tag_0_valid) begin
      _zz_2 = 1'b1;
    end
  end

  always @(*) begin
    lineLoader_fire = 1'b0;
    if(io_mem_rsp_valid) begin
      if(when_InstructionCache_l401) begin
        lineLoader_fire = 1'b1;
      end
    end
  end

  always @(*) begin
    io_cpu_prefetch_haltIt = (lineLoader_valid || lineLoader_flushPending);
    if(when_InstructionCache_l338) begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
    if(when_InstructionCache_l342) begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
    if(io_flush) begin
      io_cpu_prefetch_haltIt = 1'b1;
    end
  end

  assign when_InstructionCache_l338 = (! lineLoader_flushCounter[4]);
  assign when_InstructionCache_l342 = (! _zz_when_InstructionCache_l342);
  assign when_InstructionCache_l351 = (lineLoader_flushPending && (! (lineLoader_valid || io_cpu_fetch_isValid)));
  assign io_mem_cmd_fire = (io_mem_cmd_valid && io_mem_cmd_ready);
  assign io_mem_cmd_valid = (lineLoader_valid && (! lineLoader_cmdSent));
  assign io_mem_cmd_payload_address = {lineLoader_address[31 : 4],4'b0000};
  assign io_mem_cmd_payload_size = 3'b100;
  assign when_Utils_l513 = (! lineLoader_valid);
  always @(*) begin
    lineLoader_wayToAllocate_willIncrement = 1'b0;
    if(when_Utils_l513) begin
      lineLoader_wayToAllocate_willIncrement = 1'b1;
    end
  end

  assign lineLoader_wayToAllocate_willClear = 1'b0;
  assign lineLoader_wayToAllocate_willOverflowIfInc = 1'b1;
  assign lineLoader_wayToAllocate_willOverflow = (lineLoader_wayToAllocate_willOverflowIfInc && lineLoader_wayToAllocate_willIncrement);
  assign lineLoader_write_tag_0_valid = ((1'b1 && lineLoader_fire) || (! lineLoader_flushCounter[4]));
  assign lineLoader_write_tag_0_payload_address = (lineLoader_flushCounter[4] ? lineLoader_address[7 : 4] : lineLoader_flushCounter[3 : 0]);
  assign lineLoader_write_tag_0_payload_data_valid = lineLoader_flushCounter[4];
  assign lineLoader_write_tag_0_payload_data_error = (lineLoader_hadError || io_mem_rsp_payload_error);
  assign lineLoader_write_tag_0_payload_data_address = lineLoader_address[31 : 8];
  assign lineLoader_write_data_0_valid = (io_mem_rsp_valid && 1'b1);
  assign lineLoader_write_data_0_payload_address = {lineLoader_address[7 : 4],lineLoader_wordIndex};
  assign lineLoader_write_data_0_payload_data = io_mem_rsp_payload_data;
  assign when_InstructionCache_l401 = (lineLoader_wordIndex == 2'b11);
  assign _zz_fetchStage_read_banksValue_0_dataMem = io_cpu_prefetch_pc[7 : 2];
  assign _zz_fetchStage_read_banksValue_0_dataMem_1 = (! io_cpu_fetch_isStuck);
  assign fetchStage_read_banksValue_0_dataMem = _zz_banks_0_port1;
  assign fetchStage_read_banksValue_0_data = fetchStage_read_banksValue_0_dataMem[31 : 0];
  assign _zz_fetchStage_read_waysValues_0_tag_valid = io_cpu_prefetch_pc[7 : 4];
  assign _zz_fetchStage_read_waysValues_0_tag_valid_1 = (! io_cpu_fetch_isStuck);
  assign _zz_fetchStage_read_waysValues_0_tag_valid_2 = _zz_ways_0_tags_port1;
  assign fetchStage_read_waysValues_0_tag_valid = _zz_fetchStage_read_waysValues_0_tag_valid_2[0];
  assign fetchStage_read_waysValues_0_tag_error = _zz_fetchStage_read_waysValues_0_tag_valid_2[1];
  assign fetchStage_read_waysValues_0_tag_address = _zz_fetchStage_read_waysValues_0_tag_valid_2[25 : 2];
  assign fetchStage_hit_hits_0 = (fetchStage_read_waysValues_0_tag_valid && (fetchStage_read_waysValues_0_tag_address == io_cpu_fetch_mmuRsp_physicalAddress[31 : 8]));
  assign fetchStage_hit_valid = (|fetchStage_hit_hits_0);
  assign fetchStage_hit_error = fetchStage_read_waysValues_0_tag_error;
  assign fetchStage_hit_data = fetchStage_read_banksValue_0_data;
  assign fetchStage_hit_word = fetchStage_hit_data;
  assign io_cpu_fetch_data = fetchStage_hit_word;
  assign when_InstructionCache_l435 = (! io_cpu_decode_isStuck);
  assign io_cpu_decode_data = io_cpu_fetch_data_regNextWhen;
  assign io_cpu_fetch_physicalAddress = io_cpu_fetch_mmuRsp_physicalAddress;
  assign when_InstructionCache_l459 = (! io_cpu_decode_isStuck);
  assign when_InstructionCache_l459_1 = (! io_cpu_decode_isStuck);
  assign when_InstructionCache_l459_2 = (! io_cpu_decode_isStuck);
  assign io_cpu_decode_cacheMiss = (! decodeStage_hit_valid);
  assign io_cpu_decode_error = (decodeStage_hit_error || ((! decodeStage_mmuRsp_isPaging) && (decodeStage_mmuRsp_exception || (! decodeStage_mmuRsp_allowExecute))));
  assign io_cpu_decode_mmuRefilling = decodeStage_mmuRsp_refilling;
  assign io_cpu_decode_mmuException = (((! decodeStage_mmuRsp_refilling) && decodeStage_mmuRsp_isPaging) && (decodeStage_mmuRsp_exception || (! decodeStage_mmuRsp_allowExecute)));
  assign io_cpu_decode_physicalAddress = decodeStage_mmuRsp_physicalAddress;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      lineLoader_valid <= 1'b0;
      lineLoader_hadError <= 1'b0;
      lineLoader_flushPending <= 1'b1;
      lineLoader_cmdSent <= 1'b0;
      lineLoader_wordIndex <= 2'b00;
    end else begin
      if(lineLoader_fire) begin
        lineLoader_valid <= 1'b0;
      end
      if(lineLoader_fire) begin
        lineLoader_hadError <= 1'b0;
      end
      if(io_cpu_fill_valid) begin
        lineLoader_valid <= 1'b1;
      end
      if(io_flush) begin
        lineLoader_flushPending <= 1'b1;
      end
      if(when_InstructionCache_l351) begin
        lineLoader_flushPending <= 1'b0;
      end
      if(io_mem_cmd_fire) begin
        lineLoader_cmdSent <= 1'b1;
      end
      if(lineLoader_fire) begin
        lineLoader_cmdSent <= 1'b0;
      end
      if(io_mem_rsp_valid) begin
        lineLoader_wordIndex <= (lineLoader_wordIndex + 2'b01);
        if(io_mem_rsp_payload_error) begin
          lineLoader_hadError <= 1'b1;
        end
      end
    end
  end

  always @(posedge clk) begin
    if(io_cpu_fill_valid) begin
      lineLoader_address <= io_cpu_fill_payload;
    end
    if(when_InstructionCache_l338) begin
      lineLoader_flushCounter <= (lineLoader_flushCounter + 5'h01);
    end
    _zz_when_InstructionCache_l342 <= lineLoader_flushCounter[4];
    if(when_InstructionCache_l351) begin
      lineLoader_flushCounter <= 5'h0;
    end
    if(when_InstructionCache_l435) begin
      io_cpu_fetch_data_regNextWhen <= io_cpu_fetch_data;
    end
    if(when_InstructionCache_l459) begin
      decodeStage_mmuRsp_physicalAddress <= io_cpu_fetch_mmuRsp_physicalAddress;
      decodeStage_mmuRsp_isIoAccess <= io_cpu_fetch_mmuRsp_isIoAccess;
      decodeStage_mmuRsp_isPaging <= io_cpu_fetch_mmuRsp_isPaging;
      decodeStage_mmuRsp_allowRead <= io_cpu_fetch_mmuRsp_allowRead;
      decodeStage_mmuRsp_allowWrite <= io_cpu_fetch_mmuRsp_allowWrite;
      decodeStage_mmuRsp_allowExecute <= io_cpu_fetch_mmuRsp_allowExecute;
      decodeStage_mmuRsp_exception <= io_cpu_fetch_mmuRsp_exception;
      decodeStage_mmuRsp_refilling <= io_cpu_fetch_mmuRsp_refilling;
      decodeStage_mmuRsp_bypassTranslation <= io_cpu_fetch_mmuRsp_bypassTranslation;
    end
    if(when_InstructionCache_l459_1) begin
      decodeStage_hit_valid <= fetchStage_hit_valid;
    end
    if(when_InstructionCache_l459_2) begin
      decodeStage_hit_error <= fetchStage_hit_error;
    end
  end


endmodule
