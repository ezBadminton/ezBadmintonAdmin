# ezBadminton Windows msi installer

This directory contains XML files in the [WiX toolset](https://wixtoolset.org/) schema. They build into an msi installer that installs the ezBadminton windows client.

## Building

### Setup

The build uses MSBuild via Visual Studio 2022.

* Install the [HeatWave](https://marketplace.visualstudio.com/items?itemName=FireGiant.FireGiantHeatWaveDev17) extension
* Open the `windows.sln` solution  in VS2022


### Provide the payload files

The files that are embedded in the installer are "harvested" from different locations during the build. The paths are defined relative to this (`installers/windows`) directory.

* Build the client (run `flutter build windows` in this repository's root directory).
* Verify that the build result is at `ez_badminton_admin_app\build\windows\x64\runner\Release`
* It should look something like this
```
ez_badminton_admin_app\build\windows\x64\runner\Release
    - data
    - ez_badminton_admin_app.exe
    - flutter_windows.dll
    - ...
```
* The installer build will automatically take the files from here

---

The client can run locally and has the ability to start a local server on its own. Therefore the server executable has to be included with the installer.

* Build the server or download the windows-amd64 one from the server repository's [releases](https://github.com/ezBadminton/ezBadmintonServer/releases)
* Place it in a directory named `server` one level above the repository
    * Like this: `ez_badminton_admin_app\..\server\ezBadmintonServer-windows-amd64-vX.Y.Z.exe`
* The installer build will harvest it from there


### Build the installer

* In VS2022, press `Ctrl+Shift+B` to start the build
* The result is a `ezBadminton-installer-windows.msi` installer file

## Versioning

To change the version number, open the `Package.wxs` file and find the version attribute of the Package XML tag.