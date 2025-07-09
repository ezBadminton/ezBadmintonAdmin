cd ezbadminton-infoscreen
dpkg-buildpackage --build=any --target-arch=amd64 -us -uc
dh_clean
