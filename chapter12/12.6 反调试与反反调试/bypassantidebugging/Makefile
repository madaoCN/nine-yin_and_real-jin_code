THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = bypassantidebugging
bypassantidebugging_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 antidebugging"
