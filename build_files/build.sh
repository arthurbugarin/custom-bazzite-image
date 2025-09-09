#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux 


# install rtw89 driver
dnf5 install -y dkms
dnf5 install -y kernel-devel
dnf5 install -y gcc
dnf5 install -y make
dnf5 install -y git

git clone https://github.com/morrownr/rtw89 /tmp/rtw89
cd /tmp/rtw89
dkms install $PWD \
  --kernelsourcedir /usr/src/kernels/6.16.4-107.bazzite.fc42.x86_64 \
  -k 6.16.4-107.bazzite.fc42.x86_64
#make clean modules
#make install
make install_fw
cp -v rtw89.conf /etc/modprobe.d/
if mokutil --sb-state >/dev/null 2>&1; then
    echo "Secure Boot detected, trying to import MOK key..."
    mokutil --import /var/lib/dkms/mok.pub || echo "Failed to import MOK key (probably expected in container)"
else
    echo "Skipping MOK import: no EFI support (container build)"
fi


# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
