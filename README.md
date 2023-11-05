# Elfos-Diskless-Rom
Binary and hex image files along with source files and build files for the Diskless Elf/OS ROM.

There are two sets of ROM images available, one for the MemberChip card and another for the Pico/ELf v2 microcomputer.  More information about both platforms and about the 1802 Microprocessor in general can be found on the [Cosmac Elf Group on Groups.io.](https://groups.io/g/cosmacelf)   

1802 MicroCHIP Microcomputer
----------------------------
The [1802 MemberCHIP Microcomputer Card](https://www.sunrise-ev.com/projects.htm#memberchip) was designed by Lee Hart and the [1802 MemberCHIP Card kit](https://www.sunrise-ev.com/projects.htm#memberchip) is available at his [website.](https://www.sunrise-ev.com/projects.htm#memberchip)

[![1802 MemberCHIP Microcomputer Card](https://www.sunrise-ev.com/photos/1802/1802me-assembled.jpg)](https://www.sunrise-ev.com/projects.htm#memberchip)]

## MemberChip Elf/OS ROM Program Menu:
1. [Rc/Basic L2](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/rcbasic.txt)
2. [Rc/Forth](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/rcforth.txt)
3. [Rc/Lisp](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/rclisp.txt)
4. [EDTASM](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/edtasm.txt)
5. [VTL2](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/vtl2.txt)
6. [Visual/02](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/visual02.txt)
7. [Minimon](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/minimon.txt)
8. Dump Memory
9. Load Memory

## Exit Commands
<table>
<tr><th>Program</th><th>Exit Command</th></tr>
<tr><td>Rc/Basic L2</td><td>BYE</td></tr>
<tr><td>Rc/Forth</td><td>bye</td></tr>
<tr><td>Rc/Lisp</td><td>bye</td></tr>
<tr><td>EDTASM</td><td>q</td></tr>
<tr><td>VTL2</td><td>*=0</td></tr>
<tr><td>Visual/02</td><td>e</td></tr>
<tr><td>Minimon</td><td>/ or @0003</td></tr>
</table>

Note: The Dump Memory and Load Memory commands end after the XModem transfer is complete.

## Build Instructions
Step by step instructions on how to build the MChip Elf/OS Diskless ROM are available [here.](MChipBuildSteps.md)

## MemberChip Elf/OS ROM Memory Map
<table>
<tr><th>Address</th><th>Program</th></tr>
<tr><td>0000h</td><td>BIOS + Minimon</td></tr>
<tr><td>1000h</td><td>Rc/Lisp</td></tr>
<tr><td>2000h</td><td>Rc/Forth</td></tr>
<tr><td>3000h</td><td>EDTASM</td></tr>
<tr><td>4000h</td><td>Rc/Basic L2</td></tr>
<tr><td>6000h</td><td>Visual/02</td></tr>
<tr><td>7000h</td><td>Menu + XModem</td></tr>
<tr><td>7800h</td><td>VTL2</td></tr>
</table>

Pico/Elf v2 Microcomputer
-------------------------
The [Pico/Elf v2 Microcomputer](http://www.elf-emulation.com/picoelf.html) was designed by Mike Riley. Information about the Pico/Elf v2 Microcomputer is available on the [Elf-Emulation website](http://www.elf-emulation.com/) and an archive of his website is [available on Github.](https://github.com/rileym65/Website-ElfEmulation)

[![Pico/Elf v2 Microcomputer](http://www.elf-emulation.com/picoelfbuild2.jpg)](http://www.elf-emulation.com/picoelf.html)]

## Pico/Elf Diskless ROM Programs:
1. [Rc/Basic L2](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/rcbasic.txt)
2. [Rc/Forth](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/rcforth.txt)
3. [Rc/Lisp](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/rclisp.txt)
4. [EDTASM](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/edtasm.txt)
5. [Visual/02](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/visual02.txt)
6. [Minimon](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/docs/minimon.txt)
7. Dump Memory
8. Load Memory

## Exit Commands
<table>
<tr><th>Program</th><th>Exit Command</th></tr>
<tr><td>Rc/Basic L2</td><td>BYE</td></tr>
<tr><td>Rc/Forth</td><td>bye</td></tr>
<tr><td>Rc/Lisp</td><td>bye</td></tr>
<tr><td>EDTASM</td><td>q</td></tr>
<tr><td>VTL2</td><td>*=0</td></tr>
<tr><td>Visual/02</td><td>e</td></tr>
<tr><td>Minimon</td><td>/ or @0003</td></tr>
</table>

Note: The Dump Memory and Load Memory commands end after the XModem transfer is complete.

## Build Instructions
[Step by step instructions](PicoBuildSteps.md) on how to build the MChip Elf/OS Diskless ROM are available [here.](PicoBuildSteps.md)

## Pico/Elf Diskless ROM Memory Map
<table>
<tr><th>Address</th><th>Program</th></tr>
<tr><td>8000h</td><td>Menu + XModem</td></tr>
<tr><td>8800h</td><td>VTL2</td></tr>
<tr><td>9000h</td><td>Rc/Lisp</td></tr>
<tr><td>A000h</td><td>Rc/Forth</td></tr>
<tr><td>B000h</td><td>EDTASM</td></tr>
<tr><td>C000h</td><td>Rc/Basic L2</td></tr>
<tr><td>E000h</td><td>Visual/02</td></tr>
<tr><td>F000h</td><td>BIOS + Minimon</td></tr>
</table>

Assembler
---------
The source programs are assembled into hex files with an updated versions of the Asm/02 assembler written by Mike Riley with updates by Tony Hefner. The updated version required to assemble this code is available at the [Asm-02 repository](https://github.com/fourstix/Asm-02) on GitHub.

Common Programs
---------------
* [Rc/Basic L2](https://github.com/fourstix/Elf-RcBasic) -- A Level 2 BASIC interpreter written by Mike Riley with updates by Al Williams and Gaston Williams.
* [Rc/Forth](https://github.com/fourstix/Elf-RcForth) -- A stack based language interpreter written by Mike Riley with updates by Gaston Williams.
* [Rc/Lisp](https://github.com/fourstix/Elf-rclisp) -- A LISt Processor programming language interpreter written by Mike Riley with updates by Gaston Williams.
* [EDTASM](https://github.com/fourstix/Elf-EDTASM) -- An editor with integrated in-memory assembler written by Mike Riley with updates by All Williams Gaston Williams.
* [VTL2](https://github.com/fourstix/Elf-Elfos-VTL2) -- A Very Tiny Language interpreter written by Mike Riley with updates by Gaston Williams. 
* [Visual/02](https://github.com/fourstix/Elf-Visual02) -- A visual monitor with breakpoints, traps, and multi-instruction execution written by Mike Riley with updates by Gaston Williams. 
* [Minimon](https://github.com/fourstix/Elf-BIOS) -- A small monitor program for changing and viewing memory written by Mike Riley with updates by Gaston Williams.
* Dump/Load Memory -- send and receive commands that use the XModem routines contained in the [Elf-Diskless](https://github.com/fourstix/Elfos-Diskless-Rom) menu program written by Mike Riley with updates by Gaston Williams.

Common Source Files
-------------------
* [Elf/OS BIOS](https://github.com/fourstix/Elf-BIOS) -- A Basic Input/Output Subsystem with a set of API for the underlying hardware for many 1802 Elf/OS based microcomputers written by Mike Riley with updates by Bob Armstrong and Gaston Williams.
* [Elf-Diskless Menu](https://github.com/fourstix/Elfos-Diskless-Rom) -- Menu commands for invoking the programs with XModem logic to send and receive data.

MChip Init Source File
----------------------
* [Init](https://github.com/fourstix/Elfos-Diskless-Rom/blob/main/source/init.asm) -- Defines the BIOS cold boot and warm boot vectors for the MChip ROM.

Repository Contents
-------------------
* **/source** -- source files for ROM programs
  * bios.asm -- Elf/OS BIOS source file
  * diskless.asm -- Menu and XModem logic
  * edtasm.asm -- EDTASM assembler source file
  * forth.asm -- RC/Forth program source file
  * init.asm -- Initialization vectors for MCHIP ROM **(MChip only)**
  * rcbasic.asm -- RC/Basic program source files
  * rclisp.asm -- RC/Lisp program source files
  * visual02.asm -- Visual/02 program source files
  * vtl2.asm -- VTL2 Interpeter progrma source files 
* **/source/tools** -- source files for tool used to create ROM files 
  * rommerge.c -- source file for the ROM tools used to merge hex files
  * LICENSE.TXT -- ROM tools license
  * readme.txt -- ROM tool documentation
  * Source files for other ROM tools that were not used to create the Elf/OS Diskless ROM images, such as romcksum and romtext. 
* **/include** -- included files for ROM program source files
  * bios.inc -- bios definitions
  * ops.inc -- original opcode definitions
  * opscode.inc -- expanded opcode definitions    
* **/mchip/** -- files unique to the MChip Diskless Elf/OS ROM
* **/mchip/rom** -- MChip ROM binary and hex image files created by the build and merge process 
* **/mchip/merge** -- Hex files and tools used to create MChip ROM image
  * Hex files assembled for MChip from source files
  * rommerge.exe -- Tool used to merge multiple hex files into single ROM hex image
  * mchip_rom.bat -- Batch file to create a ROM hex image using rommerge. Replace [Your_Path] with the correct path information for your system.
* **/mchip/build** -- files used to build hex files from source files 
  * clean.bat -- file to delete previous build files
  * mchip_build.bat -- file to build all MChip hex files from source files. Replace [Your_Path] with the correct path information for your system.
  * mchip_hex.bat -- file to create a single hex file from a source file. Replace [Your_Path] with the correct path information for your system.
* **/pico/** -- files unique to the Pico/Elf Diskless ROM
* **/pico/rom** -- Pico/Elf ROM binary and hex image files created by the build and merge process 
* **/pico/merge** -- Hex files and tools used to create Pico/Elf ROM image
  * Hex files assembled for the Pico/Elf from source files
  * rommerge.exe -- Tool used to merge multiple hex files into single ROM hex image
  * mchip_rom.bat -- Batch file to create a ROM hex image using rommerge. Replace [Your_Path] with the correct path information for your system.
* **/pico/build** -- files used to build hex files from source files 
  * clean.bat -- file to delete previous build files
  * pico_build.bat -- file to build all Pico/Elf hex files from source files. Replace [Your_Path] with the correct path information for your system.
  * pico_hex.bat -- file to create a single hex file from a source file. Replace [Your_Path] with the correct path information for your system.   
* **/docs** -- documentation files for Menu programs
  * Original documentation text files for each programs
  * exit.txt -- A list of exit commands for all Menu programs

License Information
-------------------

This code is public domain under the MIT License, but please buy me a beer
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Other company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.
   
The 1802 MemberCHIP Card Microcomputer  
Copyright (c) 2006-2023  by Lee A. Hart.

The Pico/Elf v2 1802 Microcomputer hardware and software  
Copyright (c) 2004-2023 by Mike Riley.

Asm/02 1802 Assembler  
Copyright (c) 2004-2023 by Mike Riley

Elf/OS BIOS, EDTASM and Visual/02 Software  
Copyright (c) 2004-2023 by Mike Riley.

RcBasic, RcLisp, RcForth and VTL2 Software  
Copyright (c) 2004-2023 by Mike Riley.

Elf/OS Diskless Software  
Copyright (c) 2004-2023 by Mike Riley.
 
Many thanks to the original authors for making their designs and code avaialble as open source.

This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2023 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
