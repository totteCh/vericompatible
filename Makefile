ARCHS = arm64
TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = Verisure


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VeriCompatible

VeriCompatible_FILES = Tweak.x
VeriCompatible_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
