ezbadminton:

install: ezbadminton
	mkdir -p $(DESTDIR)/opt/ezbadminton/bin/local_server
	cp -r ../../../build/linux/x64/release/bundle/* $(DESTDIR)/opt/ezbadminton/bin
	cp ../../../../server/ezBadmintonServer-linux-amd64* $(DESTDIR)/opt/ezbadminton/bin/local_server/ezBadmintonServer
	mv $(DESTDIR)/opt/ezbadminton/bin/ez_badminton_admin_app $(DESTDIR)/opt/ezbadminton/bin/ezbadminton
	chown -R $(USER): $(DESTDIR)/opt/ezbadminton/bin
	chmod 0755 $(DESTDIR)/opt/ezbadminton/bin/local_server/ezBadmintonServer
	chmod 0755 $(DESTDIR)/opt/ezbadminton/bin/ezbadminton