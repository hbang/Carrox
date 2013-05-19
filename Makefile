TARGET = :clang
THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

BUNDLE_NAME = Carrox
Carrox_FILES = HBCAFolderView.x
Carrox_INSTALL_PATH = /Library/Velox/Plugins/
Carrox_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/bundle.mk

after-install::
	install.exec "spring"
