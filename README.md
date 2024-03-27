# ezBadminton Admin App

A free open source desktop app for managing badminton tournaments.

It is currently under development. The name and everything else is subject to change.

## Why?

To make organizing fun badminton tournaments easy and free (software-wise).

**Is there no solution to that already?**

Those that I know are not free, not badminton specific or require a lot of user experience.

## Contributing

Everyone is welcome to fork and/or make pull requests!

### How to get started

> **_NOTE:_** This guide was tested using Ubuntu 22.04 and Windows 10.

- Create a working directory like `ez_badminton`
- Fork and clone this repository into the working directory
    ```console
    you@yourdevice:~/ez_badminton$ git clone [your-forked-repository]
    ```

### Set up the PocketBase server locally

ezBadminton uses a custom extended [PocketBase](https://pocketbase.io) as its backend. It bundles database, data storage, authentication and REST-API.

- Download the newest prebuilt server executable from the [releases](https://github.com/ezBadminton/ezBadmintonServer/releases).
	> **_NOTE:_** You can also compile the server yourself from the [repository](https://github.com/ezBadminton/ezBadmintonServer).
- Create a directory called `local_server` in your cloned repository (`ez_badminton/ezBadmintonAdmin`).
  - Place the server executable at `ez_badminton/ezBadmintonAdmin/local_server` and rename it to `ezBadmintonServer` (with `.exe` on Windows).
- The client automatically detects the server executable in the `local_server` directory and starts it.
- The backend is ready! On to the app itself.

### Building the app

The ezBadminton Admin App is a desktop app built with [Flutter](flutter.dev).

- [Install](https://docs.flutter.dev/get-started/install) the Flutter development tools on your system (Flutter 3.19.3 as of writing)
	- Note on Windows: Make sure to complete [this step](https://docs.flutter.dev/get-started/install/windows#additional-windows-requirements) to be able to build the flutter app for Windows
	- You can ignore Android and web related setup steps as this is not a mobile/web app

> **_NOTE:_** The rest of the guide assumes VSCode as IDE but there should be analog tools for other IDEs.

- Open VSCode and open your cloned repository (`ez_badminton/ezBadmintonAdmin`)
- Install the following extensions (search by the IDs to find the right ones)
	- Dart (Dart-Code.dart-code)
	- Flutter (Dart-Code.flutter)
- Open a Terminal (e.g. in VSCode) to install Flutter dependencies with the pub package manager
    ```console
	you@yourdevice:~/ez_badminton/ezBadmintonAdmin$ flutter pub upgrade
    ```
	Switch to `packages/collection_repository`
    ```console
	you@yourdevice:~/ez_badminton/ezBadmintonAdmin/packages/collection_repository$ dart run build_runner build
    ```
- Press `F5` to build and run a debug session! Select a desktop target device. This takes about 2-3 minutes on the first run. Make sure your pocketbase service is still running.
	If the hotkey does not work, try
    ```console
	you@yourdevice:~/ez_badminton/ezBadmintonAdmin$ flutter run --debug
    ```
**You are ready to hack!**

<!-- Githook:  git config --local core.hooksPath .githooks/ -->
