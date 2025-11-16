#!/bin/bash

set -e

BOARD_DIR="$(dirname $0)"
BINARIES_DIR="$1"

# Generate .swu file if rootfs.ext2 exists
# The .swu file is for OTA updates and only needs the rootfs, not the full SD card image
if [ -f "${BINARIES_DIR}/rootfs.ext2" ]; then
	echo "Generating SWU update file..."
	
	# Create temporary directory for swupdate files
	SWU_TMP=$(mktemp -d)
	trap "rm -rf ${SWU_TMP}" EXIT
	
	# Copy rootfs image
	cp "${BINARIES_DIR}/rootfs.ext2" "${SWU_TMP}/"
	
	# Copy sw-description
	if [ -f "${BOARD_DIR}/sw-description" ]; then
		cp "${BOARD_DIR}/sw-description" "${SWU_TMP}/"
	else
		echo "Error: sw-description not found at ${BOARD_DIR}/sw-description"
		exit 1
	fi
	
	# Create empty preinst/postinst scripts if they don't exist
	[ -f "${BOARD_DIR}/preinst" ] || touch "${SWU_TMP}/preinst"
	[ -f "${BOARD_DIR}/postinst" ] || touch "${SWU_TMP}/postinst"
	chmod +x "${SWU_TMP}/preinst" "${SWU_TMP}/postinst"
	
	# Generate .swu file using cpio (swupdate .swu files are CPIO archives)
	cd "${SWU_TMP}"
	if find . -type f | cpio -o -H newc > "${BINARIES_DIR}/rptr8-rpi4.swu" 2>/dev/null; then
		echo "SWU file generated: ${BINARIES_DIR}/rptr8-rpi4.swu"
	else
		# Fallback without -H newc
		find . -type f | cpio -o > "${BINARIES_DIR}/rptr8-rpi4.swu"
		echo "SWU file generated: ${BINARIES_DIR}/rptr8-rpi4.swu"
	fi
else
	echo "Warning: rootfs.ext2 not found, skipping SWU generation"
fi

exit 0

