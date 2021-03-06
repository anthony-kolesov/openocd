++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  ARC Bookshelf: Plain text OpenOCD Getting Started manual.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 Content:

	1. Digilent probe installation instructions
	2. How to build OpenOCD on Linux
	3. How to build OpenOCD for Windows (cross compile)
	4. A typical debug session using arc-elf32-gdb with openocd
	5. Advanced debug commands
	6. How to program a bit-file into FPGA by usage of a Digilent HS2 probe
	7. ARC OpenOCD configuration options
	8. ARC-GDB development commands
	9. Find your way in the source code

 NOTES:

	1. Only ARC EM Starter Kit and Digilent HS1 probe are supported.
	2. Digilent HS2 probe currently is not supported.
	3. There is NO Flash support in ARC OpenOCD implemented.


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  1. Driver installation instructions
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

If you use Digilent HS1 cable, then download and install 'Adept' from Digilent
as it has to go with the used Digilent HS1 JTAG probe.

  http://www.digilentinc.com/Products/Detail.cfm?Prod=ADEPT2

  $> tar xzfv digilent.adept.runtime_2.10.2-i686.tar.gz 
  $> cd digilent.adept.runtime_2.10.2-i686
  $> sudo ./install.sh
  $> cd ftdi.drivers_1.0.4-i686
  $> sudo ./install.sh
  $> cd ../..

  $> tar xvzf digilent.adept.utilities_2.1.1-i686.tar.gz 
  $> cd digilent.adept.utilities_2.1.1-i686
  $> sudo ./install.sh 
  $> cd ..

If you use EM Starter Kit, install FTDI drivers from
http://www.ftdichip.com/Drivers/D2XX.htm.

  ......................................................................

>$ dadutil enum
Found 1 device(s)

Device: JtagHs1
    Product Name:   Digilent JTAG-HS1
    User Name:      JtagHs1
    Serial Number:  210205812649

>$ dadutil -d JtagHs1 showinfo
Product Name:           Digilent JTAG-HS1
User Name:              JtagHs1
Serial Number:          210205812649
Product ID:             30700150
Firmware Version:       0105
Device Transport Type:  00020001 (USB)
Device Capabilities:    00000011
    DJTG - JTAG scan chain access
    DSPI - Serial Peripheral Interface

  ......................................................................

>$ djtgcfg
ERROR: no command specified
Usage: djtgcfg [--help] [--version] command [options]

  Commands:
    enum                    enumerate (discover and list) Digilent devices
    init                    initialize JTAG scan chain and list target devices
    prog                    program target device in JTAG scan chain
    erase                   erase target device in JTAG scan chain
    loop                    loop IDCODE of target device in JTAG scan chain

  Options:
    -c, --count             number of iterations for IDCODE loop
    -d                      device user name or alias
    -f, --file              programming/verification file
    -i, --index             scan chain index of target JTAG device
    -?, --help              print usage, supported arguments, and options
    -v, --version           print program version
    --verbose               display more detailed error messages

  ......................................................................

>$ dadutil
ERROR: no command specified
Usage: dadutil [--help] [--version] command [options]

  Commands:
    enum                    enumerate devices (discover and list)
    setsn                   set a device's serial number
    setusr                  set a device's user name
    showinfo                display information about a specific
    tbladd                  add an entry to the device table
    tblrem                  remove an entry from the device table

  Options:
    --alias                 alias used in device table
    --conn                  connection string used in device table
    -d                      device user name or alias
    --dtp                   device type used in device table
    --sn                    device serial number (12-digit hex)
    -t                      enumerate (list) device table entries
    --usr                   device user name
    -?, --help              print usage, supported arguments, and options
    -v, --version           print program version


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  2. How to build OpenOCD on Linux
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Install prerequisites. For Ubuntu 12.04 build host:

  $> sudo apt-get install libftdi-dev libftdi1 libtool git-core asciidoc \
       build-essential flex bison \
       libgmp3-dev libmpfr-dev autoconf automake \
       texinfo libncurses5-dev libexpat1 libexpat1-dev \
       tk tk8.4 tk8.4-dev

For RHEL 6 build host prerequisites are:

  $> sudo yum install libtool asciidoc gcc flex bison gmp-devel mpfr-devel \
     autoconf automake texinfo-tex ncurses-devel expat-devel tk-devel

Because libftdi is not available in RHEL 6 it should be downloaded and
installed manually from 3rd-party. Suggested location is:
http://pkgs.org/search/?keyword=libftdi. Download and install libftdi and
libftdi-devel packages:

  $> wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libftdi-0.18-2.el6.x86_64.rpm
  $> sudo yum install libftdi-0.18-2.el6.x86_64.rpm
  $> wget http://dl.fedoraproject.org/pub/epel/6/x86_64/libftdi-devel-0.18-2.el6.x86_64.rpm
  $> sudo yum install libftdi-devel-0.18-2.el6.x86_64.rpm

On Fedora systems libftdi is already available in official repositories:

  $> sudo apt-get install libftdi libftdi-devel

Download and install OpenOCD:

  $> git clone https://github.com/foss-for-synopsys-dwc-arc-processors/openocd

  $> cd openocd
  $> ./bootstrap
  $> ./configure --enable-ft2232_libftdi --disable-doxygen-html \
        --enable-maintainer-mode
    NOTE: for development activities, add to the above command line:
       --disable-werror --enable-verbose --enable-verbose-jtag-io
    NOTE: when documentation is required, please remove the option:
       --disable-doxygen-html
    NOTE: option --enable-maintainer-mode is required when building from GIT,
        otherwise documentation will fail to build.

  $> make
  $> sudo make install

  $> which openocd

  How to generate documentation:
  
  $> make docs
  $> make doxygen


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  3. How to build OpenOCD for Windows (cross compile)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

First, perform instructions as in section 2 "How to build OpenOCD on Linux"
When all OK, next steps are required to do a cross compilation for a Windows
host executable of OpenOCD.

Build OpenOCD for Windows on a Linux host by usage of MinGW:

  First, download the FTDI chip drivers from:

    http://www.ftdichip.com/Drivers/D2XX.htm

  Next, make sure, MXE is installed on the Linux host
  
    http://mxe.cc/#tutorial
  
  Download OpenOCD for ARC from GitHub
  
    https://github.com/foss-for-synopsys-dwc-arc-processors/openocd

  Now, execute build instructions, please visit:
    http://dangerousprototypes.com/docs/Compile_OpenOCD_for_Windows

  Ready to perform the build:

    $> ./configure --disable-doxygen-html --host=i686-pc-mingw32 \
      --build=x86_64-unknown-linux-gnu --prefix=/<home path>/openocd/install \
      --with-ftd2xx-win32-zipdir=/<home path>/openocd/CDM20828 \
      --enable-ft2232_ftd2xx --disable-werror --with-ftd2xx-lib=static

    $> make
    $> make install


Alternative, do a Cygwin build on a Windows host,

  For instructions, please visit:

    http://www.tincantools.com/wiki/Compiling_OpenOCD_Win7


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  4. A typical debug session using arc-elf32-gdb with openocd
     See scenarios below (given commands)
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

On the HOST (Linux PC which connects directly to the target):

  Connect Digilent HS1 JTAG-USB probe or EM Starter Kit to the Host. EM Starter
  Kit has built-in debug probe, it doesn't requires a separate Digilent HS1
  probe. HS1 is required only for other debug targets like ML-509 board, etc.

  $> lsusb
    Check that FTDI 2232H device is there

  $> openocd -f <openocd.cfg> -c "init" -c "halt" -c "reset halt"
    for development activities, add to the above command line:
  		-d0 [-d 3 -l <logfile>.log]

  		valid openocd.cfg files:
  			./tcl/target/snps_starter_kit_arc-em.cfg
  			./tcl/target/snps_ml509_arc600.cfg
  			./tcl/target/snps_ml509_arc700.cfg
  			./tcl/target/snps_haps51_arc700.cfg

  The next command is not strictly necessary to do, just a way to connect.
  $> telnet localhost 4444
  Open On-Chip Debugger
  > ?

On the debug host (Linux PC with GDB, which is not necessarily the same PC as
host connected to debug target):

  Start the ELF32 GDB debugger which has to connect to OpenOCD lateron
  $> arc-elf32-gdb ./<elf app_to_debug>

  Make the connection between arc-elf32-gdb and OpenOCD
  (gdb) set remotetimeout 50
  (gdb) target extended-remote <host ip address>:3333

  Load the image which has to be debugged (./<app_to_debug>.elf)
  (gdb) load

  Set breakpoint breakpoint at function exit
  (gdb) break exit

  Start the execution on target of the image to debug
  (gdb) continue

  List the content of all core & aux registers
  (gdb) info all-registers


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  5. Advanced debug commands
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

 NOTE: With the GDB "monitor" command, you have "direct" access to the core
       without any interferance from GDB anymore! With other words, GDB
       has no notion of changes in core state when using the so called
       monitor commands (but it is very powerfull).

  Stop executing the image on the target
  (gdb) monitor halt

  Continue executing the program to debug
  (gdb) monitor resume

  Make sure the program counter is set to the load address
  (gdb) monitor arc set-pc <load address>

  Command to get a list of all possible monitor commands which go to openocd.
  NOTE; it is not that all are supported yet.
  (gdb) monitor help

  Using dedicated ARC commands, when given no arguments, the command will log
  usage parameters or type (gdb) monitor help arc <command>:

  (gdb) monitor arc set-pc
  (gdb) monitor arc set-core-into-halted

  (gdb) monitor arc read-core-reg
  (gdb) monitor arc write-core-reg

  (gdb) monitor arc read-aux-reg
  (gdb) monitor arc write-aux-reg

  (gdb) monitor arc read-mem-word
  (gdb) monitor arc write-mem-word

  (gdb) monitor arc print-core-status
  (gdb) monitor arc print-core-registers
  (gdb) monitor arc print-aux-registers

  arc Help info ...
      ARC monitor command group (command valid any time)
  arc print-aux-registers has no arguments
        list the content of all auxilary registers
  arc print-core-registers has no arguments
        list the content of all core registers
  arc print-core-status has no arguments
        list the content of core aux debug & status32 register
  arc read-aux-reg has one argument: <reg-nbr>
        list the content of a particular aux registers
  arc read-core-reg has one argument: <reg-nbr>
        list the content of a particular core registers
  arc read-mem-word has one argument: <mem-addr>
        list the content (1 word) of a particular memory location
  arc set-core-into-halted has no arguments
        set the ARC core into HALTED state
  arc set-pc has one argument: <value>
        modify the ARC core program counter (PC) register
  arc write-aux-reg has two argument: <reg-nbr> <value to write>
        write value to a particular aux registers
  arc write-core-reg has two argument: <reg-nbr> <value to write>
        write value to a particular core registers
  arc write-mem-word has two argument: <mem-addr> <value to write>
        write value (1 word) to a particular memory location


  ......................................................................

  Display register content
  (gdb) info registers
    or
  (gdb) info registers <register name>
    or
  (gdb) monitor reg <register number>

  Change register content
  (gdb) set {long} $<register name> = <value>

  read from memory
    (gdb) x /4w <physical memory address>

  write to memory
    (gdb) set {long} <physical memory address> = <value>

  (gdb) info target
  (gdb) run

  (gdb) continue
  (gdb) break main
  (gdb) continue

  (gdb) info breakpoint
  (gdb) break *0x8fd01000


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  6. How to program a bit-file into FPGA by usage of a Digilent HS2 probe
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Below is an example given of how to program a Xilinx ML509 FPGA developers
board. NOTE: make sure the Digilent HS2 dongle is connected to the right
JTAG connector on the board (programming the FPGA and not the memory).
So, it should be connected to PC4 JTAG and not to J51 BDM.
Further more, Device 4: XC5VLX110T is the FPGA to program, device 4 in the
JTAG scan chain.

>$ djtgcfg enum
Found 1 device(s)

Device: JtagHs2
    Product Name:   Digilent JTAG-HS2
    User Name:      JtagHs2
    Serial Number:  210249810909

>$ djtgcfg -d JtagHs2 init
Initializing scan chain...
Found Device ID: a2ad6093
Found Device ID: 0a001093
Found Device ID: 59608093
Found Device ID: f5059093
Found Device ID: f5059093

Found 5 device(s):
    Device 0: XCF32P
    Device 1: XCF32P
    Device 2: XC95144XL
    Device 3: XCCACE
    Device 4: XC5VLX110T

>$ djtgcfg -d JtagHs2 prog -i 4 -f <fpga bit file to progam>.bit
Programming device. Do not touch your board. This may take a few minutes...
Programming succeeded.

>$


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  7. ARC OpenOCD configuration options
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

>$ ./configure --help

`configure' configures openocd 0.7.0-dev to adapt to many kinds of systems.

Usage: ./configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  -h, --help              display this help and exit
      --help=short        display options specific to this package
      --help=recursive    display the short help of all the included packages
  -V, --version           display version information and exit
  -q, --quiet, --silent   do not print `checking...' messages
      --cache-file=FILE   cache test results in FILE [disabled]
  -C, --config-cache      alias for `--cache-file=config.cache'
  -n, --no-create         do not create output files
      --srcdir=DIR        find the sources in DIR [configure dir or `..']

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]

By default, `make install' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables [EPREFIX/bin]
  --sbindir=DIR           system admin executables [EPREFIX/sbin]
  --libexecdir=DIR        program executables [EPREFIX/libexec]
  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
  --libdir=DIR            object code libraries [EPREFIX/lib]
  --includedir=DIR        C header files [PREFIX/include]
  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
  --infodir=DIR           info documentation [DATAROOTDIR/info]
  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
  --mandir=DIR            man documentation [DATAROOTDIR/man]
  --docdir=DIR            documentation root [DATAROOTDIR/doc/openocd]
  --htmldir=DIR           html documentation [DOCDIR]
  --dvidir=DIR            dvi documentation [DOCDIR]
  --pdfdir=DIR            pdf documentation [DOCDIR]
  --psdir=DIR             ps documentation [DOCDIR]

Program names:
  --program-prefix=PREFIX            prepend PREFIX to installed program names
  --program-suffix=SUFFIX            append SUFFIX to installed program names
  --program-transform-name=PROGRAM   run sed PROGRAM on installed program names

System types:
  --build=BUILD     configure for building on BUILD [guessed]
  --host=HOST       cross-compile to build programs to run on HOST [BUILD]

Optional Features:
  --disable-option-checking  ignore unrecognized --enable/--with options
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --enable-maintainer-mode  enable make rules and dependencies not useful
			  (and sometimes confusing) to the casual installer
  --disable-dependency-tracking  speeds up one-time build
  --enable-dependency-tracking   do not reject slow dependency extractors
  --enable-shared[=PKGS]  build shared libraries [default=no]
  --enable-static[=PKGS]  build static libraries [default=yes]
  --enable-fast-install[=PKGS]
                          optimize for fast installation [default=yes]
  --disable-libtool-lock  avoid locking (might break parallel builds)
  --disable-assert        turn off assertions
  --disable-doxygen-html  Disable building Doxygen manual as HTML.
  --enable-doxygen-pdf    Enable building Doxygen manual as PDF.
  --disable-gccwarnings   Disable compiler warnings
  --disable-wextra        Disable extra compiler warnings
  --disable-werror        Do not treat warnings as errors
  --enable-verbose        Enable verbose JTAG I/O messages (for debugging).
  --enable-verbose-jtag-io
                          Enable verbose JTAG I/O messages (for debugging).
  --enable-verbose-usb-io Enable verbose USB I/O messages (for debugging)
  --enable-verbose-usb-comms
                          Enable verbose USB communication messages (for
                          debugging)
  --enable-malloc-logging Include free space in logging messages (requires
                          malloc.h).
  --enable-dummy          Enable building the dummy port driver
  --enable-parport        Enable building the pc parallel port driver
  --disable-parport-ppdev Disable use of ppdev (/dev/parportN) for parport
                          (for x86 only)
  --enable-parport-giveio Enable use of giveio for parport (for CygWin only)
  --enable-ft2232_libftdi Enable building support for FT2232 based devices
                          using the libftdi driver, opensource alternate of
                          FTD2XX
  --enable-ft2232_ftd2xx  Enable building support for FT2232 based devices
                          using the FTD2XX driver from ftdichip.com
  --enable-ftdi           Enable building support for the MPSSE mode of FTDI
                          based devices, using libusb-1.0 in asynchronous mode
  --enable-usb_blaster_libftdi
                          Enable building support for the Altera USB-Blaster
                          using the libftdi driver, opensource alternate of
                          FTD2XX
  --enable-usb_blaster_ftd2xx
                          Enable building support for the Altera USB-Blaster
                          using the FTD2XX driver from ftdichip.com
  --enable-amtjtagaccel   Enable building the Amontec JTAG-Accelerator driver
  --enable-zy1000-master  Use ZY1000 JTAG master registers
  --enable-zy1000         Enable ZY1000 interface
  --enable-ioutil         Enable ioutil functions - useful for standalone
                          OpenOCD implementations
  --enable-ep93xx         Enable building support for EP93xx based SBCs
  --enable-at91rm9200     Enable building support for AT91RM9200 based SBCs
  --enable-gw16012        Enable building support for the Gateworks GW16012
                          JTAG Programmer
  --enable-presto_libftdi Enable building support for ASIX Presto Programmer
                          using the libftdi driver
  --enable-presto_ftd2xx  Enable building support for ASIX Presto Programmer
                          using the FTD2XX driver
  --enable-usbprog        Enable building support for the usbprog JTAG
                          Programmer
  --enable-oocd_trace     Enable building support for some prototype
                          OpenOCD+trace ETM capture hardware
  --enable-jlink          Enable building support for the Segger J-Link JTAG
                          Programmer
  --enable-vsllink        Enable building support for the Versaloon-Link JTAG
                          Programmer
  --enable-rlink          Enable building support for the Raisonance RLink
                          JTAG Programmer
  --enable-ulink          Enable building support for the Keil ULINK JTAG
                          Programmer
  --enable-arm-jtag-ew    Enable building support for the Olimex ARM-JTAG-EW
                          Programmer
  --enable-buspirate      Enable building support for the Buspirate
  --enable-stlink         Enable building support for the ST-Link JTAG
                          Programmer
  --enable-ti-icdi        Enable building support for the TI ICDI JTAG
                          Programmer
  --enable-osbdm          Enable building support for the OSBDM (JTAG only)
                          Programmer
  --enable-opendous       Enable building support for the estick/opendous JTAG
                          Programmer
  --enable-sysfsgpio      Enable building support for programming driven via
                          sysfs gpios.
  --enable-minidriver-dummy
                          Enable the dummy minidriver.
  --disable-internal-jimtcl
                          Disable building internal jimtcl
  --enable-libusb0        Use libusb-0.1 library for USB JTAG devices
  --enable-remote-bitbang Enable building support for the Remote Bitbang jtag
                          driver

Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-pic              try to use only PIC/non-PIC objects [default=use
                          both]
  --with-gnu-ld           assume the C compiler uses GNU ld [default=no]
  --with-ftd2xx=<PATH>    This option has been removed.
  --with-ftd2xx-win32-zipdir
                          Where (CYGWIN/MINGW) the zip file from ftdichip.com
                          was unpacked (default=search)
  --with-ftd2xx-linux-tardir
                          Where (Linux/Unix) the tar file from ftdichip.com
                          was unpacked (default=search)
  --with-ftd2xx-lib       Use static or shared ftd2xx libs (default=static)

Some influential environment variables:
  CC          C compiler command
  CFLAGS      C compiler flags
  LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
              nonstandard directory <lib dir>
  LIBS        libraries to pass to the linker, e.g. -l<library>
  CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
              you have headers in a nonstandard directory <include dir>
  CPP         C preprocessor

Use these variables to override the choices made by `configure' or to help
it to find libraries and programs with nonstandard names/locations.

Report bugs to <OpenOCD Mailing List <openocd-devel@lists.sourceforge.net>>.

>$ 


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  8. ARC-GDB development commands
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  (gdb) set debug arc 1
  (gdb) set debug infrun 1
  (gdb) set debug arch 1
  (gdb) set debug event 1
  (gdb) set debug frame 1
  (gdb) set debug remote 1
  (gdb) set debug target 1
  
  (gdb) set sysroot /home/mjonker/BE/arc_initramfs_BE
  (gdb) file /home/mjonker/BE/arc_initramfs_BE/test

  (gdb) target extended-remote 192.168.0.2:10000
  (gdb) ...

  (gdb) set {long long}0x80000000 = 0
  (gdb) x /4w 0x80000000

  ......................................................................

  $>  arc-elf32-readelf u-boot.elf
  $>  arc-elf32-readelf -S u-boot.elf
  $>  arc-elf32-readelf u-boot.elf
  $>  arc-elf32-readelf -x --hex-dump=.text u-boot.elf | more
  $>  arc-elf32-readelf -x --hex-dump=1 u-boot.elf | more
  $>  arc-elf32-readelf -x 1 u-boot.elf | more


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  9. Find your way in the source code
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Automake makefile entry starts from: src/target/Makefile.am

In src/target is the ARC specific code base:

	Top and bottom interfaces into OpenOCD:

	arc.c				main hook into OpenOCD framework (target function body)
	arc.h				main include (gets everywhere included)
	arc_jtag.c + .h		ARC jtag interface into OpenOCD

	Supporting functions/modules as used by above interface into OpenOCD

	arc32.c + .h		generic ARC architecture functions
	arc_core.c + .h		ARC core internal specifics
	arc_dbg.c + .h		ARC debugger functions
	arc_mem.c + .h		ARC memory functions
	arc_mntr.c + .h		GDB monitor functions
	arc_ocd.c + .h		ARC OCD initialization
	arc_regs.c + .h		ARC register access
	arc_trgt.c + .h		target/board system functions


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
