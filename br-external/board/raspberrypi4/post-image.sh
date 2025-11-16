#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BINARIES_DIR="$1"

# Generate .swu file if swupdate is enabled and sdcard.img exists
# (The buildroot post-image script is called first to generate sdcard.img)
if [ -f "${BINARIES_DIR}/sdcard.img" ] && [ -f "${HOST_DIR}/bin/swupdate" ]; then
	echo "Generating SWU update file..."
	
	# Create temporary directory for swupdate files
	SWU_TMP=$(mktemp -d)
	trap "rm -rf ${SWU_TMP}" EXIT
	
	# Copy rootfs image
	if [ -f "${BINARIES_DIR}/rootfs.ext2" ]; then
		cp "${BINARIES_DIR}/rootfs.ext2" "${SWU_TMP}/"
	fi
	
	# Copy sw-description
	cp "${BOARD_DIR}/sw-description" "${SWU_TMP}/"
	
	# Create empty preinst/postinst scripts if they don't exist
	[ -f "${BOARD_DIR}/preinst" ] || touch "${SWU_TMP}/preinst"
	[ -f "${BOARD_DIR}/postinst" ] || touch "${SWU_TMP}/postinst"
	chmod +x "${SWU_TMP}/preinst" "${SWU_TMP}/postinst"
	
	# Generate .swu file using cpio (swupdate .swu files are CPIO archives)
	cd "${SWU_TMP}"
	find . -type f | cpio -o -H newc > "${BINARIES_DIR}/rptr8-rpi4.swu" 2>/dev/null || \
		find . -type f | cpio -o > "${BINARIES_DIR}/rptr8-rpi4.swu"
	
	echo "SWU file generated: ${BINARIES_DIR}/rptr8-rpi4.swu"
fi

exit 0

