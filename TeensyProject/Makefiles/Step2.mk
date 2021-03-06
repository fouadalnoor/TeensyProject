#
# embedXcode
# ----------------------------------
# Embedded Computing on Xcode
#
# Copyright © Rei VILO, 2010-2016
# http://embedxcode.weebly.com
# All rights reserved
#
#
# Last update: Apr 22, 2016 release 4.5.0






# Serial port check and selection
# ----------------------------------
#
ifneq ($(PLATFORM),mbed)
    include $(MAKEFILE_PATH)/Avrdude.mk
endif

$(shell echo > $(UTILITIES_PATH)/serial.txt)

# Some utilities manage paths with spaces
#
CURRENT_DIR_SPACE    := $(shell pwd)
UTILITIES_PATH_SPACE := $(CURRENT_DIR_SPACE)/Utilities

#ifeq ($(AVRDUDE_PROGRAMMER),usbtiny)

ifeq ($(AVRDUDE_NO_SERIAL_PORT),1)
#    no serial port

else ifeq ($(UPLOADER),teensy_flash)
#    teensy uploader in charge

else ifeq ($(UPLOADER),lightblue_loader)
#    lightblue uploader in charge

else
#    general case
    ifneq ($(MAKECMDGOALS),boards)
        ifneq ($(MAKECMDGOALS),build)
        ifneq ($(MAKECMDGOALS),make)
        ifneq ($(MAKECMDGOALS),document)
        ifneq ($(MAKECMDGOALS),clean)
        ifneq ($(MAKECMDGOALS),distribute)
        ifneq ($(MAKECMDGOALS),info)
        ifneq ($(MAKECMDGOALS),depends)
        ifneq ($(MAKECMDGOALS),style)
            ifeq ($(UPLOADER),DSLite)
                $(shell ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt)

            else ifeq ($(UPLOADER),cp)
                USED_VOLUME_PORT = $(shell ls -d $(BOARD_VOLUME))
                ifeq ($(USED_VOLUME_PORT),)
                    $(error Volume not available)
                endif
                $(shell ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt)

            else ifeq ($(UPLOADER),stlink)
                $(shell ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt)

            else ifeq ($(UPLOADER),spark_usb)
#                        $(shell ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt)
# ~
            else ifeq ($(UPLOADER),spark_wifi)
#                        $(shell ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt)
# ~~
            else ifeq ($(BOARD_PORT),ssh)
                $(shell echo 'ssh' > $(UTILITIES_PATH)/serial.txt)
                BACK_ADDRESS = $(shell ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\ -f 2-)

            else ifeq ($(BOARD_PORT),pgm)

            else ifeq ($(UPLOADER),espota)
                $(shell if [ -f $(BOARD_PORT) ] ; then ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt ; fi)

            else ifeq ($(AVRDUDE_PORT),)
                $(error Serial port not available)

            else
                $(shell ls -1 $(BOARD_PORT) > $(UTILITIES_PATH)/serial.txt)

            endif
        endif
        endif
        endif
        endif
        endif
        endif
        endif
        endif
    else
        ifneq ($(wildcard $(MAKEFILE_PATH)/Cosa.mk),)
            include $(MAKEFILE_PATH)/Cosa.mk
        endif
    endif
endif

ifndef UPLOADER
    UPLOADER = avrdude
endif

ifndef BOARD_NAME
    BOARD_NAME = $(call PARSE_BOARD,$(BOARD_TAG),name)
endif


# Functions
# ----------------------------------
#

# Function TRACE action target source to ~/Library/Logs/embedXcode.log
# result = $(shell echo 'action',$(BOARD_TAG),'target','source' >> ~/Library/Logs/embedXcode.log)
#
#TRACE = $(shell echo $(1)': '$(suffix $(2))' < '$(suffix $(3))'	'$(BOARD_TAG)'	'$(dir $(2))'	'$(notdir $(3)) >> ~/Library/Logs/embedXcode.log)

# Function SHOW action target source
# result = $(shell echo 'action',$(BOARD_TAG),'target','source')
#
#SHOW  = @echo $(1)'\t'$(suffix $(3))$(suffix $(2))' < '$(suffix $(3))'\t'$(BOARD_TAG)'	'$(dir $(2))'	'$(notdir $(3))
#SHOW  = @echo $(1)'\t'$(2)
SHOW  = @printf '%-24s\t%s\r\n' $(1) $(2)

# ~
#QUIET = @
# ~~

# Find version of the platform
#
ifeq ($(PLATFORM_VERSION),)
ifneq ($(MAKECMDGOALS),boards)
ifneq ($(MAKECMDGOALS),clean)
    ifeq ($(PLATFORM),MapleIDE)
        PLATFORM_VERSION := $(shell cat $(APPLICATION_PATH)/lib/build-version.txt)
    else ifeq ($(PLATFORM),mbed)
        PLATFORM_VERSION := $(shell cat $(APPLICATION_PATH)/version.txt)
# ~
    else ifeq ($(PLATFORM),IntelYocto)
        PLATFORM_VERSION := $(shell cat $(APPLICATION_PATH)/version.txt)
    else ifeq ($(PLATFORM),IntelEdisonMCU)
        PLATFORM_VERSION := $(shell cat $(EDISONMCU_PATH)/version.txt)
    else ifeq ($(PLATFORM),BeagleBoneDebian)
        PLATFORM_VERSION := $(shell cat $(APPLICATION_PATH)/version.txt)
# ~~
    else ifeq ($(PLATFORM),Spark)
        PLATFORM_VERSION := $(shell cat $(SPARK_PATH)/version.txt)
    else
        PLATFORM_VERSION := $(shell cat $(APPLICATION_PATH)/lib/version.txt)
    endif
endif
endif
endif


# CORE libraries
# ----------------------------------
#
ifndef CORE_LIB_PATH
    CORE_LIB_PATH = $(APPLICATION_PATH)/hardware/arduino/cores/arduino
endif

ifndef CORE_LIBS_LIST
    s205            = $(subst .h,,$(subst $(CORE_LIB_PATH)/,,$(wildcard $(CORE_LIB_PATH)/*.h $(CORE_LIB_PATH)/*/*.h))) # */
#    CORE_LIBS_LIST  = $(subst $(CORE_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s205)))
    CORE_LIBS_LIST  = $(subst $(CORE_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s205)))
endif


# List of sources
# ----------------------------------
#
# CORE sources
#
ifeq ($(CORE_LIBS_LOCK),)
ifdef CORE_LIB_PATH
    CORE_C_SRCS     = $(wildcard $(CORE_LIB_PATH)/*.c $(CORE_LIB_PATH)/*/*.c) # */
    
    s210              = $(filter-out %main.cpp, $(wildcard $(CORE_LIB_PATH)/*.cpp $(CORE_LIB_PATH)/*/*.cpp $(CORE_LIB_PATH)/*/*/*.cpp $(CORE_LIB_PATH)/*/*/*/*.cpp)) # */
    CORE_CPP_SRCS     = $(filter-out %/$(EXCLUDE_LIST),$(s210))
    CORE_AS1_SRCS_OBJ = $(patsubst %.S,%.S.o,$(filter %S, $(CORE_AS_SRCS)))
    CORE_AS2_SRCS_OBJ = $(patsubst %.s,%.s.o,$(filter %s, $(CORE_AS_SRCS)))

    CORE_OBJ_FILES  += $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS1_SRCS_OBJ) $(CORE_AS2_SRCS_OBJ)
#    CORE_OBJS       += $(patsubst $(CORE_LIB_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
    CORE_OBJS       += $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
#    CORE_OBJS       += $(patsubst $(HARDWARE_PATH)/%,$(OBJDIR)/%,$(CORE_OBJ_FILES))
endif
endif

# APPlication Arduino/chipKIT/Digistump/Energia/Maple/Microduino/Teensy/Wiring sources
#
ifndef APP_LIB_PATH
    APP_LIB_PATH  = $(APPLICATION_PATH)/libraries
endif

ifeq ($(APP_LIBS_LIST),)
    s201         = $(realpath $(sort $(dir $(wildcard $(APP_LIB_PATH)/*/*.h $(APP_LIB_PATH)/*/*/*.h)))) # */
    APP_LIBS_LIST = $(subst $(APP_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s201)))
endif

ifeq ($(APP_LIBS_LOCK),)
    ifndef APP_LIBS
    ifneq ($(APP_LIBS_LIST),0)
        s204       = $(patsubst %,$(APP_LIB_PATH)/%,$(APP_LIBS_LIST))
        APP_LIBS   = $(realpath $(sort $(dir $(foreach dir,$(s204),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h)))))
    endif
    endif
endif

ifndef APP_LIB_OBJS
    FLAG = 1
    APP_LIB_C_SRC     = $(wildcard $(patsubst %,%/*.c,$(APP_LIBS))) # */
    APP_LIB_CPP_SRC   = $(wildcard $(patsubst %,%/*.cpp,$(APP_LIBS))) # */
    APP_LIB_AS_SRC    = $(wildcard $(patsubst %,%/*.s,$(APP_LIBS))) # */
    APP_LIB_OBJ_FILES = $(APP_LIB_C_SRC:.c=.c.o) $(APP_LIB_CPP_SRC:.cpp=.cpp.o) $(APP_LIB_AS_SRC:.s=.s.o)
    APP_LIB_OBJS      = $(patsubst $(APPLICATION_PATH)/%,$(OBJDIR)/%,$(APP_LIB_OBJ_FILES))
else
    FLAG = 0
endif

# USER sources
# wildcard required for ~ management
# ?ibraries required for libraries and Libraries
#
ifndef USER_LIB_PATH
    USER_LIB_PATH    = $(wildcard $(SKETCHBOOK_DIR)/?ibraries)
endif

ifndef USER_LIBS_LIST
	s202             = $(realpath $(sort $(dir $(wildcard $(USER_LIB_PATH)/*/*.h)))) # */
    USER_LIBS_LIST   = $(subst $(USER_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST),$(s202)))
endif

ifeq ($(USER_LIBS_LOCK),)
ifneq ($(USER_LIBS_LIST),0)
    s203             = $(patsubst %,$(USER_LIB_PATH)/%,$(USER_LIBS_LIST))
#	USER_LIBS        = $(realpath $(sort $(dir $(foreach dir,$(s203),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h)))))
#    USER_LIBS        = $(sort $(foreach dir,$(s203),$(shell find $(dir) -type d  | grep -v [eE]xample)))
    EXCLUDE_LIST     = $(shell echo $(strip $(EXCLUDE_NAMES)) | sed "s/ /|/g" )
    USER_LIBS       := $(sort $(foreach dir,$(s203),$(shell find $(dir) -type d | egrep -v '$(EXCLUDE_LIST)' )))

    USER_LIB_CPP_SRC = $(foreach dir,$(USER_LIBS),$(wildcard $(dir)/*.cpp)) # */
    USER_LIB_C_SRC   = $(foreach dir,$(USER_LIBS),$(wildcard $(dir)/*.c)) # */
    USER_LIB_H_SRC   = $(foreach dir,$(USER_LIBS),$(wildcard $(dir)/*.h)) # */

#    USER_LIB_CPP_SRC = $(wildcard $(patsubst %,%/*.cpp,$(USER_LIBS))) # */
#    USER_LIB_C_SRC   = $(wildcard $(patsubst %,%/*.c,$(USER_LIBS))) # */
#    USER_LIB_H_SRC   = $(wildcard $(patsubst %,%/*.h,$(USER_LIBS))) # */

    USER_OBJS        = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/user/%.cpp.o,$(USER_LIB_CPP_SRC))
    USER_OBJS       += $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/user/%.c.o,$(USER_LIB_C_SRC))
endif
endif


# LOCAL sources
#
LOCAL_LIB_PATH  = .
#LOCAL_LIB_PATH  = $(CURRENT_DIR)

ifndef LOCAL_LIBS_LIST
    s206            = $(sort $(dir $(wildcard $(LOCAL_LIB_PATH)/*/*.h))) # */
    LOCAL_LIBS_LIST = $(subst $(LOCAL_LIB_PATH)/,,$(filter-out $(EXCLUDE_LIST)/,$(s206))) # */
endif

ifneq ($(LOCAL_LIBS_LIST),0)
    s207          = $(patsubst %,$(LOCAL_LIB_PATH)/%,$(LOCAL_LIBS_LIST))
    s208          = $(sort $(dir $(foreach dir,$(s207),$(wildcard $(dir)/*.h $(dir)/*/*.h $(dir)/*/*/*.h))))
    LOCAL_LIBS    = $(shell echo $(s208)' ' | sed 's://:/:g' | sed 's:/ : :g')
endif

# Core main function check
s209             = $(wildcard $(patsubst %,%/*.cpp,$(LOCAL_LIBS))) $(wildcard $(LOCAL_LIB_PATH)/*.cpp) # */
LOCAL_CPP_SRCS   = $(filter-out %$(PROJECT_NAME_AS_IDENTIFIER).cpp, $(s209))

LOCAL_CC_SRCS    = $(wildcard $(patsubst %,%/*.cc,$(LOCAL_LIBS))) $(wildcard $(LOCAL_LIB_PATH)/*.cc) # */
LOCAL_C_SRCS     = $(wildcard $(patsubst %,%/*.c,$(LOCAL_LIBS))) $(wildcard $(LOCAL_LIB_PATH)/*.c) # */

# Use of implicit rule for LOCAL_PDE_SRCS
#
#LOCAL_PDE_SRCS  = $(wildcard *.$(SKETCH_EXTENSION))
LOCAL_AS1_SRCS   = $(wildcard $(patsubst %,%/*.S,$(LOCAL_LIBS))) $(wildcard $(LOCAL_LIB_PATH)/*.S) # */
LOCAL_AS2_SRCS   = $(wildcard $(patsubst %,%/*.s,$(LOCAL_LIBS))) $(wildcard $(LOCAL_LIB_PATH)/*.s) # */

LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.c.o) $(LOCAL_CPP_SRCS:.cpp=.cpp.o) $(LOCAL_PDE_SRCS:.$(SKETCH_EXTENSION)=.$(SKETCH_EXTENSION).o) $(LOCAL_CC_SRCS:.cc=.cc.o) $(LOCAL_AS1_SRCS:.S=.S.o) $(LOCAL_AS2_SRCS:.s=.s.o)
LOCAL_OBJS      = $(patsubst $(LOCAL_LIB_PATH)/%,$(OBJDIR)/%,$(filter-out %/$(PROJECT_NAME_AS_IDENTIFIER).o,$(LOCAL_OBJ_FILES)))

# All the objects
# ??? Does order matter?
#
ifeq ($(REMOTE_OBJS),)
    REMOTE_OBJS = $(sort $(CORE_OBJS) $(BUILD_CORE_OBJS) $(APP_LIB_OBJS) $(BUILD_APP_LIB_OBJS) $(VARIANT_OBJS) $(USER_OBJS))
endif
OBJS        = $(REMOTE_OBJS) $(LOCAL_OBJS)

# Dependency files
#
DEPS   = $(OBJS:.o=.d)


# Processor model and frequency
# ----------------------------------
#
ifndef MCU
    MCU   = $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
endif

ifndef F_CPU
    F_CPU = $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
endif

ifeq ($(OUT_PREPOSITION),)
    OUT_PREPOSITION = -o # end of line
endif


# Rules
# ----------------------------------
#
# Main targets
#
TARGET_A   = $(OBJDIR)/$(TARGET).a
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGET_BIN = $(OBJDIR)/$(TARGET).bin
TARGET_BIN2 = $(OBJDIR)/$(TARGET).bin2
TARGET_OUT = $(OBJDIR)/$(TARGET).out
TARGET_DOT = $(OBJDIR)/$(TARGET)
TARGET_TXT = $(OBJDIR)/$(TARGET).txt
TARGETS    = $(OBJDIR)/$(TARGET).*
TARGET_MCU = $(OBJDIR)/$(TARGET).mcu
# ~
TARGET_VXP = $(OBJDIR)/$(TARGET).vxp
# ~~

ifndef TARGET_HEXBIN
    TARGET_HEXBIN = $(TARGET_HEX)
endif

ifndef TARGET_EEP
    TARGET_EEP    =
endif

# List of dependencies
#
DEP_FILE   = $(OBJDIR)/depends.mk

# Executables
#
REMOVE  = rm -r
MV      = mv -f
CAT     = cat
ECHO    = echo

# General arguments
#
#ifeq ($(APP_LIBS_LOCK),)
    SYS_INCLUDES  = $(patsubst %,-I%,$(APP_LIBS))
    SYS_INCLUDES += $(patsubst %,-I%,$(BUILD_APP_LIBS))
    SYS_INCLUDES += $(patsubst %,-I%,$(USER_LIBS))
    SYS_INCLUDES += $(patsubst %,-I%,$(LOCAL_LIBS))
#endif

SYS_OBJS      = $(wildcard $(patsubst %,%/*.o,$(APP_LIBS))) # */
SYS_OBJS     += $(wildcard $(patsubst %,%/*.o,$(BUILD_APP_LIBS))) # */
SYS_OBJS     += $(wildcard $(patsubst %,%/*.o,$(USER_LIBS))) # */

# ~
ifeq ($(WARNING_OPTIONS),)
    WARNING_FLAGS = -Wall
else
    ifeq ($(WARNING_OPTIONS),0)
        WARNING_FLAGS = -w
    else
        WARNING_FLAGS = $(addprefix -W, $(WARNING_OPTIONS))
    endif
endif
# ~~

ifeq ($(OPTIMISATION),)
    OPTIMISATION = -Os -g
endif

ifeq ($(CPPFLAGS),)
    CPPFLAGS      = -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU)
    CPPFLAGS     += $(SYS_INCLUDES) -g $(OPTIMISATION) $(WARNING_FLAGS) -ffunction-sections -fdata-sections
    CPPFLAGS     += $(EXTRA_CPPFLAGS) -I$(CORE_LIB_PATH)
else
    CPPFLAGS     += $(SYS_INCLUDES)
endif

ifdef USB_FLAGS
    CPPFLAGS += $(USB_FLAGS)
endif    

ifdef USE_GNU99
    CFLAGS       += -std=gnu99
endif

# ~
ifeq (false,true)
    SCOPE_FLAG  := +$(PLATFORM):$(BUILD_CORE)
else
    SCOPE_FLAG  := -$(PLATFORM)
endif
# ~~

# CXX = flags for C++ only
# CPP = flags for both C and C++
#
ifeq ($(CXXFLAGS),)
    CXXFLAGS      = -fno-exceptions
else
    CXXFLAGS     += $(EXTRA_CXXFLAGS)
endif

ifeq ($(ASFLAGS),)
    ASFLAGS       = -$(MCU_FLAG_NAME)=$(MCU) -x assembler-with-cpp
endif

ifeq ($(LDFLAGS),)
    LDFLAGS       = -$(MCU_FLAG_NAME)=$(MCU) -Wl,--gc-sections $(OPTIMISATION) $(EXTRA_LDFLAGS)
endif

ifndef OBJCOPYFLAGS
    OBJCOPYFLAGS  = -Oihex -R .eeprom
endif

# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future


# 1- Build
# ----------------------------------
#
# Following rules manages APP and BUILD_APP, CORE and VARIANT libraries
#
$(OBJDIR)/%.cpp.o: $(APPLICATION_PATH)/%.cpp
	$(call SHOW,"1.1-APPLICATION CPP",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.c.o: $(APPLICATION_PATH)/%.c
	$(call SHOW,"1.2-APPLICATION C",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.s.o: $(APPLICATION_PATH)/%.s
	$(call SHOW,"1.3-APPLICATION AS",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.S.o: $(APPLICATION_PATH)/%.S
	$(call SHOW,"1.4-APPLICATION AS",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.d: $(APPLICATION_PATH)/%.c
	$(call SHOW,"1.5-APPLICATION D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.c.o)

$(OBJDIR)/%.d: $(APPLICATION_PATH)/%.cpp
	$(call SHOW,"1.6-APPLICATION D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.cpp.o)

$(OBJDIR)/%.d: $(APPLICATION_PATH)/%.S
	$(call SHOW,"1.7-APPLICATION D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.S.o)

$(OBJDIR)/%.d: $(APPLICATION_PATH)/%.s
	$(call SHOW,"1.8-APPLICATION D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.s.o)


# 2- Build
# ----------------------------------
#
# Following rules manages APP and BUILD_APP, CORE and VARIANT libraries
#
$(OBJDIR)/%.cpp.o: $(HARDWARE_PATH)/%.cpp
	$(call SHOW,"2.1-HARDWARE CPP",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.c.o: $(HARDWARE_PATH)/%.c
	$(call SHOW,"2.2-HARDWARE C",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.s.o: $(HARDWARE_PATH)/%.s
	$(call SHOW,"2.3-HARDWARE AS",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.S.o: $(HARDWARE_PATH)/%.S
	$(call SHOW,"2.4-HARDWARE AS",$@,$<)
	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.d: $(HARDWARE_PATH)/%.c
	$(call SHOW,"2.5-HARDWARE D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.c.o)

$(OBJDIR)/%.d: $(HARDWARE_PATH)/%.cpp
	$(call SHOW,"2.6-HARDWARE D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.cpp.o)

$(OBJDIR)/%.d: $(HARDWARE_PATH)/%.S
	$(call SHOW,"2.7-HARDWARE D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.S.o)

$(OBJDIR)/%.d: $(HARDWARE_PATH)/%.s
	$(call SHOW,"2.8-HARDWARE D",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.s.o)

# 3- USER library sources
#
$(OBJDIR)/user/%.cpp.o: $(USER_LIB_PATH)/%.cpp
	$(call SHOW,"3.1-USER CPP",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/user/%.c.o: $(USER_LIB_PATH)/%.c
	$(call SHOW,"3.2-USER C",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/user/%.d: $(USER_LIB_PATH)/%.cpp
	$(call SHOW,"3.3-USER CPP",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.cpp.o)

$(OBJDIR)/user/%.d: $(USER_LIB_PATH)/%.c
	$(call SHOW,"3.4-USER C",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.c.o)

    
# 4- LOCAL sources
# .o rules are for objects, .d for dependency tracking
# 
$(OBJDIR)/%.c.o: %.c
	$(call SHOW,"4.1-LOCAL C",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.cc.o: %.cc
	$(call SHOW,"4.2-LOCAL CC",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.cpp.o: 	%.cpp
	$(call SHOW,"4.3-LOCAL CPP",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.S.o: %.S
	$(call SHOW,"4.4-LOCAL AS",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.s.o: %.s
	$(call SHOW,"4.5-LOCAL AS",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< $(OUT_PREPOSITION)$@

$(OBJDIR)/%.d: %.c
	$(call SHOW,"4.6-LOCAL C",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(CFLAGS) $< -MF $@ -MT $(@:.d=.c.o)

$(OBJDIR)/%.d: %.cpp
	$(call SHOW,"4.7-LOCAL CPP",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CXX) -MM $(CPPFLAGS) $(CXXFLAGS) $< -MF $@ -MT $(@:.d=.cpp.o)

$(OBJDIR)/%.d: %.S
	$(call SHOW,"4.8-LOCAL AS",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.S.o)

$(OBJDIR)/%.d: %.s
	$(call SHOW,"4.9-LOCAL AS",$@,$<)

	@mkdir -p $(dir $@)
	$(QUIET)$(CC) -MM $(CPPFLAGS) $(ASFLAGS) $< -MF $@ -MT $(@:.d=.s.o)


# 5- Link
# ----------------------------------
#
$(TARGET_ELF): 	$(OBJS)
		@echo "---- Link ---- "
		$(call SHOW,"5.1-ARCHIVE",$@,.)

ifneq ($(FIRST_O_IN_A),)
		$(QUIET)$(AR) rcs $(TARGET_A) $(FIRST_O_IN_A)
endif

# ~
ifeq ($(PLATFORM),IntelYocto)
    ifneq ($(REMOTE_OBJS),)
		$(QUIET)$(AR) rcs $(TARGET_A) $(REMOTE_OBJS)
    endif
else
	$(QUIET)$(AR) rcs $(TARGET_A) $(REMOTE_OBJS)
endif
# ~~

ifneq ($(EXTRA_COMMAND),)
		$(call SHOW,"5.2-COPY",$@,.)

		$(EXTRA_COMMAND)
endif

ifneq ($(COMMAND_LINK),)
		$(call SHOW,"5.3-LINK",$@,.)

		$(QUIET)$(COMMAND_LINK)

else
		$(call SHOW,"5.4-LINK default",$@,.)

		$(QUIET)$(CXX) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(TARGET_A) $(LDFLAGS)
endif


$(TARGET_OUT): 	$(OBJS)
# ~
ifeq ($(BUILD_CORE),c2000)
		$(call SHOW,"5.5-ARCHIVE",$@,.)

		$(QUIET)$(AR) r $(TARGET_A) $(FIRST_O_IN_A)
		$(QUIET)$(AR) r $(TARGET_A) $(REMOTE_OBJS)

		$(call SHOW,"5.6-LINK",$@,.)

		$(QUIET)$(CC) $(CPPFLAGS) $(LDFLAGS) $(OUT_PREPOSITION)$@ $(LOCAL_OBJS) $(TARGET_A) $(COMMAND_FILES) -l$(LDSCRIPT)

else
		$(call SHOW,"5.7-LINK",$@,.)

endif
# ~~


# 6- Final conversions
# ----------------------------------
#
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf
	$(call SHOW,"6.1-COPY HEX",$@,$<)

	$(QUIET)$(OBJCOPY) -Oihex -R .eeprom $< $@
# ~
ifneq ($(SOFTDEVICE),)
	$(call SHOW,"6.2-COPY HEX",$@,$<)

	$(QUIET)$(MERGE_PATH)/$(MERGE_EXEC) $(SOFTDEVICE_HEX) -intel $(CURRENT_DIR)/$@ -intel $(OUT_PREPOSITION)$(CURRENT_DIR)/combined.hex $(MERGE_OPTS)
	$(QUIET)mv $(CURRENT_DIR)/combined.hex $(CURRENT_DIR)/$@
endif
# ~~

$(OBJDIR)/%.bin: $(OBJDIR)/%.elf
	$(call SHOW,"6.3-COPY BIN",$@,$<)
  ifneq ($(COMMAND_COPY),)
	$(QUIET)$(COMMAND_COPY)
  else
	$(QUIET)$(OBJCOPY) -Obinary $< $@
  endif

$(OBJDIR)/%.bin2: $(OBJDIR)/%.elf
	$(call SHOW,"6.4-COPY BIN",$@,$<)

	$(QUIET)$(ESP_POST_COMPILE) -eo $(BOOTLOADER_ELF) -bo Builds/$(TARGET)_$(ADDRESS_BIN1).bin -bm $(OBJCOPYFLAGS) -bf $(BUILD_FLASH_FREQ) -bz $(BUILD_FLASH_SIZE) -bs .text -bp 4096 -ec -eo $< -bs .irom0.text -bs .text -bs .data -bs .rodata -bc -ec
	$(QUIET)cp Builds/$(TARGET)_$(ADDRESS_BIN1).bin Builds/$(TARGET).bin

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf
	$(call SHOW,"6.5-COPY EEP",$@,$<)

	-$(QUIET)$(OBJCOPY) -Oihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings --change-section-lma .eeprom=0 $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf
	$(call SHOW,"6.6-COPY LSS",$@,$<)

	$(QUIET)$(OBJDUMP) -h -S $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf
	$(call SHOW,"6.7-COPY SYM",$@,$<)

	$(QUIET)$(NM) -n $< > $@

#$(OBJDIR)/%.txt: $(OBJDIR)/%.out
#	$(call SHOW,"6.8-COPY",$@,$<)
#
#	echo ' -boot -sci8 -a $< -o $@'
#	$(QUIET)$(OBJCOPY) -boot -sci8 -a $< -o $@

$(OBJDIR)/%.mcu: $(OBJDIR)/%.elf
	$(call SHOW,"6.9-COPY MCU",$@,$<)

	@rm -f $(OBJDIR)/intel_mcu.*
	@cp $(OBJDIR)/embeddedcomputing.elf $(OBJDIR)/intel_mcu.elf
	@cd $(OBJDIR) ; export TOOLCHAIN_PATH=$(APP_TOOLS_PATH) ; $(UTILITIES_PATH)/generate_mcu.sh

# ~
$(OBJDIR)/%.vxp: $(OBJDIR)/%.elf
	$(call SHOW,"6.10-COPY VXP",$@,$<)

	$(QUIET)cp $(OBJDIR)/embeddedcomputing.elf $(OBJDIR)/embeddedcomputing2.elf
	$(QUIET)$(OBJCOPY) -i $<
	$(QUIET)mv $(OBJDIR)/embeddedcomputing2.elf $(OBJDIR)/embeddedcomputing.elf
# ~~

$(OBJDIR)/%: $(OBJDIR)/%.elf
	$(call SHOW,"6.11-COPY",$@,$<)

	$(QUIET)cp $< $@


# Size of file
# ----------------------------------
#
ifeq ($(TARGET_HEXBIN),$(TARGET_HEX))
#    FLASH_SIZE = $(SIZE) --target=ihex --totals $(CURRENT_DIR)/$(TARGET_HEX) | grep TOTALS | tr '\t' . | cut -d. -f2 | tr -d ' '
    FLASH_SIZE = $(SIZE) --target=ihex --totals $(CURRENT_DIR)/$(TARGET_HEX) | grep TOTALS | awk '{t=$$3 + $$2} END {print t}'
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3 + $$2} END {print t}'

# ~
else ifeq ($(TARGET_HEXBIN),$(TARGET_VXP))
    FLASH_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$1 + $$2} END {print t}'
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3} END {print t}'
# ~~

else ifeq ($(TARGET_HEXBIN),$(TARGET_BIN))
    FLASH_SIZE = $(SIZE) --target=binary --totals $(CURRENT_DIR)/$(TARGET_BIN) | grep TOTALS | tr '\t' . | cut -d. -f2 | tr -d ' '
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3 + $$2} END {print t}'

else ifeq ($(TARGET_HEXBIN),$(TARGET_BIN2))

    FLASH_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$1 + $$2} END {print t}'
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3 + $$2} END {print t}'

else ifeq ($(TARGET_HEXBIN),$(TARGET_OUT))
    FLASH_SIZE = cat Builds/embeddedcomputing.map | grep '^.text' | awk 'BEGIN { OFS = "" } {print "0x",$$4}' | xargs printf '%d'
    RAM_SIZE = cat Builds/embeddedcomputing.map | grep '^.ebss' | awk 'BEGIN { OFS = "" } {print "0x",$$4}' | xargs printf '%d'

else ifeq ($(TARGET_HEXBIN),$(TARGET_DOT))
    FLASH_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$1} END {print t}'
#    FLASH_SIZE = ls -all $(CURRENT_DIR)/$(TARGET_DOT) | awk '{print $$5}'
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3 + $$2} END {print t}'

else ifeq ($(TARGET_HEXBIN),$(TARGET_ELF))
    FLASH_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$1} END {print t}'
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$3 + $$2} END {print t}'

else ifeq ($(TARGET_HEXBIN),$(TARGET_MCU))
    FLASH_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$4} END {print t}'
    RAM_SIZE = $(SIZE) $(CURRENT_DIR)/$(TARGET_ELF) | sed '1d' | awk '{t=$$4} END {print t}'
endif

ifeq ($(MAX_FLASH_SIZE),)
    MAX_FLASH_SIZE = $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_size)
endif
ifeq ($(MAX_RAM_SIZE),)
    MAX_RAM_SIZE = $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_data_size)
endif
ifeq ($(MAX_RAM_SIZE),)
    MAX_RAM_SIZE = $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_ram_size)
endif

ifneq ($(MAX_FLASH_SIZE),)
#     MAX_FLASH_BYTES   = 'bytes (of a '$(MAX_FLASH_SIZE)' byte maximum)'
# ~
    MAX_FLASH_BYTES   = 'bytes used ('$(shell echo "scale=1; (100.0* $(shell $(FLASH_SIZE)))/$(MAX_FLASH_SIZE)" | bc)'% of '$(MAX_FLASH_SIZE)' maximum), '$(shell echo "$(MAX_FLASH_SIZE) - $(shell $(FLASH_SIZE))"|bc) 'bytes free ('$(shell echo "scale=1; 100-(100.0* $(shell $(FLASH_SIZE)))/$(MAX_FLASH_SIZE)"|bc)'%)'
# ~~
else
    MAX_FLASH_BYTES   = bytes used
endif

ifneq ($(MAX_RAM_SIZE),)
#    MAX_RAM_BYTES   = 'bytes (of a '$(MAX_RAM_SIZE)' byte maximum)'
# ~
    MAX_RAM_BYTES   = 'bytes used ('$(shell echo "scale=1; (100.0* $(shell $(RAM_SIZE)))/$(MAX_RAM_SIZE)" | bc)'% of '$(MAX_RAM_SIZE)' maximum), '$(shell echo "$(MAX_RAM_SIZE) - $(shell $(RAM_SIZE))"|bc) 'bytes free ('$(shell echo "scale=1; 100-(100.0* $(shell $(RAM_SIZE)))/$(MAX_RAM_SIZE)"|bc)'%)'
# ~~
else
    MAX_RAM_BYTES   = bytes used
endif


# Serial monitoring
# ----------------------------------
#

# First /dev port
#
#ifndef SERIAL_PORT
#    SERIAL_PORT = $(firstword $(wildcard $(BOARD_PORT)))
#endif

ifndef SERIAL_BAUDRATE
    SERIAL_BAUDRATE = 9600
endif

ifndef SERIAL_COMMAND
    SERIAL_COMMAND  = screen
endif

STARTCHRONO      = $(shell $(UTILITIES_PATH)/embedXcode_chrono)
STOPCHRONO       = $(shell $(UTILITIES_PATH)/embedXcode_chrono -s)

ifeq ($(PLATFORM),LinkIt)
    ifeq ($(BUILD_CORE),arduino)
        USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt | head -1)
    else
        USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt | tail -1)
    endif

else ifeq ($(PLATFORM),Energia)
    ifeq ($(BUILD_CORE),msp432)
        USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt | head -1)
    else ifeq ($(BUILD_CORE),cc2600emt)
        USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt | head -1)
    else
        USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt | tail -1)
    endif

#    $(shell ls -1 $(BOARD_PORT) | tail -1 > $(UTILITIES_PATH)/serial.txt)
#    $(shell ls -1 $(BOARD_PORT) | head -1 > $(UTILITIES_PATH)/serial.txt)
# ~ 
else ifeq ($(PLATFORM),linkitone)
    USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt | head -1)
# ~~

else
    USED_SERIAL_PORT = $(shell cat $(UTILITIES_PATH)/serial.txt)
endif


# Info for debugging
# ----------------------------------
#
# 0- Info
#
info:
#		@if [ -f $(CURRENT_DIR)/About/About.txt ]; then $(CAT) $(CURRENT_DIR)/About/About.txt | head -6; fi;
		@if [ -f $(UTILITIES_PATH)/embedXcode_check ]; then $(UTILITIES_PATH)/embedXcode_check; fi
		@echo $(STARTCHRONO)


ifneq ($(MAKECMDGOALS),boards)
  ifneq ($(MAKECMDGOALS),clean)
		@echo ==== Info ====
		@echo ---- Project ----
		@echo 'Target		'$(MAKECMDGOALS)
		@echo 'Name		'$(PROJECT_NAME)' ('$(SKETCH_EXTENSION)')'
#		@echo 'Tag			'$(BOARD_TAG)
#		@echo 'Extension		'$(SKETCH_EXTENSION)

#		@echo 'User			'$(HOME)

#    ifneq ($(PLATFORM),Wiring)
    ifneq ($PLATFORM_VERSION),)
		@echo ---- Platform ----
		@echo 'IDE			'$(PLATFORM)' version '$(PLATFORM_VERSION)
    endif

    ifneq ($(WARNING_MESSAGE),)
		@echo 'WARNING		$(WARNING_MESSAGE)'
# ~
#		@osascript -e 'tell application "System Events" to display dialog "$(WARNING_MESSAGE)" buttons {"OK"} default button {"OK"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns") with title "embedXcode" giving up after 5'
		@osascript -e 'tell application "System Events" to display dialog "$(WARNING_MESSAGE)" buttons {"OK"} default button {"OK"} with icon 2 with title "embedXcode" giving up after 5'
# ~~
    endif
    ifneq ($(INFO_MESSAGE),)
		@echo 'Information	$(INFO_MESSAGE)'
# ~
#		@osascript -e 'tell application "System Events" to display notification "$(INFO_MESSAGE)" with title "embedXcode" subtitle "Information" sound name "Dong"'
#		@osascript -e 'tell application "System Events" to display dialog "$(INFO_MESSAGE)" buttons {"OK"} default button {"OK"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns")  with title "embedXcode" giving up after 5'
# ~~
    endif

    ifneq ($(BUILD_CORE),)
		@echo 'Platform		'$(BUILD_CORE)
    endif

    ifneq ($(VARIANT),)
		@echo 'Variant		'$(VARIANT)
    endif

    ifneq ($(USB_VID),)
		@echo 'USB			VID = '$(USB_VID)', PID = '$(USB_PID)
    endif

#    ifneq ($(USB_PID),)
#		@echo 'USB PID		'$(USB_PID)
#    endif

		@echo ---- Board ----
		@echo 'Name		''$(BOARD_NAME)' ' ('$(BOARD_TAG)')'
#		@echo 'Frequency		'$(F_CPU)
ifneq ($(F_CPU),)
		@echo 'MCU			'$(MCU)' at '$(F_CPU)
else
		@echo 'MCU			'$(MCU)
endif
#    ifneq ($(MAX_FLASH_SIZE),)
#		@echo 'Flash memory	'$(MAX_FLASH_SIZE)' bytes'
#   endif
#   ifneq ($(MAX_RAM_SIZE),)
#		@echo 'SRAM memory	'$(MAX_RAM_SIZE)' bytes'
#   endif
		@echo 'Memory		Flash = '$(MAX_FLASH_SIZE)' bytes, RAM = '$(MAX_RAM_SIZE)' bytes'

		@echo ---- Port ----
		@echo 'Uploader		'$(UPLOADER)

    ifeq ($(UPLOADER),avrdude)
        ifeq ($(AVRDUDE_NO_SERIAL_PORT),1)
			@echo 'AVRdude   	no serial port'
        else
			@echo 'AVRdude    	'$(AVRDUDE_PORT)
        endif
        ifneq ($(AVRDUDE_PROGRAMMER),)
			@echo 'Programmer	'$(AVRDUDE_PROGRAMMER)
        endif
    endif
    ifeq ($(UPLOADER),mspdebug)
		@echo 'Protocol    	'$(UPLOADER_PROTOCOL)
    endif

    ifeq ($(AVRDUDE_NO_SERIAL_PORT),1)
		@echo 'Serial   	  	no serial port'
# ~
    else ifeq ($(BOARD_PORT),ssh)
		@echo 'Serial   	  	'$(SSH_ADDRESS)
# ~~

    else
		@echo 'Serial   	  	'$(USED_SERIAL_PORT)
    endif

		@echo ---- Libraries ----
		@echo . Core libraries from $(CORE_LIB_PATH) | cut -d. -f1,2
		@echo $(CORE_LIBS_LIST)

		@echo . Application libraries from $(basename $(APP_LIB_PATH)) | cut -d. -f1,2
    ifneq ($(strip $(APP_LIBS_LIST)),)
		@echo $(APP_LIBS_LIST)
    endif
    ifneq ($(BUILD_APP_LIBS_LIST),)
		@echo $(sort $(BUILD_APP_LIBS_LIST))
    endif

		@echo . User libraries from $(SKETCHBOOK_DIR)
		@echo $(USER_LIBS_LIST)

		@echo . Local libraries from $(CURRENT_DIR)

    ifneq ($(wildcard $(LOCAL_LIB_PATH)/*.h),) # */
		@echo $(subst .h,,$(notdir $(wildcard $(LOCAL_LIB_PATH)/*.h))) # */
    endif
    ifneq ($(strip $(LOCAL_LIBS_LIST)),)
		@echo '$(LOCAL_LIBS_LIST) ' | sed 's/\/ / /g'
    endif
    ifeq ($(wildcard $(LOCAL_LIB_PATH)/*.h),) # */
        ifeq ($(strip $(LOCAL_LIBS_LIST)),)
			@echo 0
        endif
    endif

		@echo ---- Tools ----
		@defaults read /System/Library/PrivateFrameworks/ServerInformation.framework/Versions/A/Resources/English.lproj/SIMachineAttributes.plist $$(sysctl hw.model | cut -d: -f2) | grep marketingModel | cut -d\" -f2-3 | sed 's/\\//g'
		@echo $$(sw_vers -productName) $$(sw_vers -productVersion)' ('$$(sw_vers -buildVersion)')'
#		@echo Xcode $$(system_profiler SPDeveloperToolsDataType | grep "Version" | cut -d: -f2) $$(echo on Mac $$(system_profiler SPSoftwareDataType | grep "System Version" | cut -d: -f2))
#		@echo Mac $$(system_profiler SPSoftwareDataType | grep "System Version" | cut -d: -f2)
		@echo Xcode $$(system_profiler SPDeveloperToolsDataType | grep "Version" | cut -d: -f2)
#		@echo Xcode $(XCODE_VERSION_ACTUAL)' ('$(XCODE_PRODUCT_BUILD_VERSION)')' | sed "s/\( ..\)/\1\./"
#		@echo $(EMBEDXCODE_EDITION) $(EMBEDXCODE_RELEASE) | sed 's/[0-9]/&./g' | sed 's/.$$//'
#		@echo $(EMBEDXCODE_EDITION) release $$(printf '%06s' $(EMBEDXCODE_RELEASE) | fold -w2 | paste -sd. -)
		@echo $(EMBEDXCODE_EDITION) release $(EMBEDXCODE_RELEASE)
		@if [ -f $(UTILITIES_PATH)/embedXcode_check ]; then $(UTILITIES_PATH)/embedXcode_check -v; fi
		@if [ -f $(UTILITIES_PATH)/embedXcode_prepare ]; then $(UTILITIES_PATH)/embedXcode_prepare -v; fi
		@if [ -f $(UTILITIES_PATH)/embedXcode_debug ]; then $(UTILITIES_PATH)/embedXcode_debug -v; fi
		@echo $(PLATFORM) $(PLATFORM_VERSION)
ifeq ($(BUILD_CORE),c2000)
		@$(CC) -version | head -1
else
		@$(CC) --version | head -1
endif

# ~
    ifeq ($(MAKECMDGOALS),debug)
		@if [ -n '$(UPLOADER_EXEC)' ] ; then $(UPLOADER_EXEC) --version | head -1 ; fi
		@if [ -n '$(GDB)' ] ; then $(GDB) --version | head -1 ; fi
		@if [ -n '$(MDB)' ] ; then $(MDB) --version | head -1 ; fi
    endif
# ~~

		@echo ==== Info done ====
  endif
endif


# ~
# Additional features
# ----------------------------------
#
ifeq ($(MAKECMDGOALS),document)
    include $(MAKEFILE_PATH)/Doxygen.mk
endif

ifeq ($(MAKECMDGOALS),distribute)
    include $(MAKEFILE_PATH)/Doxygen.mk
endif

ifeq ($(MAKECMDGOALS),debug)
    include $(MAKEFILE_PATH)/Debug.mk
endif

ifeq ($(MAKECMDGOALS),style)
    include $(MAKEFILE_PATH)/Doxygen.mk
endif
# ~~


# Release management
# ----------------------------------
#
include $(MAKEFILE_PATH)/About.mk


# Rules
# ----------------------------------
#
all: 		info message_all clean compile reset raw_upload serial end_all prepare


build: 		info message_build clean compile end_build prepare


compile:	info message_compile $(OBJDIR) $(TARGET_HEXBIN) $(TARGET_EEP) size
		@echo $(BOARD_TAG) > $(NEW_TAG)


prepare:
		@if [ -f $(UTILITIES_PATH)/embedXcode_prepare ]; then $(UTILITIES_PATH)/embedXcode_prepare $(SCOPE_FLAG) "$(USER_LIB_PATH)"; rm -r $(UTILITIES_PATH)/embedXcode_prepare; fi;


$(OBJDIR):
		@echo "---- Build ---- "
		@mkdir $(OBJDIR)


$(DEP_FILE):	$(OBJDIR) $(DEPS)
		@echo "9-" $<
		@cat $(DEPS) > $(DEP_FILE)


upload:		message_upload reset raw_upload
		@echo "==== upload done ==== "


reset:
		@echo "---- Reset ---- "
# ~
ifeq ($(BOARD_PORT),pgm)

else ifeq ($(BOARD_PORT),ssh)
		-killall ssh

else
# ~~
		-screen -X kill
		-screen -wipe
		sleep 1

    ifeq ($(UPLOADER),stlink)

    else ifeq ($(UPLOADER),dfu-util)
		$(call SHOW,"9.1-RESET",$(UPLOADER_RESET))

		$(UPLOADER_RESET)
		@sleep 1
    endif

    ifdef USB_RESET
		$(call SHOW,"9.2-RESET",USB_RESET 1200)

		-stty -f $(AVRDUDE_PORT) 1200
#		$(USB_RESET) $(USED_SERIAL_PORT)
		@sleep 2
# ~
    endif
# ~~
endif

# stty on Mac OS likes -F, but on Debian it likes -f redirecting
# stdin/out appears to work but generates a spurious error on MacOS at
# least. Perhaps it would be better to just do it in perl ?
#		@if [ -z "$(AVRDUDE_PORT)" ]; then \
#			echo "No Arduino-compatible TTY device found -- exiting"; exit 2; \
#			fi
#		for STTYF in 'stty --file' 'stty -f' 'stty <' ; \
#		  do $$STTYF /dev/tty >/dev/null 2>/dev/null && break ; \
#		done ;\
#		$$STTYF $(AVRDUDE_PORT)  hupcl ;\
#		(sleep 0.1 || sleep 1)     ;\
#		$$STTYF $(AVRDUDE_PORT) -hupcl


raw_upload:
		@echo "---- Upload ---- "

ifeq ($(RESET_MESSAGE),1)
		$(call SHOW,"10.0-UPLOAD",$(UPLOADER))

		@osascript -e 'tell application "System Events" to display dialog "Press the RESET button on the board $(BOARD_NAME) and then click OK." buttons {"OK"} default button {"OK"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns") with title "embedXcode"'
# Give Mac OS X enough time for enumerating the USB ports
		@sleep 3
endif

ifneq ($(COMMAND_PREPARE),)
		$(call SHOW,"10.80-PREPARE",$(UPLOADER))

		$(COMMAND_PREPARE)
endif

ifneq ($(COMMAND_UPLOAD),)
		$(call SHOW,"10.90-UPLOAD",$(UPLOADER))

		$(COMMAND_UPLOAD)
# ~
else ifeq ($(BOARD_PORT),pgm)
		$(call SHOW,"10.1-UPLOAD",$(UPLOADER))

		@if [ -f $(UTILITIES_PATH)/embedXcode_debug ]; then export STECK_EXTENSION=$(STECK_EXTENSION); $(UTILITIES_PATH)/embedXcode_debug; fi;
		@osascript -e 'tell application "Terminal" to do script "$(MDB) \"$(UTILITIES_PATH_SPACE)/mdb.txt\""'

else ifeq ($(BOARD_PORT),ssh)

	$(eval BOARD_FILE = $(shell grep -rl $(CURRENT_DIR)/Configurations -e '$(BOARD_TAG) \| ssh'))

    ifeq ($(SSH_ADDRESS),)
		$(eval SSH_ADDRESS = $(shell grep ^SSH_ADDRESS '$(BOARD_FILE)' | cut -d= -f 2- | sed 's/^ //'))
    endif

    ifeq ($(SSH_PASSWORD),)
		$(eval SSH_PASSWORD = $(shell grep ^SSH_PASSWORD '$(BOARD_FILE)' | cut -d= -f 2- | sed 's/^ //'))
    endif

    ifeq ($(SSH_ADDRESS),)
		@echo 'SSH_ADDRESS not defined'
		exit 2
    endif

    ifeq ($(SSH_PASSWORD),)
		@echo 'SSH_PASSWORD not defined'
		exit 2
    endif


    ifeq ($(BOARD_TAG),yun)
		$(call SHOW,"10.2-UPLOAD",$(UPLOADER))

		@echo "Uploading 1/3"
		@$(UTILITIES_PATH)/sshpass -p '$(SSH_PASSWORD)' scp $(TARGET_HEX) root@$(SSH_ADDRESS):"/tmp/sketch.hex"

		@echo "Uploading 2/3"
		@$(UTILITIES_PATH)/sshpass -p '$(SSH_PASSWORD)' ssh root@$(SSH_ADDRESS) '/usr/bin/merge-sketch-with-bootloader.lua /tmp/sketch.hex'
		@$(UTILITIES_PATH)/sshpass -p '$(SSH_PASSWORD)' ssh root@$(SSH_ADDRESS) '/usr/bin/kill-bridge'

		@echo "Uploading 3/3"
		@$(UTILITIES_PATH)/sshpass -p '$(SSH_PASSWORD)' ssh root@$(SSH_ADDRESS) '/usr/bin/run-avrdude /tmp/sketch.hex';
		@sleep 1

      ifneq ($(wildcard www/*),) # */
		@echo "Uploading www folder"
		@$(UTILITIES_PATH)/sshpass -p '$(SSH_PASSWORD)' ssh root@$(SSH_ADDRESS) 'mkdir -p /mnt/sda1/arduino/www/$(PROJECT_NAME_AS_IDENTIFIER)'
		@$(UTILITIES_PATH)/sshpass -p '$(SSH_PASSWORD)' scp -r www/* root@$(SSH_ADDRESS):/mnt/sda1/arduino/www/$(PROJECT_NAME_AS_IDENTIFIER) # */
		@open http://$(SSH_ADDRESS)/sd/$(PROJECT_NAME_AS_IDENTIFIER)
      endif

    else ifeq ($(BOARD_TAG),izmir_ec)
		$(call SHOW,"10.3-UPLOAD",$(UPLOADER))

		osascript -e 'tell application "Terminal" to do script "cd $(CURRENT_DIR); $(UTILITIES_PATH)/uploader_ssh.sh $(SSH_ADDRESS) $(SSH_PASSWORD) $(REMOTE_FOLDER) $(TARGET) -exec"'

    else ifeq ($(BOARD_TAG),izmir_ec_yocto)
      ifneq ($(MAKECMDGOALS),debug)

		$(call SHOW,"10.21-UPLOAD",$(UPLOADER))

		osascript -e 'tell application "Terminal" to do script "cd $(CURRENT_DIR); $(UTILITIES_PATH)/uploader_ssh.sh $(SSH_ADDRESS) $(SSH_PASSWORD) $(REMOTE_FOLDER) $(TARGET) -exec"'
      endif
#    endif

    else ifeq ($(BOARD_TAG),BeagleBoneDebian)
      ifneq ($(MAKECMDGOALS),debug)

		$(call SHOW,"10.22-UPLOAD",$(UPLOADER))


		osascript -e 'tell application "Terminal" to do script "cd $(CURRENT_DIR); $(UTILITIES_PATH)/uploader_ssh.sh $(SSH_ADDRESS) $(SSH_PASSWORD) $(REMOTE_FOLDER) $(TARGET) -exec"'
      endif

    else ifeq ($(BOARD_TAG),izmir_ec_yocto_MCU)
		$(call SHOW,"10.27-UPLOAD",$(UPLOADER))

#		osascript -e 'tell application "Terminal" to do script "cd $(CURRENT_DIR); export FIRMWARE_TOOLS_PATH=$(UTILITIES_PATH) ; export SSH_USER=root ; export SSH_IP_ADDR=$(SSH_ADDRESS) ; export SSH_PASSWORD=$(SSH_PASSWORD) ; bash $(UTILITIES_PATH)/download.sh install $(OBJDIR)"'
		echo $(OBJDIR)

		osascript -e 'tell application "Terminal" to do script "cd $(CURRENT_DIR); $(UTILITIES_PATH)/uploader_mcu.sh $(SSH_ADDRESS) $(SSH_PASSWORD) /lib/firmware $(OBJDIR)/intel_mcu.bin \"$(MCU_CONFIGURATION)\""'
#		echo "-- 1/3 Preparing"
#		$(UTILITIES_PATH)/ssh_password $(SSH_ADDRESS) $(SSH_PASSWORD) rm /lib/firmware/intel_mcu.bin

#		echo "-- 2/3 Uploading"
#		$(UTILITIES_PATH)/scp_password $(SSH_ADDRESS) $(SSH_PASSWORD) $(BUILDS)/intel_mcu.bin /lib/firmware/intel_mcu.bin

#		echo "-- 3/3 Running"
#		$(UTILITIES_PATH)/ssh_password $(SSH_ADDRESS) $(SSH_PASSWORD) $(COMMAND)
#		$(UTILITIES_PATH)/ssh_password $(SSH_ADDRESS) $(SSH_PASSWORD) reboot

    endif
# ~~
else ifeq ($(UPLOADER),izmir_tty)
		$(call SHOW,"10.4-UPLOAD",$(UPLOADER))

		bash $(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_ELF) $(USED_SERIAL_PORT)

else ifeq ($(UPLOADER),micronucleus)
		$(call SHOW,"10.5-UPLOAD",$(UPLOADER))

		osascript -e 'tell application "System Events" to display dialog "Click OK and plug the Digispark board into the USB port." buttons {"OK"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns") with title "embedXcode"'

		$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -P$(USED_SERIAL_PORT) -Uflash:w:$(TARGET_HEX):i

else ifeq ($(PLATFORM),RedBearLab)
		$(call SHOW,"10.6-UPLOAD",$(UPLOADER))
		sleep 2

		$(QUIET)$(OBJCOPY) -Oihex -Ibinary $(TARGET_BIN) $(TARGET_HEX)
		$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -P$(USED_SERIAL_PORT) -Uflash:w:$(TARGET_HEX):i
		sleep 2

else ifeq ($(UPLOADER),avrdude)

  ifeq ($(AVRDUDE_SPECIAL),1)
		$(call SHOW,"10.7-UPLOAD",$(UPLOADER) $(AVRDUDE_PROGRAMMER))

        ifeq ($(AVR_FUSES),1)
            $(AVRDUDE_EXEC) -p$(AVRDUDE_MCU) -C$(AVRDUDE_CONF) -c$(AVRDUDE_PROGRAMMER) -e -U lock:w:$(ISP_LOCK_FUSE_PRE):m -U hfuse:w:$(ISP_HIGH_FUSE):m -U lfuse:w:$(ISP_LOW_FUSE):m -U efuse:w:$(ISP_EXT_FUSE):m
        endif
		$(AVRDUDE_EXEC) -p$(AVRDUDE_MCU) -C$(AVRDUDE_CONF) -c$(AVRDUDE_PROGRAMMER) $(AVRDUDE_OTHER_OPTIONS) -U flash:w:$(TARGET_HEX):i
        ifeq ($(AVR_FUSES),1)
            $(AVRDUDE_EXEC) -p$(AVRDUDE_MCU) -C$(AVRDUDE_CONF) -c$(AVRDUDE_PROGRAMMER) -U lock:w:$(ISP_LOCK_FUSE_POST):m
        endif

  else
		$(call SHOW,"10.8-UPLOAD",$(UPLOADER))

        ifeq ($(USED_SERIAL_PORT),)
			$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -Uflash:w:$(TARGET_HEX):i
        else
			$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_OPTS) -P$(USED_SERIAL_PORT) -Uflash:w:$(TARGET_HEX):i
        endif
    ifeq ($(AVRDUDE_PROGRAMMER),avr109)
		sleep 2
    endif

  endif

else ifeq ($(UPLOADER),bossac)
		$(call SHOW,"10.9-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_BIN) -R

else ifeq ($(UPLOADER),openocd)
    ifneq ($(MAKECMDGOALS),debug)
		$(call SHOW,"10.10-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) $(UPLOADER_OPTS) -c "program $(TARGET_BIN) $(UPLOADER_COMMAND)"
    endif

else ifeq ($(UPLOADER),mspdebug)
		$(call SHOW,"10.10-UPLOAD",$(UPLOADER))

        
  ifeq ($(UPLOADER_PROTOCOL),tilib)
		cd $(UPLOADER_PATH); ./mspdebug $(UPLOADER_OPTS) "$(UPLOADER_COMMAND) $(CURRENT_DIR_SPACE)/$(TARGET_HEX)";

  else
		$(UPLOADER_EXEC) $(UPLOADER_OPTS) "$(UPLOADER_COMMAND) $(TARGET_HEX)"
  endif
        
else ifeq ($(UPLOADER),lm4flash)
# ~
    ifneq ($(MAKECMDGOALS),debug)
# ~~
		$(call SHOW,"10.11-UPLOAD",$(UPLOADER))

		-killall openocd
		$(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_BIN)
# ~
    endif
# ~~

else ifeq ($(UPLOADER),cc3200serial)
# ~
    ifneq ($(MAKECMDGOALS),debug)
# ~~
		$(call SHOW,"10.12-UPLOAD",$(UPLOADER))

		-killall openocd
		@cp -r $(APP_TOOLS_PATH)/dll ./dll
		$(UPLOADER_EXEC) $(USED_SERIAL_PORT) $(TARGET_BIN)
		@if [ -d ./dll ]; then rm -R ./dll; fi
# ~
    endif
# ~~

else ifeq ($(UPLOADER),DSLite)
#    ifneq ($(MAKECMDGOALS),debug)
		$(call SHOW,"10.28-UPLOAD",$(UPLOADER))

#		-killall openocd
		$(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_ELF)
#		@if [ -d ./dll ]; then rm -R ./dll; fi
#    endif

else ifeq ($(UPLOADER),serial_loader2000)
		$(call SHOW,"10.13-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) -f $(TARGET_TXT) $(UPLOADER_OPTS) -p $(USED_SERIAL_PORT)

else ifeq ($(UPLOADER),dfu-util)
		$(call SHOW,"10.14-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) $(UPLOADER_OPTS) -D $(TARGET_BIN) -R
		sleep 4

else ifeq ($(UPLOADER),teensy_flash)
		$(call SHOW,"10.15-UPLOAD",$(UPLOADER))

		$(TEENSY_POST_COMPILE) -file=$(basename $(notdir $(TARGET_HEX))) -path=$(dir $(abspath $(TARGET_HEX))) -tools=$(abspath $(TEENSY_FLASH_PATH))
		sleep 2
		$(TEENSY_REBOOT)
		sleep 2

else ifeq ($(UPLOADER),lightblue_loader)
		$(call SHOW,"10.16-UPLOAD",$(UPLOADER))

		$(LIGHTBLUE_POST_COMPILE) -board="$(BOARD_TAG)" -tools="$(abspath $(LIGHTBLUE_FLASH_PATH))" -path="$(dir $(abspath $(TARGET_HEX)))" -file="$(basename $(notdir $(TARGET_HEX)))"
		sleep 2

else ifeq ($(UPLOADER),izmirdl)
		$(call SHOW,"10.17-UPLOAD",$(UPLOADER))

		bash $(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_ELF) $(USED_SERIAL_PORT)
#		osascript -e 'tell application "Terminal" to do script "cd $(CURRENT_DIR) ; $(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_ELF) $(USED_SERIAL_PORT)"'

else ifeq ($(UPLOADER),spark_usb)
		$(call SHOW,"10.18-UPLOAD",$(UPLOADER))

		$(eval SPARK_NAME = $(shell $(UPLOADER_EXEC) -l | grep 'serial' | cut -d\= -f8 | sed 's/\"//g' | head -1))

		@if [ -z '$(SPARK_NAME)' ] ; then echo 'ERROR No DFU found' ; exit 1 ; fi
		@echo 'DFU found $(SPARK_NAME)'

		$(PREPARE_EXEC) $(PREPARE_OPTS) "$(CURRENT_DIR)/$(TARGET_BIN)"
		$(UPLOADER_EXEC) $(UPLOADER_OPTS) "$(CURRENT_DIR)/$(TARGET_BIN)"

# ~
else ifeq ($(UPLOADER),spark_wifi)
	$(call SHOW,"10.19-UPLOAD",$(UPLOADER))
    ifeq ($(SPARK_NAME),)
		$(eval SPARK_NAME = $(shell $(UPLOADER_EXEC) list | tr '\[' '\n' | grep 'online' | cut -d\] -f1 ))
    endif

		@if [ -z '$(SPARK_NAME)' ] ; then echo 'ERROR No core found' ; echo 'Have you run particle cloud login?'; exit 1 ; fi

		@echo 'Found core $(SPARK_NAME)'

		$(UPLOADER_EXEC) $(UPLOADER_OPTS) "$(CURRENT_DIR)/$(TARGET_BIN)"
		sleep 60

else ifeq ($(UPLOADER),robotis-loader)
		$(call SHOW,"10.20-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) $(USED_SERIAL_PORT) $(TARGET_BIN)

else ifeq ($(UPLOADER),RFDLoader)
		$(call SHOW,"10.21-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) -q $(USED_SERIAL_PORT) $(TARGET_HEX)

else ifeq ($(UPLOADER),PushTool)
		$(call SHOW,"10.22-UPLOAD",$(UPLOADER))

		$(UPLOADER_EXEC) $(UPLOADER_OPTS) -b $(USED_SERIAL_PORT) -p $(TARGET_VXP)

# ~~

else ifeq ($(UPLOADER),cp)
# ~
    ifneq ($(MAKECMDGOALS),debug)
# ~~
		$(call SHOW,"10.23-UPLOAD",$(UPLOADER))

# Option 1
#		if [ -f $(USED_VOLUME_PORT)/*.bin ] ; then rm $(USED_VOLUME_PORT)/*.bin ; fi ; # */
#		$(UPLOADER_EXEC) $(UPLOADER_OPTS) $(TARGET_BIN) $(USED_VOLUME_PORT)
# Option 2
# Some boards require the Finder, not cp, to copy the .bin file to board USB volume.
		osascript -e 'tell application "Finder" to duplicate file POSIX file "$(CURRENT_DIR)/$(TARGET_HEXBIN)" to disk "$(USED_VOLUME_PORT:/Volumes/%=%)" with replacing'

# Waiting for USB enumeration
		@sleep 5
# ~
    endif
# ~~

else ifeq ($(UPLOADER),stlink)
# ~
    ifneq ($(MAKECMDGOALS),debug)
# ~~
		$(call SHOW,"10.23-UPLOAD",$(UPLOADER))

		$(UPLOADER_PATH)/$(UPLOADER_EXEC) write $(CURRENT_DIR)/$(TARGET_BIN) $(UPLOADER_OPTS)
# ~
    endif
# ~~


else ifeq ($(UPLOADER),BsLoader.jar)
	$(call SHOW,"10.24-UPLOAD",$(UPLOADER))

#	echo 'USED_SERIAL_PORT = '$(USED_SERIAL_PORT)
	$(UPLOADER_EXEC) $(TARGET_HEX) $(USED_SERIAL_PORT) $(UPLOADER_OPTS)

else ifeq ($(UPLOADER),esptool)
	$(call SHOW,"10.25-UPLOAD",$(UPLOADER))

#	echo 'USED_SERIAL_PORT = '$(USED_SERIAL_PORT)
	$(UPLOADER_EXEC) $(UPLOADER_OPTS) -cp $(USED_SERIAL_PORT) -ca 0x$(ADDRESS_BIN1) -cf Builds/$(TARGET)_$(ADDRESS_BIN1).bin

else ifeq ($(UPLOADER),esptool.py)
	$(call SHOW,"10.26-UPLOAD",$(UPLOADER))

#	echo 'USED_SERIAL_PORT = '$(USED_SERIAL_PORT)
	$(UPLOADER_EXEC) $(UPLOADER_OPTS) --port $(USED_SERIAL_PORT) write_flash 0x00000 Builds/$(TARGET)_00000.bin 0x$(ADDRESS_BIN2) Builds/$(TARGET)_$(ADDRESS_BIN2).bin
else
		$(error No valid uploader)
endif

ifeq ($(POST_RESET_MESSAGE),1)
		$(call SHOW,"10.30-UPLOAD",$(UPLOADER))

		@osascript -e 'tell application "System Events" to display dialog "Press the RESET button on the board $(BOARD_NAME) and then click OK." buttons {"OK"} default button {"OK"} with icon POSIX file ("$(UTILITIES_PATH)/TemplateIcon.icns") with title "embedXcode"'
# Give Mac OS X enough time for enumerating the USB ports
		@sleep 3
endif

ispload:	$(TARGET_HEX)
		@echo "---- ISP upload ---- "
ifeq ($(UPLOADER),avrdude)
		$(call SHOW,"10.15-UPLOAD",$(UPLOADER))

		$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e \
			-U lock:w:$(ISP_LOCK_FUSE_PRE):m \
			-U hfuse:w:$(ISP_HIGH_FUSE):m \
			-U lfuse:w:$(ISP_LOW_FUSE):m \
			-U efuse:w:$(ISP_EXT_FUSE):m
		$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -D \
			-U flash:w:$(TARGET_HEX):i
		$(AVRDUDE_EXEC) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) \
			-U lock:w:$(ISP_LOCK_FUSE_POST):m
endif


# ~
serial_option:		reset
ifneq ($(NO_SERIAL_CONSOLE),1)
    ifeq ($(BOARD_PORT),ssh)
      ifeq ($(BOARD_TAG),yun)
		$(call SHOW,"11.1-SERIAL",$(UPLOADER))

		osascript -e 'tell application "Terminal" to do script "$(UTILITIES_PATH_SPACE)/sshpass -p $(SSH_PASSWORD) ssh root@$(SSH_ADDRESS) exec telnet localhost 6571"'
      endif
    else ifeq ($(AVRDUDE_NO_SERIAL_PORT),1)
		@echo "The programmer provides no serial port"

    else ifeq ($(UPLOADER),teensy_flash)
		$(call SHOW,"11.2-SERIAL",$(UPLOADER))

		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $$(ls $(BOARD_PORT)) $(SERIAL_BAUDRATE)"'

    else ifeq ($(UPLOADER),lightblue_loader)
		$(call SHOW,"11.3-SERIAL",$(UPLOADER))

		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $$(ls $(BOARD_PORT)) $(SERIAL_BAUDRATE)"'

    else ifneq ($(USED_SERIAL_PORT),)
		$(call SHOW,"11.4-SERIAL",$(UPLOADER))

		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $(USED_SERIAL_PORT) $(SERIAL_BAUDRATE)"' -e 'tell application "Terminal" to activate'
    else
		@echo "No serial port available"
    endif
endif
# ~~


serial:		reset
		@echo "---- Serial ---- "
# ~
ifeq ($(BOARD_PORT),ssh)
    ifeq ($(BOARD_TAG),yun)
		osascript -e 'tell application "Terminal" to do script "$(UTILITIES_PATH_SPACE)/sshpass -p $(SSH_PASSWORD) ssh root@$(SSH_ADDRESS) exec telnet localhost 6571"'
    endif
# ~~

else ifeq ($(AVRDUDE_NO_SERIAL_PORT),1)
		@echo "The programmer provides no serial port"

else ifeq ($(UPLOADER),teensy_flash)
		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $$(ls $(BOARD_PORT)) $(SERIAL_BAUDRATE)"'

else ifeq ($(UPLOADER),lightblue_loader)
		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $$(ls $(BOARD_PORT)) $(SERIAL_BAUDRATE)"'

else
		osascript -e 'tell application "Terminal" to do script "$(SERIAL_COMMAND) $(USED_SERIAL_PORT) $(SERIAL_BAUDRATE)"'  -e 'tell application "Terminal" to activate'
endif


size:
		@echo '---- Size ----'
		@echo 'Estimated Flash: ' $(shell $(FLASH_SIZE)) $(MAX_FLASH_BYTES); echo;
		@echo 'Estimated SRAM:  ' $(shell $(RAM_SIZE)) $(MAX_RAM_BYTES); echo;
		@echo 'Elapsed time:    ' $(STOPCHRONO)
#		@if [ -f $(TARGET_HEX) ]; then echo 'Binary sketch size:  ' $(shell $(FLASH_SIZE)) $(MAX_FLASH_BYTES); echo; fi
#		@if [ -f $(TARGET_BIN) ]; then echo 'Binary sketch size:  ' $(shell $(FLASH_SIZE)) $(MAX_FLASH_BYTES); echo; fi
#		@if [ -f $(TARGET_DOT) ]; then echo 'Binary sketch size:  ' $(shell $(FLASH_SIZE)) $(MAX_FLASH_BYTES); echo; fi
#		@if [ -f $(TARGET_ELF) ]; then echo 'Estimated SRAM used: ' $(shell $(RAM_SIZE)) $(MAX_RAM_BYTES); echo; fi
#		@if [ -f $(TARGET_OUT) ]; then echo 'Binary sketch size:  ' $(shell $(FLASH_SIZE)) $(MAX_FLASH_BYTES); echo; fi
#		@if [ -f $(TARGET_OUT) ]; then echo 'Estimated SRAM used: ' $(shell $(RAM_SIZE)) $(MAX_RAM_BYTES); echo; fi

clean:
		@if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
		@echo "nil" > $(OBJDIR)/nil
		@echo "---- Clean ----"
		-@rm -r $(OBJDIR)/* # */

changed:
		@echo "---- Clean changed ----"
ifeq ($(CHANGE_FLAG),1)
		@if [ ! -d $(OBJDIR) ]; then mkdir $(OBJDIR); fi
		@echo "nil" > $(OBJDIR)/nil
		@$(REMOVE) $(OBJDIR)/* # */
		@echo "Remove all"
else
#		$(REMOVE) $(LOCAL_OBJS)
		@for f in $(LOCAL_OBJS); do if [ -f $$f ]; then rm $$f; fi; done
		@echo "Remove local only"
		@if [ -f $(OBJDIR)/$(TARGET).elf ] ; then rm $(OBJDIR)/$(TARGET).* ; fi ;
endif

depends:	$(DEPS)
		@echo "---- Depends ---- "
		@cat $(DEPS) > $(DEP_FILE)

boards:
		@echo "==== Boards ===="
		@ls -1 Configurations/ | sed 's/\(.*\)\..*/\1/'
		@echo "==== Boards done ==== "

message_all:
		@echo "==== All ===="

message_build:
		@echo "==== Build ===="

message_compile:
		@echo "---- Compile ----"

message_upload:
		@echo "==== Upload ===="

end_all:
		@echo "==== All done ==== "

end_build:
		@echo "==== Build done ==== "

# ~
fast: 		info message_fast changed compile reset raw_upload serial_option end_fast prepare

make:		info message_make changed compile end_make prepare

message_fast:
		@echo "==== Fast ===="

message_make:
		@echo "==== Make ===="

end_make:
		@echo "==== Make done ==== "

end_fast:
		@echo "==== Fast done ==== "
# ~~

.PHONY:	all clean depends upload raw_upload reset serial show_boards headers size document


