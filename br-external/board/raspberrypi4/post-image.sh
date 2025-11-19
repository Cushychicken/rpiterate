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
	
	# Compress rootfs image to reduce .swu file size
	echo "Compressing rootfs image..."
	if command -v gzip >/dev/null 2>&1; then
		gzip -c "${BINARIES_DIR}/rootfs.ext2" > "${SWU_TMP}/rootfs.ext2.gz"
		ROOTFS_FILE="rootfs.ext2.gz"
		ROOTFS_COMPRESSED=true
	else
		cp "${BINARIES_DIR}/rootfs.ext2" "${SWU_TMP}/"
		ROOTFS_FILE="rootfs.ext2"
		ROOTFS_COMPRESSED=false
	fi
	
	# Copy sw-description
	if [ -f "${BOARD_DIR}/sw-description" ]; then
		cp "${BOARD_DIR}/sw-description" "${SWU_TMP}/"
	else
		echo "Error: sw-description not found at ${BOARD_DIR}/sw-description"
		exit 1
	fi
	
	# Generate .swu file using cpio (swupdate .swu files are CPIO archives)
	# sw-description must be first in the archive
	cd "${SWU_TMP}"
	
	# Create file list ensuring sw-description is first
	FILE_LIST=$(mktemp)
	echo "./sw-description" > "${FILE_LIST}"
	find . -type f ! -name "sw-description" -print | LC_ALL=C sort >> "${FILE_LIST}"
	
	# Update sw-description to reflect compressed filename if needed
	if [ "${ROOTFS_COMPRESSED}" = "true" ]; then
		sed -i 's/"filename": "rootfs\.ext2"/"filename": "rootfs.ext2.gz"/' "${SWU_TMP}/sw-description"
		sed -i 's/"compressed": false/"compressed": true/' "${SWU_TMP}/sw-description"
	fi
	
	# Create CPIO archive in newc format
	cat "${FILE_LIST}" | cpio -o -H newc > "${BINARIES_DIR}/rptr8-rpi4.swu" 2>&1
	CPIO_EXIT=$?
	rm -f "${FILE_LIST}"
	
	# Verify the archive was created successfully
	if [ ${CPIO_EXIT} -eq 0 ] && [ -f "${BINARIES_DIR}/rptr8-rpi4.swu" ] && [ -s "${BINARIES_DIR}/rptr8-rpi4.swu" ]; then
		echo "SWU file generated: ${BINARIES_DIR}/rptr8-rpi4.swu"
	else
		echo "Error: Failed to generate SWU file (exit code: ${CPIO_EXIT})"
		exit 1
	fi
else
	echo "Warning: rootfs.ext2 not found, skipping SWU generation"
fi

exit 0

