###########################################################################
## Makefile generated for component 'NEDwaves'. 
## 
## Makefile     : NEDwaves_rtw.mk
## Generated on : Wed Dec 07 08:45:54 2022
## Final product: ./NEDwaves.lib
## Product type : static-library
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile
# COMPILER_COMMAND_FILE   Compiler command listing model reference header paths
# CMD_FILE                Command file
# MODELLIB                Static library target

PRODUCT_NAME              = NEDwaves
MAKEFILE                  = NEDwaves_rtw.mk
MATLAB_ROOT               = /Applications/MATLAB_R2022a.app
MATLAB_BIN                = /Applications/MATLAB_R2022a.app/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/maci64
START_DIR                 = /Users/jthomson/Dropbox/Mac/Documents/GitHub/SWIFT-codes/Waves
TGT_FCN_LIB               = ISO_C
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
COMPILER_COMMAND_FILE     = NEDwaves_rtw_comp.rsp
CMD_FILE                  = NEDwaves_rtw.rsp
C_STANDARD_OPTS           = 
CPP_STANDARD_OPTS         = 
MODELLIB                  = NEDwaves.lib

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          GNU Tools for ARM Embedded Processors
# Supported Version(s):    
# ToolchainInfo Version:   2022a
# Specification Revision:  1.0
# 
#-------------------------------------------
# Macros assumed to be defined elsewhere
#-------------------------------------------

# TARGET_LOAD_CMD_ARGS
# TARGET_LOAD_CMD
# MW_GNU_ARM_TOOLS_PATH
# FDATASECTIONS_FLG

#-----------
# MACROS
#-----------

LIBGCC                    = ${shell $(MW_GNU_ARM_TOOLS_PATH)/arm-none-eabi-gcc ${CFLAGS} -print-libgcc-file-name}
LIBC                      = ${shell $(MW_GNU_ARM_TOOLS_PATH)/arm-none-eabi-gcc ${CFLAGS} -print-file-name=libc.a}
LIBM                      = ${shell $(MW_GNU_ARM_TOOLS_PATH)/arm-none-eabi-gcc ${CFLAGS} -print-file-name=libm.a}
PRODUCT_NAME_WITHOUT_EXTN = $(basename $(PRODUCT))
PRODUCT_BIN               = $(PRODUCT_NAME_WITHOUT_EXTN).bin
PRODUCT_HEX               = $(PRODUCT_NAME_WITHOUT_EXTN).hex
CPFLAGS                   = -O binary

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = -lm

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# Assembler: GNU ARM Assembler
AS_PATH = $(MW_GNU_ARM_TOOLS_PATH)
AS = "$(AS_PATH)/arm-none-eabi-gcc"

# C Compiler: GNU ARM C Compiler
CC_PATH = $(MW_GNU_ARM_TOOLS_PATH)
CC = "$(CC_PATH)/arm-none-eabi-gcc"

# Linker: GNU ARM Linker
LD_PATH = $(MW_GNU_ARM_TOOLS_PATH)
LD = "$(LD_PATH)/arm-none-eabi-g++"

# C++ Compiler: GNU ARM C++ Compiler
CPP_PATH = $(MW_GNU_ARM_TOOLS_PATH)
CPP = "$(CPP_PATH)/arm-none-eabi-g++"

# C++ Linker: GNU ARM C++ Linker
CPP_LD_PATH = $(MW_GNU_ARM_TOOLS_PATH)
CPP_LD = "$(CPP_LD_PATH)/arm-none-eabi-g++"

# Archiver: GNU ARM Archiver
AR_PATH = $(MW_GNU_ARM_TOOLS_PATH)
AR = "$(AR_PATH)/arm-none-eabi-ar"

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)/mex"

# Binary Converter: Binary Converter
OBJCOPYPATH = $(MW_GNU_ARM_TOOLS_PATH)
OBJCOPY = "$(OBJCOPYPATH)/arm-none-eabi-objcopy"

# Hex Converter: Hex Converter
OBJCOPYPATH = $(MW_GNU_ARM_TOOLS_PATH)
OBJCOPY = "$(OBJCOPYPATH)/arm-none-eabi-objcopy"

# Executable Size: Executable Size
EXESIZEPATH = $(MW_GNU_ARM_TOOLS_PATH)
EXESIZE = "$(EXESIZEPATH)/arm-none-eabi-size"

# Download: Download
DOWNLOAD =

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: GMAKE Utility
MAKE_PATH = %MATLAB%/bin/maci64
MAKE = "$(MAKE_PATH)/gmake"


#-------------------------
# Directives/Utilities
#-------------------------

ASDEBUG             = -g
AS_OUTPUT_FLAG      = -o
CDEBUG              = -g
C_OUTPUT_FLAG       = -o
LDDEBUG             = -g
OUTPUT_FLAG         = -o
CPPDEBUG            = -g
CPP_OUTPUT_FLAG     = -o
CPPLDDEBUG          = -g
OUTPUT_FLAG         = -o
ARDEBUG             =
STATICLIB_OUTPUT_FLAG =
MEX_DEBUG           = -g
RM                  = @del /f/q
ECHO                = @echo
MV                  = @mv
RUN                 =

#--------------------------------------
# "Faster Runs" Build Configuration
#--------------------------------------

ARFLAGS              = ruvs
ASFLAGS              = -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  \
                       -Wall \
                       -x assembler-with-cpp \
                       $(ASFLAGS_ADDITIONAL) \
                       $(DEFINES) \
                       $(INCLUDES) \
                       -c
OBJCOPYFLAGS_BIN     = -O binary $(PRODUCT) $(PRODUCT_BIN)
CFLAGS               = $(FDATASECTIONS_FLG) \
                       -Wall \
                       -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  \
                       -c \
                       -O3
CPPFLAGS             = -std=gnu++14 \
                       -fno-rtti \
                       -fno-exceptions \
                       $(FDATASECTIONS_FLG) \
                       -Wall \
                       -MMD -MP -MF"$(@:%.o=%.dep)" -MT"$@"  \
                       -c \
                       -O3
CPP_LDFLAGS          = -Wl,--gc-sections \
                       -Wl,-Map="$(PRODUCT_NAME).map"
CPP_SHAREDLIB_LDFLAGS  =
DOWNLOAD_FLAGS       =
EXESIZE_FLAGS        = $(PRODUCT)
EXECUTE_FLAGS        =
OBJCOPYFLAGS_HEX     = -O ihex $(PRODUCT) $(PRODUCT_HEX)
LDFLAGS              = -Wl,--gc-sections \
                       -Wl,-Map="$(PRODUCT_NAME).map"
MEX_CPPFLAGS         =
MEX_CPPLDFLAGS       =
MEX_CFLAGS           =
MEX_LDFLAGS          =
MAKE_FLAGS           = -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    =



###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = ./NEDwaves.lib
PRODUCT_TYPE = "static-library"
BUILD_TYPE = "Static Library"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = 

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_ = -D__MW_TARGET_USE_HARDWARE_RESOURCES_H__
DEFINES_CUSTOM = 
DEFINES_SKIPFORSIL = -DNULL=0 -D__NO_SYSTEM_INIT -DARM_MATH_CM3=1 -DEXIT_FAILURE=1 -DEXTMODE_DISABLEPRINTF -DEXTMODE_DISABLETESTING -DEXTMODE_DISABLE_ARGS_PROCESSING=1 -DSTACK_SIZE=20000
DEFINES_STANDARD = -DMODEL=NEDwaves

DEFINES = $(DEFINES_) $(DEFINES_CUSTOM) $(DEFINES_SKIPFORSIL) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_data.c $(START_DIR)/codegen/lib/NEDwaves/rt_nonfinite.c $(START_DIR)/codegen/lib/NEDwaves/rtGetNaN.c $(START_DIR)/codegen/lib/NEDwaves/rtGetInf.c $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_initialize.c $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_terminate.c $(START_DIR)/codegen/lib/NEDwaves/NEDwaves.c $(START_DIR)/codegen/lib/NEDwaves/qrsolve.c $(START_DIR)/codegen/lib/NEDwaves/xnrm2.c $(START_DIR)/codegen/lib/NEDwaves/std.c $(START_DIR)/codegen/lib/NEDwaves/blockedSummation.c $(START_DIR)/codegen/lib/NEDwaves/detrend.c $(START_DIR)/codegen/lib/NEDwaves/var.c $(START_DIR)/codegen/lib/NEDwaves/fft.c $(START_DIR)/codegen/lib/NEDwaves/FFTImplementationCallback.c $(START_DIR)/codegen/lib/NEDwaves/mean.c $(START_DIR)/codegen/lib/NEDwaves/sum.c $(START_DIR)/codegen/lib/NEDwaves/minOrMax.c $(START_DIR)/codegen/lib/NEDwaves/nullAssignment.c $(START_DIR)/codegen/lib/NEDwaves/div.c $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_emxutil.c $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_emxAPI.c $(START_DIR)/codegen/lib/NEDwaves/rtwhalf.c

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = NEDwaves_data.o rt_nonfinite.o rtGetNaN.o rtGetInf.o NEDwaves_initialize.o NEDwaves_terminate.o NEDwaves.o qrsolve.o xnrm2.o std.o blockedSummation.o detrend.o var.o fft.o FFTImplementationCallback.o mean.o sum.o minOrMax.o nullAssignment.o div.o NEDwaves_emxutil.o NEDwaves_emxAPI.o rtwhalf.o

ALL_OBJS = $(OBJS)

###########################################################################
## PREBUILT OBJECT FILES
###########################################################################

PREBUILT_OBJS = 

###########################################################################
## LIBRARIES
###########################################################################

LIBS = 

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = 

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_SKIPFORSIL = -mcpu=cortex-m3 -mthumb -mlittle-endian -mthumb-interwork
CFLAGS_BASIC = $(DEFINES) $(INCLUDES) @$(COMPILER_COMMAND_FILE)

CFLAGS += $(CFLAGS_SKIPFORSIL) $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_SKIPFORSIL = -mcpu=cortex-m3 -mthumb -mlittle-endian -mthumb-interwork
CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES) @$(COMPILER_COMMAND_FILE)

CPPFLAGS += $(CPPFLAGS_SKIPFORSIL) $(CPPFLAGS_BASIC)

#---------------
# C++ Linker
#---------------

CPP_LDFLAGS_SKIPFORSIL = -mcpu=cortex-m3 -mthumb -mlittle-endian -mthumb-interwork -nostartfiles --specs=nano.specs --specs=nosys.specs -T "/Users/jthomson/Dropbox/Mac/Documents/MATLAB/SupportPackages/R2022a/toolbox/target/supportpackages/arm_cortex_m/src/arm_cortex_m3_qemu_gcc.ld"

CPP_LDFLAGS += $(CPP_LDFLAGS_SKIPFORSIL)

#------------------------------
# C++ Shared Library Linker
#------------------------------

CPP_SHAREDLIB_LDFLAGS_SKIPFORSIL = -mcpu=cortex-m3 -mthumb -mlittle-endian -mthumb-interwork -nostartfiles --specs=nano.specs --specs=nosys.specs -T "/Users/jthomson/Dropbox/Mac/Documents/MATLAB/SupportPackages/R2022a/toolbox/target/supportpackages/arm_cortex_m/src/arm_cortex_m3_qemu_gcc.ld"

CPP_SHAREDLIB_LDFLAGS += $(CPP_SHAREDLIB_LDFLAGS_SKIPFORSIL)

#-----------
# Linker
#-----------

LDFLAGS_SKIPFORSIL = -mcpu=cortex-m3 -mthumb -mlittle-endian -mthumb-interwork -nostartfiles --specs=nano.specs --specs=nosys.specs -T "/Users/jthomson/Dropbox/Mac/Documents/MATLAB/SupportPackages/R2022a/toolbox/target/supportpackages/arm_cortex_m/src/arm_cortex_m3_qemu_gcc.ld"

LDFLAGS += $(LDFLAGS_SKIPFORSIL)

#---------------------
# MEX C++ Compiler
#---------------------

MEX_CPP_Compiler_BASIC =  @$(COMPILER_COMMAND_FILE)

MEX_CPPFLAGS += $(MEX_CPP_Compiler_BASIC)

#-----------------
# MEX Compiler
#-----------------

MEX_Compiler_BASIC =  @$(COMPILER_COMMAND_FILE)

MEX_CFLAGS += $(MEX_Compiler_BASIC)

#--------------------------
# Shared Library Linker
#--------------------------

SHAREDLIB_LDFLAGS_SKIPFORSIL = -mcpu=cortex-m3 -mthumb -mlittle-endian -mthumb-interwork -nostartfiles --specs=nano.specs --specs=nosys.specs -T "/Users/jthomson/Dropbox/Mac/Documents/MATLAB/SupportPackages/R2022a/toolbox/target/supportpackages/arm_cortex_m/src/arm_cortex_m3_qemu_gcc.ld"

SHAREDLIB_LDFLAGS += $(SHAREDLIB_LDFLAGS_SKIPFORSIL)

###########################################################################
## INLINED COMMANDS
###########################################################################


ALL_DEPS:=$(patsubst %.o,%.dep,$(ALL_OBJS))
all:

ifndef DISABLE_GCC_FUNCTION_DATA_SECTIONS
FDATASECTIONS_FLG := -ffunction-sections -fdata-sections
endif



-include codertarget_assembly_flags.mk
-include ../codertarget_assembly_flags.mk
-include ../../codertarget_assembly_flags.mk
-include $(ALL_DEPS)


###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build clean info prebuild postbuild download execute


all : build postbuild
	@echo "### Successfully generated all binary outputs."


build : prebuild $(PRODUCT)


prebuild : 


postbuild : $(PRODUCT)


download : postbuild


execute : download


###########################################################################
## FINAL TARGET
###########################################################################

#---------------------------------
# Create a static library         
#---------------------------------

$(PRODUCT) : $(OBJS) $(PREBUILT_OBJS)
	@echo "### Creating static library "$(PRODUCT)" ..."
	$(AR) $(ARFLAGS)  $(PRODUCT) @$(CMD_FILE)
	@echo "### Created: $(PRODUCT)"


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%.o : %.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : %.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : %.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : %.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : %.cc
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : %.C
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : %.cxx
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cc
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.C
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cxx
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.cc
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.C
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.cxx
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.s
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.S
	$(AS) $(ASFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cc
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.C
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cxx
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


NEDwaves_data.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_data.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rt_nonfinite.o : $(START_DIR)/codegen/lib/NEDwaves/rt_nonfinite.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtGetNaN.o : $(START_DIR)/codegen/lib/NEDwaves/rtGetNaN.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtGetInf.o : $(START_DIR)/codegen/lib/NEDwaves/rtGetInf.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_initialize.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_initialize.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_terminate.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_terminate.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves.c
	$(CC) $(CFLAGS) -o "$@" "$<"


qrsolve.o : $(START_DIR)/codegen/lib/NEDwaves/qrsolve.c
	$(CC) $(CFLAGS) -o "$@" "$<"


xnrm2.o : $(START_DIR)/codegen/lib/NEDwaves/xnrm2.c
	$(CC) $(CFLAGS) -o "$@" "$<"


std.o : $(START_DIR)/codegen/lib/NEDwaves/std.c
	$(CC) $(CFLAGS) -o "$@" "$<"


blockedSummation.o : $(START_DIR)/codegen/lib/NEDwaves/blockedSummation.c
	$(CC) $(CFLAGS) -o "$@" "$<"


detrend.o : $(START_DIR)/codegen/lib/NEDwaves/detrend.c
	$(CC) $(CFLAGS) -o "$@" "$<"


var.o : $(START_DIR)/codegen/lib/NEDwaves/var.c
	$(CC) $(CFLAGS) -o "$@" "$<"


fft.o : $(START_DIR)/codegen/lib/NEDwaves/fft.c
	$(CC) $(CFLAGS) -o "$@" "$<"


FFTImplementationCallback.o : $(START_DIR)/codegen/lib/NEDwaves/FFTImplementationCallback.c
	$(CC) $(CFLAGS) -o "$@" "$<"


mean.o : $(START_DIR)/codegen/lib/NEDwaves/mean.c
	$(CC) $(CFLAGS) -o "$@" "$<"


sum.o : $(START_DIR)/codegen/lib/NEDwaves/sum.c
	$(CC) $(CFLAGS) -o "$@" "$<"


minOrMax.o : $(START_DIR)/codegen/lib/NEDwaves/minOrMax.c
	$(CC) $(CFLAGS) -o "$@" "$<"


nullAssignment.o : $(START_DIR)/codegen/lib/NEDwaves/nullAssignment.c
	$(CC) $(CFLAGS) -o "$@" "$<"


div.o : $(START_DIR)/codegen/lib/NEDwaves/div.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_emxutil.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_emxutil.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_emxAPI.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_emxAPI.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtwhalf.o : $(START_DIR)/codegen/lib/NEDwaves/rtwhalf.c
	$(CC) $(CFLAGS) -o "$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : rtw_proj.tmw $(COMPILER_COMMAND_FILE) $(MAKEFILE)


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	@echo "### PRODUCT = $(PRODUCT)"
	@echo "### PRODUCT_TYPE = $(PRODUCT_TYPE)"
	@echo "### BUILD_TYPE = $(BUILD_TYPE)"
	@echo "### INCLUDES = $(INCLUDES)"
	@echo "### DEFINES = $(DEFINES)"
	@echo "### ALL_SRCS = $(ALL_SRCS)"
	@echo "### ALL_OBJS = $(ALL_OBJS)"
	@echo "### LIBS = $(LIBS)"
	@echo "### MODELREF_LIBS = $(MODELREF_LIBS)"
	@echo "### SYSTEM_LIBS = $(SYSTEM_LIBS)"
	@echo "### TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS)"
	@echo "### ASFLAGS = $(ASFLAGS)"
	@echo "### CFLAGS = $(CFLAGS)"
	@echo "### LDFLAGS = $(LDFLAGS)"
	@echo "### SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS)"
	@echo "### CPPFLAGS = $(CPPFLAGS)"
	@echo "### CPP_LDFLAGS = $(CPP_LDFLAGS)"
	@echo "### CPP_SHAREDLIB_LDFLAGS = $(CPP_SHAREDLIB_LDFLAGS)"
	@echo "### ARFLAGS = $(ARFLAGS)"
	@echo "### MEX_CFLAGS = $(MEX_CFLAGS)"
	@echo "### MEX_CPPFLAGS = $(MEX_CPPFLAGS)"
	@echo "### MEX_LDFLAGS = $(MEX_LDFLAGS)"
	@echo "### MEX_CPPLDFLAGS = $(MEX_CPPLDFLAGS)"
	@echo "### OBJCOPYFLAGS_BIN = $(OBJCOPYFLAGS_BIN)"
	@echo "### OBJCOPYFLAGS_HEX = $(OBJCOPYFLAGS_HEX)"
	@echo "### EXESIZE_FLAGS = $(EXESIZE_FLAGS)"
	@echo "### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@echo "### EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@echo "### MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "### Deleting all derived files..."
	$(RM) $(PRODUCT)
	$(RM) $(ALL_OBJS)
	$(RM) *.dep
	$(ECHO) "### Deleted all derived files."


