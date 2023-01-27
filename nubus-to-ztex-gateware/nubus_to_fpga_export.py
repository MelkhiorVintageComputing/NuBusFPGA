import os
import json
import inspect
from shutil import which
from sysconfig import get_platform

from migen import *

from litex.soc.interconnect.csr import CSRStatus

from litex.build.tools import generated_banner

from litex.soc.doc.rst import reflow
from litex.soc.doc.module import gather_submodules, ModuleNotDocumented, DocumentedModule, DocumentedInterrupts
from litex.soc.doc.csr import DocumentedCSRRegion
from litex.soc.interconnect.csr import _CompoundCSR

#from litex.soc.integration.export import _get_rw_functions_c

# for generating a timestamp in the description field, if none is otherwise given
import datetime
import time


### _get_rw_functions_c(          reg_name, reg_base,            nwords, busword, alignment, read_only, with_access_functions):
def _get_rw_functions_c(name,     csr_name, reg_base, area_base, nwords, busword, alignment, read_only, with_access_functions):
    reg_name = name + "_" + csr_name
    r = ""

    addr_str = "CSR_{}_ADDR".format(reg_name.upper())
    size_str = "CSR_{}_SIZE".format(reg_name.upper())
    r += "#define {} (CSR_{}_BASE + {}L)\n".format(addr_str, name.upper(), hex(reg_base - area_base))
    r += "#define {} {}\n".format(size_str, nwords)

    size = nwords*busword//8
    if size > 8:
        # downstream should select appropriate `csr_[rd|wr]_buf_uintX()` pair!
        return r
    elif size > 4:
        ctype = "uint64_t"
    elif size > 2:
        ctype = "uint32_t"
    elif size > 1:
        ctype = "uint16_t"
    else:
        ctype = "uint8_t"

    stride = alignment//8;
    if with_access_functions:
        r += "static inline {} {}_read(uint32_t a32) {{\n".format(ctype, reg_name, name)
        if nwords > 1:
            r += "\t{} r = __builtin_bswap32(*((volatile {}*)(a32 + {})));\n".format(ctype, ctype, addr_str)
            for sub in range(1, nwords):
                r += "\tr <<= {};\n".format(busword)
                r += "\tr |= __builtin_bswap32(*((volatile {}*)(a32 + {} + {})));\n".format(ctype, addr_str, (sub*stride))
            r += "\treturn r;\n}\n"
        else:
            r += "\treturn __builtin_bswap32(*((volatile {}*)(a32 + {})));\n}}\n".format(ctype, addr_str)

        if not read_only:
            r += "static inline void {}_write(uint32_t a32, {} v) {{\n".format(reg_name, ctype)
            for sub in range(nwords):
                shift = (nwords-sub-1)*busword
                if shift:
                    v_shift = "v >> {}".format(shift)
                else:
                    v_shift = "v"
                r += "\t*((volatile {}*)(a32 + {} + {})) = __builtin_bswap32({});\n".format(ctype, addr_str, (sub*stride), v_shift)
            r += "}\n"
    return r

def get_csr_header_split(regions, constants, csr_base=None, with_access_functions=True):
    alignment = constants.get("CONFIG_CSR_ALIGNMENT", 32)
    ar = dict()
    for name, region in regions.items():
        r = generated_banner("//")
    
        r += "#ifndef __GENERATED_{}_CSR_H\n#define __GENERATED_{}_CSR_H\n".format(name.upper(), name.upper())
        csr_base = csr_base if csr_base is not None else regions[next(iter(regions))].origin
        
        origin = region.origin - csr_base
        r += "\n/* "+name+" */\n"
        r += "#ifndef CSR_BASE\n"
        r += "#define CSR_BASE {}L\n".format(hex(csr_base & 0x00FFFFFF))
        r += "#endif\n"
        r += "#ifndef CSR_"+name.upper()+"_BASE\n"
        r += "#define CSR_"+name.upper()+"_BASE (CSR_BASE + "+hex(origin)+"L)\n"
        if not isinstance(region.obj, Memory):
            for csr in region.obj:
                nr = (csr.size + region.busword - 1)//region.busword
                r += _get_rw_functions_c(name = name, csr_name = csr.name, reg_base = origin, area_base = region.origin - csr_base, nwords = nr, busword = region.busword, alignment = alignment, read_only = getattr(csr, "read_only", False), with_access_functions = with_access_functions)
                origin += alignment//8*nr
                if hasattr(csr, "fields"):
                    for field in csr.fields.fields:
                        offset = str(field.offset)
                        size = str(field.size)
                        r += "#define CSR_"+name.upper()+"_"+csr.name.upper()+"_"+field.name.upper()+"_OFFSET "+offset+"\n"
                        r += "#define CSR_"+name.upper()+"_"+csr.name.upper()+"_"+field.name.upper()+"_SIZE "+size+"\n"
                        if with_access_functions and csr.size <= 32: # FIXME: Implement extract/read functions for csr.size > 32-bit.
                            reg_name = name + "_" + csr.name.lower()
                            field_name = reg_name + "_" + field.name.lower()
                            r += "static inline uint32_t " + field_name + "_extract(uint32_t a32, uint32_t oldword) {\n"
                            r += "\tuint32_t mask = ((1 << " + size + ")-1);\n"
                            r += "\treturn ( (oldword >> " + offset + ") & mask );\n}\n"
                            r += "static inline uint32_t " + field_name + "_read(uint32_t a32) {\n"
                            r += "\tuint32_t word = " + reg_name + "_read(a32);\n"
                            r += "\treturn " + field_name + "_extract(a32, word);\n"
                            r += "}\n"
                            if not getattr(csr, "read_only", False):
                                r += "static inline uint32_t " + field_name + "_replace(uint32_t a32, uint32_t oldword, uint32_t plain_value) {\n"
                                r += "\tuint32_t mask = ((1 << " + size + ")-1);\n"
                                r += "\treturn (oldword & (~(mask << " + offset + "))) | (mask & plain_value)<< " + offset + " ;\n}\n"
                                r += "static inline void " + field_name + "_write(uint32_t a32, uint32_t plain_value) {\n"
                                r += "\tuint32_t oldword = " + reg_name + "_read(a32);\n"
                                r += "\tuint32_t newword = " + field_name + "_replace(a32, oldword, plain_value);\n"
                                r += "\t" + reg_name + "_write(a32, newword);\n"
                                r += "}\n"

        r += "#endif // CSR_"+name.upper()+"_BASE\n"
        r += "\n#endif\n"
        ar[name] = r
            
    return ar
