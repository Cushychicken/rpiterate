################################################################################
#
# hellopython-example
#
################################################################################

HELLOPYTHON_EXAMPLE_VERSION = main
HELLOPYTHON_EXAMPLE_SITE = https://github.com/Cushychicken/hellopython-example.git
HELLOPYTHON_EXAMPLE_SITE_METHOD = git
HELLOPYTHON_EXAMPLE_LICENSE = Unknown
HELLOPYTHON_EXAMPLE_LICENSE_FILES = README.md

define HELLOPYTHON_EXAMPLE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/hello.py $(TARGET_DIR)/usr/bin/hello.py
endef

$(eval $(generic-package))

