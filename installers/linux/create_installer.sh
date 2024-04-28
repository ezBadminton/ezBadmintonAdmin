cd ezbadminton
dpkg-buildpackage --build=any --target-arch=amd64 -us -uc
dh_clean