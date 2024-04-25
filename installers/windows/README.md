# ezBadminton Windows msi installer

This directory contains XML files in the [WiX toolset](https://wixtoolset.org/) schema. They build into an msi installer that installs the ezBadminton windows client.

## Building

### Setup

The build uses MSBuild via Visual Studio 2022.

* Install the [HeatWave](https://marketplace.visualstudio.com/items?itemName=FireGiant.FireGiantHeatWaveDev17) extension
* Open the `windows.sln` solution  in VS2022


### Provide the file cabinet

The files in the cabinet are embedded in the installer during its build.

* Build the client (run `flutter build windows` in this repository's root directory).
* Find the build result at `[...]\ez_badminton_admin_app\build\windows\x64\runner\Release`
* Copy the files to the `cabinet` directory
    * It should look something like this
    ```
    ez_badminton_admin_app\installers\windows\cabinet
        - data
        - ez_badminton_admin_app.exe
        - flutter_windows.dll
        - ...
    ```
* Rename `ez_badminton_admin_app.exe` to `ezBadminton.exe`
* Download the ezBadminton server executable from the [releases](https://github.com/ezBadminton/ezBadmintonServer/releases)
    * Take the windows-amd64 one
* Create a directory called `local_server` in the `cabinet` directory
* Move the server executable to `local_server`
* Rename the server executable to `ezBadmintonServer.exe`

### Build the installer

* In VS2022, press `Ctrl+Shift+B` to start the build
* The result is a `ezBadminton-installer-windows.msi` installer file

## Versioning

To change the version number, open the `Package.wxs` file and find the version attribute of the Package XML tag.