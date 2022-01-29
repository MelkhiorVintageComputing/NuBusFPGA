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

from litex.soc.integration.export import _get_rw_functions_c

# for generating a timestamp in the description field, if none is otherwise given
import datetime
import time


### _get_rw_functions_c(          reg_name, reg_base,            nwords, busword, alignment, read_only, with_access_functions):
def _get_rw_functions_c_DIS(name, csr_name, reg_base, area_base, nwords, busword, alignment, read_only, with_access_functions):
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
        r += "static inline {} {}_read(struct nubusfpga_{}_softc *sc) {{\n".format(ctype, reg_name, name)
        if nwords > 1:
            r += "\t{} r = bus_space_read_4(sc->slotid, {}L);\n".format(ctype, hex(reg_base - area_base))
            for sub in range(1, nwords):
                r += "\tr <<= {};\n".format(busword)
                r += "\tr |= bus_space_read_4(sc->slotid, {}L);\n".format(hex(reg_base - area_base + sub*stride))
            r += "\treturn r;\n}\n"
        else:
            r += "\treturn bus_space_read_4(sc->slotid, {}L);\n}}\n".format(hex(reg_base - area_base))

        if not read_only:
            r += "static inline void {}_write(struct nubusfpga_{}_softc *sc, {} v) {{\n".format(reg_name, name, ctype)
            for sub in range(nwords):
                shift = (nwords-sub-1)*busword
                if shift:
                    v_shift = "v >> {}".format(shift)
                else:
                    v_shift = "v"
                r += "\tbus_space_write_4(sc->slotid, {}L, {});\n".format(hex(reg_base - area_base + sub*stride), v_shift)
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
        r += "#define CSR_BASE {}L\n".format(hex(csr_base))
        r += "#endif\n"
        r += "#ifndef CSR_"+name.upper()+"_BASE\n"
        r += "#define CSR_"+name.upper()+"_BASE (CSR_BASE + "+hex(origin)+"L)\n"
        if not isinstance(region.obj, Memory):
            for csr in region.obj:
                nr = (csr.size + region.busword - 1)//region.busword
                r += _get_rw_functions_c(csr.name, origin, nr, region.busword, alignment,
                    getattr(csr, "read_only", False), with_access_functions)
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
                            r += "static inline uint32_t " + field_name + "_extract(struct nubusfpga_" + name + "_softc *sc, uint32_t oldword) {\n"
                            r += "\tuint32_t mask = ((1 << " + size + ")-1);\n"
                            r += "\treturn ( (oldword >> " + offset + ") & mask );\n}\n"
                            r += "static inline uint32_t " + field_name + "_read(struct nubusfpga_" + name + "_softc *sc) {\n"
                            r += "\tuint32_t word = " + reg_name + "_read(sc);\n"
                            r += "\treturn " + field_name + "_extract(sc, word);\n"
                            r += "}\n"
                            if not getattr(csr, "read_only", False):
                                r += "static inline uint32_t " + field_name + "_replace(struct nubusfpga_" + name + "_softc *sc, uint32_t oldword, uint32_t plain_value) {\n"
                                r += "\tuint32_t mask = ((1 << " + size + ")-1);\n"
                                r += "\treturn (oldword & (~(mask << " + offset + "))) | (mask & plain_value)<< " + offset + " ;\n}\n"
                                r += "static inline void " + field_name + "_write(struct nubusfpga_" + name + "_softc *sc, uint32_t plain_value) {\n"
                                r += "\tuint32_t oldword = " + reg_name + "_read(sc);\n"
                                r += "\tuint32_t newword = " + field_name + "_replace(sc, oldword, plain_value);\n"
                                r += "\t" + reg_name + "_write(sc, newword);\n"
                                r += "}\n"

        r += "#endif // CSR_"+name.upper()+"_BASE\n"
        r += "\n#endif\n"
        ar[name] = r
            
    return ar
