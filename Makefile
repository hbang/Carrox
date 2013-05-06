TARGET = :clang

include theos/makefiles/common.mk

BUNDLE_NAME = Carrox
Carrox_FILES = HBCAFolderView.x
Carrox_INSTALL_PATH = /Library/Velox/Plugins/
Carrox_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "spring"
