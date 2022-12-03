###########################################################################
## Makefile generated for component 'NEDwaves'. 
## 
## Makefile     : NEDwaves_rtw.mk
## Generated on : Fri Dec 02 23:00:12 2022
## Final product: ./NEDwaves.a
## Product type : static-library
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile
# MODELLIB                Static library target

PRODUCT_NAME              = NEDwaves
MAKEFILE                  = NEDwaves_rtw.mk
MATLAB_ROOT               = /Applications/MATLAB_R2022a.app
MATLAB_BIN                = /Applications/MATLAB_R2022a.app/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/maci64
START_DIR                 = /Users/jthomson/Dropbox/Mac/Documents/GitHub/SWIFT-codes/Waves
TGT_FCN_LIB               = ISO_C++11
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
C_STANDARD_OPTS           = -fno-common -fexceptions
CPP_STANDARD_OPTS         = -std=c++14 -fno-common -fexceptions
MODELLIB                  = NEDwaves.a

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

# Toolchain Name:          Clang v3.1 | gmake (64-bit Mac)
# Supported Version(s):    3.1
# ToolchainInfo Version:   2022a
# Specification Revision:  1.0
# 
#-------------------------------------------
# Macros assumed to be defined elsewhere
#-------------------------------------------

# C_STANDARD_OPTS
# CPP_STANDARD_OPTS

#-----------
# MACROS
#-----------

ARCHS             = x86_64
XCODE_SDK_VER     = $(shell perl $(MATLAB_ROOT)/rtw/c/tools/macsdkver.pl)
XCODE_SDK         = MacOSX$(XCODE_SDK_VER).sdk
XCODE_DEVEL_DIR   = $(shell xcode-select -print-path)
XCODE_SDK_ROOT    = $(XCODE_DEVEL_DIR)/Platforms/MacOSX.platform/Developer/SDKs/$(XCODE_SDK)

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = 

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# C Compiler: Clang C Compiler
CC = xcrun clang

# Linker: Clang Linker
LD = xcrun clang++

# C++ Compiler: Clang C++ Compiler
CPP = xcrun clang++

# C++ Linker: Clang C++ Linker
CPP_LD = xcrun clang++

# Archiver: Clang Archiver
AR = xcrun ar

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_ARCH_BIN)
MEX = "$(MEX_PATH)/mex"

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
RM                  = @rm -f
ECHO                = @echo
MV                  = @mv
RUN                 =

#--------------------------------------
# "Faster Runs" Build Configuration
#--------------------------------------

ARFLAGS              = ruvs
CFLAGS               = -c -isysroot $(XCODE_SDK_ROOT) -arch $(ARCHS) $(C_STANDARD_OPTS) -mmacosx-version-min=10.15 \
                       -O3
CPPFLAGS             = -c -isysroot $(XCODE_SDK_ROOT) -arch $(ARCHS) $(CPP_STANDARD_OPTS) -mmacosx-version-min=10.15 \
                       -O3
CPP_LDFLAGS          = -arch $(ARCHS) -isysroot $(XCODE_SDK_ROOT) -Wl,-rpath,@executable_path -Wl,-rpath,@executable_path/$(RELATIVE_PATH_TO_ANCHOR)
CPP_SHAREDLIB_LDFLAGS  = -dynamiclib -install_name @rpath/$(notdir $(PRODUCT)) -isysroot $(XCODE_SDK_ROOT) \
                         -Wl,$(LD_NAMESPACE) $(LD_UNDEFS)
DOWNLOAD_FLAGS       =
EXECUTE_FLAGS        =
LDFLAGS              = -arch $(ARCHS) -isysroot $(XCODE_SDK_ROOT) -Wl,-rpath,@executable_path -Wl,-rpath,@executable_path/$(RELATIVE_PATH_TO_ANCHOR)
MEX_CPPFLAGS         =
MEX_CPPLDFLAGS       =
MEX_CFLAGS           =
MEX_LDFLAGS          =
MAKE_FLAGS           = -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    = -dynamiclib -install_name @rpath/$(notdir $(PRODUCT)) -isysroot $(XCODE_SDK_ROOT) \
                       -Wl,$(LD_NAMESPACE) $(LD_UNDEFS)



###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = ./NEDwaves.a
PRODUCT_TYPE = "static-library"
BUILD_TYPE = "Static Library"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I$(START_DIR)/codegen/lib/NEDwaves -I$(START_DIR) -I$(MATLAB_ROOT)/extern/include

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_CUSTOM = 
DEFINES_STANDARD = -DMODEL=NEDwaves

DEFINES = $(DEFINES_CUSTOM) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_data.cpp $(START_DIR)/codegen/lib/NEDwaves/rt_nonfinite.cpp $(START_DIR)/codegen/lib/NEDwaves/rtGetNaN.cpp $(START_DIR)/codegen/lib/NEDwaves/rtGetInf.cpp $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_initialize.cpp $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_terminate.cpp $(START_DIR)/codegen/lib/NEDwaves/NEDwaves.cpp $(START_DIR)/codegen/lib/NEDwaves/qrsolve.cpp $(START_DIR)/codegen/lib/NEDwaves/xnrm2.cpp $(START_DIR)/codegen/lib/NEDwaves/std.cpp $(START_DIR)/codegen/lib/NEDwaves/blockedSummation.cpp $(START_DIR)/codegen/lib/NEDwaves/detrend.cpp $(START_DIR)/codegen/lib/NEDwaves/var.cpp $(START_DIR)/codegen/lib/NEDwaves/fft.cpp $(START_DIR)/codegen/lib/NEDwaves/mean.cpp $(START_DIR)/codegen/lib/NEDwaves/sum.cpp $(START_DIR)/codegen/lib/NEDwaves/minOrMax.cpp $(START_DIR)/codegen/lib/NEDwaves/nullAssignment.cpp $(START_DIR)/codegen/lib/NEDwaves/div.cpp $(START_DIR)/codegen/lib/NEDwaves/FFTImplementationCallback.cpp

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = NEDwaves_data.o rt_nonfinite.o rtGetNaN.o rtGetInf.o NEDwaves_initialize.o NEDwaves_terminate.o NEDwaves.o qrsolve.o xnrm2.o std.o blockedSummation.o detrend.o var.o fft.o mean.o sum.o minOrMax.o nullAssignment.o div.o FFTImplementationCallback.o

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

SYSTEM_LIBS =  -L"$(MATLAB_ROOT)/sys/os/maci64" -lm -lstdc++ -liomp5

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_OPTS = -Xpreprocessor -fopenmp -I/Applications/MATLAB_R2022a.app/toolbox/eml/externalDependency/omp/maci64/include -DOpenMP_omp_LIBRARY=/Applications/MATLAB_R2022a.app/sys/os/maci64/libiomp5.dylib
CFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CFLAGS += $(CFLAGS_OPTS) $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_OPTS = -Xpreprocessor -fopenmp -I/Applications/MATLAB_R2022a.app/toolbox/eml/externalDependency/omp/maci64/include -DOpenMP_omp_LIBRARY=/Applications/MATLAB_R2022a.app/sys/os/maci64/libiomp5.dylib
CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CPPFLAGS += $(CPPFLAGS_OPTS) $(CPPFLAGS_BASIC)

#---------------
# C++ Linker
#---------------

CPP_LDFLAGS_ = -Wl,-rpath,$(MATLAB_ROOT)/sys/os/$(ARCH)/  

CPP_LDFLAGS += $(CPP_LDFLAGS_)

#------------------------------
# C++ Shared Library Linker
#------------------------------

CPP_SHAREDLIB_LDFLAGS_ = -Wl,-rpath,$(MATLAB_ROOT)/sys/os/$(ARCH)/  

CPP_SHAREDLIB_LDFLAGS += $(CPP_SHAREDLIB_LDFLAGS_)

#-----------
# Linker
#-----------

LDFLAGS_ = -Wl,-rpath,$(MATLAB_ROOT)/sys/os/$(ARCH)/  

LDFLAGS += $(LDFLAGS_)

#--------------------------
# Shared Library Linker
#--------------------------

SHAREDLIB_LDFLAGS_ = -Wl,-rpath,$(MATLAB_ROOT)/sys/os/$(ARCH)/  

SHAREDLIB_LDFLAGS += $(SHAREDLIB_LDFLAGS_)

###########################################################################
## INLINED COMMANDS
###########################################################################

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
	$(AR) $(ARFLAGS)  $(PRODUCT) $(OBJS)
	@echo "### Created: $(PRODUCT)"


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%.o : %.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : %.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


NEDwaves_data.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_data.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rt_nonfinite.o : $(START_DIR)/codegen/lib/NEDwaves/rt_nonfinite.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rtGetNaN.o : $(START_DIR)/codegen/lib/NEDwaves/rtGetNaN.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


rtGetInf.o : $(START_DIR)/codegen/lib/NEDwaves/rtGetInf.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


NEDwaves_initialize.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_initialize.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


NEDwaves_terminate.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves_terminate.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


NEDwaves.o : $(START_DIR)/codegen/lib/NEDwaves/NEDwaves.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


qrsolve.o : $(START_DIR)/codegen/lib/NEDwaves/qrsolve.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


xnrm2.o : $(START_DIR)/codegen/lib/NEDwaves/xnrm2.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


std.o : $(START_DIR)/codegen/lib/NEDwaves/std.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


blockedSummation.o : $(START_DIR)/codegen/lib/NEDwaves/blockedSummation.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


detrend.o : $(START_DIR)/codegen/lib/NEDwaves/detrend.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


var.o : $(START_DIR)/codegen/lib/NEDwaves/var.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


fft.o : $(START_DIR)/codegen/lib/NEDwaves/fft.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


mean.o : $(START_DIR)/codegen/lib/NEDwaves/mean.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


sum.o : $(START_DIR)/codegen/lib/NEDwaves/sum.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


minOrMax.o : $(START_DIR)/codegen/lib/NEDwaves/minOrMax.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


nullAssignment.o : $(START_DIR)/codegen/lib/NEDwaves/nullAssignment.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


div.o : $(START_DIR)/codegen/lib/NEDwaves/div.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


FFTImplementationCallback.o : $(START_DIR)/codegen/lib/NEDwaves/FFTImplementationCallback.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(ALL_OBJS) : rtw_proj.tmw $(MAKEFILE)


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
	$(ECHO) "### Deleting all derived files..."
	$(RM) $(PRODUCT)
	$(RM) $(ALL_OBJS)
	$(ECHO) "### Deleted all derived files."


