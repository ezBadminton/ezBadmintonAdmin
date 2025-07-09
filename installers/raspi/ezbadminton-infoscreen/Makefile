ezbadminton-infoscreen:

install: ezbadminton-infoscreen
	git clone --recursive https://github.com/ardera/flutter-pi $(DESTDIR)/tmp/flutter-pi
	mkdir -p $(DESTDIR)/opt/ezbadminton-infoscreen/bin
	cp -r ../../../build/flutter_assets/* $(DESTDIR)/opt/ezbadminton-infoscreen/bin
	cp ../run.sh $(DESTDIR)/opt/ezbadminton-infoscreen/bin/ezbadminton-infoscreen
	chown -R $(USER): $(DESTDIR)/opt/ezbadminton-infoscreen/bin
	chmod 0775 $(DESTDIR)/opt/ezbadminton-infoscreen/bin/ezbadminton-infoscreen
