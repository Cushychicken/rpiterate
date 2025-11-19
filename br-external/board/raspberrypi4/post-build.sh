#!/bin/sh

set -u
set -e

# Copy custom cmdline.txt if it exists
# BINARIES_DIR is available as an environment variable in post-build scripts
if [ -f "${BR2_EXTERNAL_RPTR8_PATH}/board/raspberrypi4/cmdline.txt" ] && [ -n "${BINARIES_DIR}" ]; then
	if [ -d "${BINARIES_DIR}/rpi-firmware" ]; then
		cp "${BR2_EXTERNAL_RPTR8_PATH}/board/raspberrypi4/cmdline.txt" \
			"${BINARIES_DIR}/rpi-firmware/cmdline.txt"
	fi
fi

