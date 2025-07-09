ezbadminton-infoscreen:

install: ezbadminton-infoscreen
	mkdir -p $(DESTDIR)/opt/ezbadminton-infoscreen/bin
	cp -r ../../../build/linux/x64/release/bundle/* $(DESTDIR)/opt/ezbadminton-infoscreen/bin
	mv $(DESTDIR)/opt/ezbadminton-infoscreen/bin/ez_badminton_admin_app $(DESTDIR)/opt/ezbadminton-infoscreen/bin/ezbadminton-infoscreen
	chown -R $(USER): $(DESTDIR)/opt/ezbadminton-infoscreen/bin
	chmod 0755 $(DESTDIR)/opt/ezbadminton-infoscreen/bin/ezbadminton-infoscreen
