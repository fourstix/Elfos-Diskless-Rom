# Step by Step Build Instructions for MChip Elf/OS Diskless ROM

Here are the steps below to build the MChip Elf/OS Diskless ROM from the source files on Windows.

Pre-Requisites
--------------
1. Install the Windows version of Asm/02
  * Go to the [Asm/02 Releases](https://github.com/fourstix/Asm-02/releases) page for the [Asm-02](https://github.com/fourstix/Asm-02) Repository on GitHub.
  * Create an Asm02 subdirectory on your Windows computer, for example C:\\Users\\Your_Name\\Asm02 might be a good path name.
  * The top release on the page is the latest release. Click on the link for Asm02.exe to download the windows executable.
  * Save the executable file to your Asm02 directory. 
  * Click on the Asm.doc link to download the Asm02 documentation file.
  * Save the documentation file to your Asm02 directory.
   
2. Create an mchip subdirectory.
  * Create an include subdirectory underneath the mchip subdirectory.
  * Create a source subdirectory underneath the mchip subdirectory.
  * Create a merge subdirectory underneath the mchip subdirectory.
  * The mchip subdirectory should now have three subdirectories underneath it named include, source and merge.
  
3. Download the code from the [Elfos-Diskless-Rom](https://github.com/fourstix/Elfos-Diskless-Rom) repository on GitHub.
  * Go to the [Elfos-Diskless-Rom](https://github.com/fourstix/Elfos-Diskless-Rom) repository on GitHub and click on the Green button labeled "<> Code".
  * Click on the "Download ZIP" menu item.
  * Save the "Elfos-Diskless-Rom-main.zip" file locally in a temporary directory.
  * Unpack the zip file in a temporary directory named "Eflos-Diskless-Rom-main"
  * In the instructions below temp\\Eflos-Diskless-Rom-main refers to this temporary subdirectory and mchip\\source, mchip\\include and mchip\\merge refer to the target directories.
   
4. Copy the 3 batch files to mchip\\source subdirectory. 
  * Copy the batch files named clean.bat, mchip_hex.bat and mchip_build.bat from the temp\\Elfos-Diskless-Rom-main\\mchip\\build directory into the mchip\\source directory.
  
5. Edit the batch files in mchip\\source subdirectory to set the path to Asm02.exe.
  * Edit mchip_hex.bat and replace the text [Your_Path] with the actual path to the Asm02.exe file.
  * Edit mchip_build.bat and replace the text [Your_Path] with the actual path to the Asm02.exe file.
  * The clean.bat batch file does not contain any path information, so it can be left as-is.
  
6. Copy the rommerge tool and mchip_rom.bat batch file to the mchip\\merge directory.
  * Copy the make_mchip.bat batch file from the temp\\Elfos-Diskless-Rom-main\\mchip\\merge directory into the mchip\\merge directory.
  * Copy the rommerge.exe executable from the temp\\Elfos-Diskless-Rom-main\\mchip\\merge directory into the mchip\\merge directory.
  * Edit make_mchip.bat batch file and replace the text [Your_Path] with the actual path to the Asm02.exe file.
    
7. At this point the batch files and tools are set up to build the MChip Elf/OS Diskless ROM.  
  * This can be done by copying the hex files from temp\\Elfos-Diskless-Rom-main\\mchip\\merge directory into the mchip\\merge directory and running the make_mchip.bat batch file to merge them into the rom hex file.
  * This can also be done by copy the source files from temp\\Elfos-Diskless-Rom-main\\source into the mchip\\merge directory and running the mchip_build.bat batch file to create the hex files from source, and then copying the hex files to the merge directory, before running the make_mchip.bat batch file to merge them into a new rom hex file.
  * The steps below walk you through the second procedure to build everything from scratch. 
    
Build the MChip Elf/OS Diskless ROM
-----------------------------------

1. Copy source files to mchip\\source subdirectory. 
  * Copy all assembly files from temp\\Elfos-Diskless-Rom-main\\source directory to the mchip\\source directory. 
  * It's not necessary to copy the tools subdirectory or any files in it.  
    
2. Copy the include files to the mchip\\include subdirectory. 
  * Copy the bios.inc, ops.inc and opscode.inc files from temp\\Elfos-Diskless-Rom-main\\include directory to the mchip\\include directory. 
    
3. Run the mchip_build.bat batch file in the mchip\\source directory. 
  * The mchip_build.bat will create all the hex files from the source.
  * An individual hex file can be created by using the mchip_hex.bat batch file and passing it the name of the assembly file.  For example, the command *mchip_hex bios.asm* should create the bios.hex file.  
    
4. Copy all nine hex files into the mchip\\merge directory. 
  
5. Run the make_mchip.bat batch file to merge the hex files into the MChip Elf/OS Diskless ROM mchip.hex file. 
  * The file created will be named mchip.hex.
  * This file can be loaded into your PROM burner to create the ROM.
  * The file has an origin at $0000 and should be 32K in size when loaded.
  
  
