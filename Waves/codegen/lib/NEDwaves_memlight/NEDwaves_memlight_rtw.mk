###########################################################################
## Makefile generated for component 'NEDwaves_memlight'. 
## 
## Makefile     : NEDwaves_memlight_rtw.mk
## Generated on : Fri Jun 30 08:54:27 2023
## Final product: ./NEDwaves_memlight.a
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

PRODUCT_NAME              = NEDwaves_memlight
MAKEFILE                  = NEDwaves_memlight_rtw.mk
MATLAB_ROOT               = /Applications/MATLAB_R2022a.app
MATLAB_BIN                = /Applications/MATLAB_R2022a.app/bin
MATLAB_ARCH_BIN           = $(MATLAB_BIN)/maci64
START_DIR                 = /Users/jthomson/Dropbox/Mac/Documents/GitHub/SWIFT-codes/Waves
TGT_FCN_LIB               = ISO_C
SOLVER_OBJ                = 
CLASSIC_INTERFACE         = 0
MODEL_HAS_DYNAMICALLY_LOADED_SFCNS = 
RELATIVE_PATH_TO_ANCHOR   = ../../..
C_STANDARD_OPTS           = -fno-common -fexceptions
CPP_STANDARD_OPTS         = -std=c++14 -fno-common -fexceptions
MODELLIB                  = NEDwaves_memlight.a

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

PRODUCT = ./NEDwaves_memlight.a
PRODUCT_TYPE = "static-library"
BUILD_TYPE = "Static Library"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I$(START_DIR)/codegen/lib/NEDwaves_memlight -I$(START_DIR) -I$(MATLAB_ROOT)/extern/include

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_ = -D__MW_TARGET_USE_HARDWARE_RESOURCES_H__
DEFINES_CUSTOM = 
DEFINES_SKIPFORSIL = -DSTACK_SIZE=20000
DEFINES_STANDARD = -DMODEL=NEDwaves_memlight

DEFINES = $(DEFINES_) $(DEFINES_CUSTOM) $(DEFINES_SKIPFORSIL) $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_data.c $(START_DIR)/codegen/lib/NEDwaves_memlight/rt_nonfinite.c $(START_DIR)/codegen/lib/NEDwaves_memlight/rtGetNaN.c $(START_DIR)/codegen/lib/NEDwaves_memlight/rtGetInf.c $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_initialize.c $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_terminate.c $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight.c $(START_DIR)/codegen/lib/NEDwaves_memlight/linspace.c $(START_DIR)/codegen/lib/NEDwaves_memlight/combineVectorElements.c $(START_DIR)/codegen/lib/NEDwaves_memlight/var.c $(START_DIR)/codegen/lib/NEDwaves_memlight/fft.c $(START_DIR)/codegen/lib/NEDwaves_memlight/FFTImplementationCallback.c $(START_DIR)/codegen/lib/NEDwaves_memlight/interp1.c $(START_DIR)/codegen/lib/NEDwaves_memlight/minOrMax.c $(START_DIR)/codegen/lib/NEDwaves_memlight/nullAssignment.c $(START_DIR)/codegen/lib/NEDwaves_memlight/div.c $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_emxutil.c $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_emxAPI.c $(START_DIR)/codegen/lib/NEDwaves_memlight/rtwhalf.c

ALL_SRCS = $(SRCS)

###########################################################################
## OBJECTS
###########################################################################

OBJS = NEDwaves_memlight_data.o rt_nonfinite.o rtGetNaN.o rtGetInf.o NEDwaves_memlight_initialize.o NEDwaves_memlight_terminate.o NEDwaves_memlight.o linspace.o combineVectorElements.o var.o fft.o FFTImplementationCallback.o interp1.o minOrMax.o nullAssignment.o div.o NEDwaves_memlight_emxutil.o NEDwaves_memlight_emxAPI.o rtwhalf.o

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

SYSTEM_LIBS =  -L"$(MATLAB_ROOT)/sys/os/maci64" -lm -liomp5

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


%.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.c
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cpp
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


NEDwaves_memlight_data.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_data.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rt_nonfinite.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/rt_nonfinite.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtGetNaN.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/rtGetNaN.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtGetInf.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/rtGetInf.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_memlight_initialize.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_initialize.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_memlight_terminate.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_terminate.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_memlight.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight.c
	$(CC) $(CFLAGS) -o "$@" "$<"


linspace.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/linspace.c
	$(CC) $(CFLAGS) -o "$@" "$<"


combineVectorElements.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/combineVectorElements.c
	$(CC) $(CFLAGS) -o "$@" "$<"


var.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/var.c
	$(CC) $(CFLAGS) -o "$@" "$<"


fft.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/fft.c
	$(CC) $(CFLAGS) -o "$@" "$<"


FFTImplementationCallback.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/FFTImplementationCallback.c
	$(CC) $(CFLAGS) -o "$@" "$<"


interp1.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/interp1.c
	$(CC) $(CFLAGS) -o "$@" "$<"


minOrMax.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/minOrMax.c
	$(CC) $(CFLAGS) -o "$@" "$<"


nullAssignment.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/nullAssignment.c
	$(CC) $(CFLAGS) -o "$@" "$<"


div.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/div.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_memlight_emxutil.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_emxutil.c
	$(CC) $(CFLAGS) -o "$@" "$<"


NEDwaves_memlight_emxAPI.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/NEDwaves_memlight_emxAPI.c
	$(CC) $(CFLAGS) -o "$@" "$<"


rtwhalf.o : $(START_DIR)/codegen/lib/NEDwaves_memlight/rtwhalf.c
	$(CC) $(CFLAGS) -o "$@" "$<"


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


