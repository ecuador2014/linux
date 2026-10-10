ROS2_RUNTIME_VERSION = local
ROS2_RUNTIME_SITE =
ROS2_RUNTIME_LICENSE = Apache-2.0
ROS2_RUNTIME_DEPENDENCIES = python3 host-tar

define ROS2_RUNTIME_EXTRACT_CMDS
	@test -f $(call qstrip,$(BR2_PACKAGE_ROS2_RUNTIME_TARBALL)) || \
		{ echo "Falta el tarball de ROS 2: ejecuta ros2/cross-build.sh"; exit 1; }
endef

define ROS2_RUNTIME_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/opt/ros
	$(TAR) -xzf $(call qstrip,$(BR2_PACKAGE_ROS2_RUNTIME_TARBALL)) -C $(TARGET_DIR)/opt/ros
endef

$(eval $(generic-package))
