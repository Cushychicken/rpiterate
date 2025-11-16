# rpiterate

A Buildroot-based kickstarter for Raspberry Pi projects, eliminating the need to set up base OS and software update services for each new testbed.

## Quickstart

```bash
# Clone and initialize
git clone <repository-url> rpiterate
cd rpiterate
git submodule update --init --recursive

# Configure and build
cd buildroot
make BR2_EXTERNAL=../br-external rptr8_rpi4_defconfig
make

# Output files
# - buildroot/output/images/sdcard.img
# - buildroot/output/images/*.swu
```

## Project Description

This repository provides a pre-configured Buildroot environment for Raspberry Pi 4, including:

- Base OS configuration optimized for Raspberry Pi 4
- SWUpdate integration for over-the-air updates
- External package structure for application development
- Automated generation of SD card images and SWU update files

## Project Structure

```
rpiterate/
├── br-external/          # Buildroot external tree
│   ├── configs/          # Defconfig files
│   │   └── rptr8_rpi4_defconfig
│   ├── packages/         # External packages
│   ├── Config.in         # External package menu
│   └── external.mk       # External makefile
└── buildroot/            # Buildroot submodule
```

The repository uses Buildroot's out-of-tree external mechanism. All custom configuration and packages are contained in `br-external`, while Buildroot itself is maintained as a git submodule.

## Prerequisites

- Linux build environment
- Standard build tools (gcc, make, etc.)
- Git
- Python 3 (for Buildroot)

## Software Updates

### SD Card Update (Full Image)

#### Using dd

```bash
# Identify SD card device (e.g., /dev/sdb)
lsblk

# Write image to SD card
sudo dd if=buildroot/output/images/sdcard.img of=/dev/sdb bs=4M status=progress conv=fsync
```

#### Using BalenaEtcher

1. Download and install [BalenaEtcher](https://www.balena.io/etcher/)
2. Launch BalenaEtcher
3. Click "Flash from file" and select `buildroot/output/images/sdcard.img`
4. Select your SD card device
5. Click "Flash!"

### Over-the-Air Update (Web Interface)

1. Boot the Raspberry Pi with the generated image
2. Access the SWUpdate web interface at `http://<pi-ip-address>:8080`
3. Navigate to the update page
4. Upload the `.swu` file from `buildroot/output/images/`
5. Follow the on-screen instructions to complete the update

The SWUpdate service runs automatically on boot and provides a web interface for uploading and applying software updates without requiring physical access to the device.

## External Packages

Application layer programs are implemented as external packages in `br-external/packages/`. Each package follows the standard Buildroot package structure:

- `Config.in` - Package configuration menu
- `<package>.mk` - Package build and install rules

To add a new package:

1. Create package directory: `br-external/packages/myapp/`
2. Create `Config.in` with package configuration
3. Create `myapp.mk` with build/install rules
4. Add `source "$BR2_EXTERNAL_RPTR8_PATH/package/myapp/Config.in"` to `br-external/packages/Config.in`
5. Rebuild: `cd buildroot && make menuconfig` (enable package) && `make`

## Configuration

The base configuration (`rptr8_rpi4_defconfig`) is derived from Buildroot's `raspberrypi4_defconfig` with the following additions:

- SWUpdate package enabled
- SWUpdate web interface enabled
- Automatic SWU file generation

To customize the configuration:

```bash
cd buildroot
make BR2_EXTERNAL=../br-external menuconfig
make savedefconfig BR2_DEFCONFIG=../br-external/configs/rptr8_rpi4_defconfig
```

