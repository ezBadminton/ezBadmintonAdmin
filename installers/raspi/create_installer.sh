cd ezbadminton-infoscreen
dpkg-buildpackage -a arm64 --target-arch=arm64 -b -us -uc
dh_clean
