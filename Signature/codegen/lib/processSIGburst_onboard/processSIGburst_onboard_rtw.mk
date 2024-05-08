###########################################################################
## Makefile generated for component 'processSIGburst_onboard'. 
## 
## Makefile     : processSIGburst_onboard_rtw.mk
## Generated on : Wed May 08 13:57:16 2024
## Final product: ./processSIGburst_onboard.lib
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

PRODUCT_NAME              = processSIGburst_onboard
MAKEFILE                  = processSIGburst_onboard_rtw.mk
MATLAB_ROOT               = C:/PROGRA~1/MATLAB/R2023a
MATLAB_BIN                = C:/PROGRA~1/MATLAB/R2023a/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/win64
START_DIR                 = C:/Users/kfitz/Github/MATLAB/Functions/SWIFT-codes/Signature
TGT_FCN_LIB               = ISO_C++
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
COMPILER_COMMAND_FILE     = processSIGburst_onboard_rtw_comp.rsp
CMD_FILE                  = processSIGburst_onboard_rtw.rsp
C_STANDARD_OPTS           = -fwrapv
CPP_STANDARD_OPTS         = -fwrapv
MODELLIB                  = processSIGburst_onboard.lib

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          MinGW64 | gmake (64-bit Windows)
# Supported Version(s):    6.x
# ToolchainInfo Version:   2023a
# Specification Revision:  1.0
# 
#-------------------------------------------
# Macros assumed to be defined elsewhere
#-------------------------------------------

# C_STANDARD_OPTS
# CPP_STANDARD_OPTS
# MINGW_ROOT
# MINGW_C_STANDARD_OPTS

#-----------
# MACROS
#-----------

WARN_FLAGS            = -Wall -W -Wwrite-strings -Winline -Wstrict-prototypes -Wnested-externs -Wpointer-arith -Wcast-align
WARN_FLAGS_MAX        = $(WARN_FLAGS) -Wcast-qual -Wshadow
CPP_WARN_FLAGS        = -Wall -W -Wwrite-strings -Winline -Wpointer-arith -Wcast-align
CPP_WARN_FLAGS_MAX    = $(CPP_WARN_FLAGS) -Wcast-qual -Wshadow
MW_EXTERNLIB_DIR      = $(MATLAB_ROOT)/extern/lib/win64/mingw64
SHELL                 = %SystemRoot%/system32/cmd.exe

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = -lws2_32

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# C Compiler: GNU C Compiler
CC_PATH = $(MINGW_ROOT)
CC = "$(CC_PATH)/gcc"

# Linker: GNU Linker
LD_PATH = $(MINGW_ROOT)
LD = "$(LD_PATH)/g++"

# C++ Compiler: GNU C++ Compiler
CPP_PATH = $(MINGW_ROOT)
CPP = "$(CPP_PATH)/g++"

# C++ Linker: GNU C++ Linker
CPP_LD_PATH = $(MINGW_ROOT)
CPP_LD = "$(CPP_LD_PATH)/g++"

# Archiver: GNU Archiver
AR_PATH = $(MINGW_ROOT)
AR = "$(AR_PATH)/ar"

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)/mex"

# Download: Download
DOWNLOAD =

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder: GMAKE Utility
MAKE_PATH = $(MINGW_ROOT)
MAKE = "$(MAKE_PATH)/mingw32-make.exe"


#-------------------------
# Directives/Utilities
#-------------------------

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
RM                  = @del
ECHO                = @echo
MV                  = @move
RUN                 =

#--------------------------------------
# "Faster Runs" Build Configuration
#--------------------------------------

ARFLAGS              = ruvs
CFLAGS               = -c $(MINGW_C_STANDARD_OPTS) -m64 \
                       -O3 -fno-loop-optimize -fno-aggressive-loop-optimizations
CPPFLAGS             = -c $(CPP_STANDARD_OPTS) -m64 \
                       -O3 -fno-loop-optimize -fno-aggressive-loop-optimizations
CPP_LDFLAGS          =  -static -m64
CPP_SHAREDLIB_LDFLAGS  = -shared -Wl,--no-undefined \
                         -Wl,--out-implib,$(notdir $(basename $(PRODUCT))).lib
DOWNLOAD_FLAGS       =
EXECUTE_FLAGS        =
LDFLAGS              =  -static -m64
MEX_CPPFLAGS         =
MEX_CPPLDFLAGS       =
MEX_CFLAGS           =
MEX_LDFLAGS          =
MAKE_FLAGS           = -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    = -shared -Wl,--no-undefined \
                       -Wl,--out-implib,$(notdir $(basename $(PRODUCT))).lib



###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = ./processSIGburst_onboard.lib
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

DEFINES_ = -D__USE_MINGW_ANSI_STDIO=1
DEFINES_CUSTOM = 
DEFINES_STANDARD = -DMODEL=processSIGburst_onboard

DEFINES = $(DEFINES_) $(DEFINES_CUSTOM) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_data.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/rt_nonfinite.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/rtGetNaN.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/rtGetInf.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_initialize.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_terminate.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/movmedian.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/abs.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/find.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/interp1.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/combineVectorElements.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/mtimes.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/eig.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/eigHermitianStandard.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xnrm2.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlaev2.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlartg.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xgeev.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xdladiv.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/sortLE.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/diff.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/mean.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/repmat.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/permute.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/std.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/mldivide.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/strcmp.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlarfg.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzungqr.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlarf.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzsteqr.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlahqr.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlanv2.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzgebal.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzunghr.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xdtrevc3.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xaxpy.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xgemv.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/sort.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/sortIdx.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlascl.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlaln2.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/div.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/SortedBuffer.cpp $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_rtwutil.cpp

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = processSIGburst_onboard_data.obj rt_nonfinite.obj rtGetNaN.obj rtGetInf.obj processSIGburst_onboard_initialize.obj processSIGburst_onboard_terminate.obj processSIGburst_onboard.obj movmedian.obj abs.obj find.obj interp1.obj combineVectorElements.obj mtimes.obj eig.obj eigHermitianStandard.obj xnrm2.obj xdlaev2.obj xzlartg.obj xgeev.obj xdladiv.obj sortLE.obj diff.obj mean.obj repmat.obj permute.obj std.obj mldivide.obj strcmp.obj xzlarfg.obj xzungqr.obj xzlarf.obj xzsteqr.obj xdlahqr.obj xdlanv2.obj xzgebal.obj xzunghr.obj xdtrevc3.obj xaxpy.obj xgemv.obj sort.obj sortIdx.obj xzlascl.obj xdlaln2.obj div.obj SortedBuffer.obj processSIGburst_onboard_rtwutil.obj

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

CFLAGS_OPTS = -fopenmp
CFLAGS_BASIC = $(DEFINES) $(INCLUDES) @$(COMPILER_COMMAND_FILE)

CFLAGS += $(CFLAGS_OPTS) $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_OPTS = -fopenmp
CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES) @$(COMPILER_COMMAND_FILE)

CPPFLAGS += $(CPPFLAGS_OPTS) $(CPPFLAGS_BASIC)

#---------------
# C++ Linker
#---------------

CPP_LDFLAGS_ = -fopenmp

CPP_LDFLAGS += $(CPP_LDFLAGS_)

#------------------------------
# C++ Shared Library Linker
#------------------------------

CPP_SHAREDLIB_LDFLAGS_ = -fopenmp

CPP_SHAREDLIB_LDFLAGS += $(CPP_SHAREDLIB_LDFLAGS_)

#-----------
# Linker
#-----------

LDFLAGS_ = -fopenmp

LDFLAGS += $(LDFLAGS_)

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

SHAREDLIB_LDFLAGS_ = -fopenmp

SHAREDLIB_LDFLAGS += $(SHAREDLIB_LDFLAGS_)

###########################################################################
## INLINED COMMANDS
###########################################################################


MINGW_C_STANDARD_OPTS = $(C_STANDARD_OPTS)


###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build clean info prebuild download execute


all : build
	@echo "### Successfully generated all binary outputs."


build : prebuild $(PRODUCT)


prebuild : 


download : $(PRODUCT)


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

%.obj : %.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.obj : %.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.obj : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.obj : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.obj : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.obj : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


processSIGburst_onboard_data.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_data.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rt_nonfinite.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/rt_nonfinite.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rtGetNaN.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/rtGetNaN.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rtGetInf.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/rtGetInf.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


processSIGburst_onboard_initialize.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_initialize.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


processSIGburst_onboard_terminate.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_terminate.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


processSIGburst_onboard.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


movmedian.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/movmedian.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


abs.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/abs.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


find.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/find.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


interp1.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/interp1.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


combineVectorElements.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/combineVectorElements.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


mtimes.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/mtimes.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


eig.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/eig.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


eigHermitianStandard.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/eigHermitianStandard.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xnrm2.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xnrm2.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xdlaev2.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlaev2.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzlartg.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlartg.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xgeev.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xgeev.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xdladiv.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xdladiv.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


sortLE.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/sortLE.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


diff.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/diff.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


mean.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/mean.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


repmat.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/repmat.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


permute.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/permute.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


std.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/std.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


mldivide.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/mldivide.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


strcmp.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/strcmp.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzlarfg.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlarfg.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzungqr.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzungqr.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzlarf.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlarf.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzsteqr.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzsteqr.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xdlahqr.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlahqr.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xdlanv2.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlanv2.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzgebal.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzgebal.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzunghr.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzunghr.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xdtrevc3.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xdtrevc3.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xaxpy.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xaxpy.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xgemv.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xgemv.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


sort.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/sort.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


sortIdx.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/sortIdx.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xzlascl.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xzlascl.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xdlaln2.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/xdlaln2.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


div.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/div.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


SortedBuffer.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/SortedBuffer.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


processSIGburst_onboard_rtwutil.obj : $(START_DIR)/codegen/lib/processSIGburst_onboard/processSIGburst_onboard_rtwutil.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


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
	@echo "### DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@echo "### EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@echo "### MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "### Deleting all derived files ..."
	$(RM) $(subst /,\,$(PRODUCT))
	$(RM) $(subst /,\,$(ALL_OBJS))
	$(ECHO) "### Deleted all derived files."


