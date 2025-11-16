################################################################################
#
# helloworld-example
#
################################################################################

HELLOWORLD_EXAMPLE_VERSION = main
HELLOWORLD_EXAMPLE_SITE = https://github.com/Cushychicken/helloworld-example.git
HELLOWORLD_EXAMPLE_SITE_METHOD = git
HELLOWORLD_EXAMPLE_LICENSE = Unknown
HELLOWORLD_EXAMPLE_LICENSE_FILES = README.md

define HELLOWORLD_EXAMPLE_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)
endef

define HELLOWORLD_EXAMPLE_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/hello $(TARGET_DIR)/usr/bin/hello
endef

$(eval $(generic-package))

