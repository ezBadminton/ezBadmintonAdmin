# ezBadminton linux .deb installer

This directory contains a Makefile for building a debian package (`.deb` file) that installs the ezBadminton linux client.

## Building

### Setup

* Install the `build-essential` and `debhelper` packages.
    ```console
    sudo apt install build-essential debhelper
    ```

### Provide the payload files

The files that are embedded in the installer are copied from different locations during the build. The paths are defined relative to this (`installers/linux`) directory.

* Build the client (run `flutter build linux` in this repository's root directory).
* Verify that the build result is at `ez_badminton_admin_app\build\linux\x64\release\bundle`
* It should look something like this
```
ez_badminton_admin_app\build\linux\x64\release\bundle
    - data
    - lib
    - ez_badminton_admin_app
```
* The installer build will automatically take the files from here

---

The client can run locally and has the ability to start a local server on its own. Therefore the server executable has to be included with the installer.

* Build the server or download the linux-amd64 one from the server repository's [releases](https://github.com/ezBadminton/ezBadmintonServer/releases)
* Place it in a directory named `server` one level above the repository
    * Like this: `ez_badminton_admin_app\..\server\ezBadmintonServer-linux-amd64-vX.Y.Z.exe`
* The installer build will copy it from there


### Build the installer

In the `installers/linux` directory run
```console
./create_installer.sh
```

The result will be a `ezbadminton_x.y.z_amd64.deb` package file.

### Using the installer

ezBadminton can then be installed by calling
```
sudo apt install ./ezbadminton_x.y.z_amd64.deb
```

After the installation you should be able open it with
```console
you@yourdevice:~$ ezbadminton
```




## Versioning

To change the version, open the `installers/linux/ezbadminton/debian/changelog` file and add a new entry with an incremented version number.