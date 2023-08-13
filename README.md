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

### Set up Pocketbase locally

ezBadminton uses [Pocketbase](https://pocketbase.io) as its backend. It bundles database, data storage, authentication and REST-API.

- Download the newest prebuilt archive for your platform from https://pocketbase.io/docs (0.17.4 as of writing).
- Create a directory called `pocketbase` in your working directory and unpack the archive's contents there.
- Start the service
    ```console
    you@yourdevice:~/ez_badminton/pocketbase$ ./pocketbase serve
    ```
    It will create the `pb_data` directory.
- Stop the service (`Ctrl+C`)
- Set up your admin access
    ```console
	you@yourdevice:~/ez_badminton/pocketbase$ ./pocketbase admin create test@example.com your-password
    ```
	> **_NOTE:_** You can use a fake mail but don't forget your password ^^.
- Start the service again
    ```console
	you@yourdevice:~/ez_badminton/pocketbase$ ./pocketbase serve
    ```
- Open the [pocketbase admin UI](http://127.0.0.1:8090/_/) in your browser and log in
- Open the [pocketbase settings](http://127.0.0.1:8090/_/#/settings/import-collections) and import the ezBadminton database schema from [pb_schema.json](https://gist.githubusercontent.com/Snonky/1a596069391fb06eb3d916934e8c140b/raw/pb_schema.json).
  - You should be able to see the collection tables on the [pocketbase home page](http://127.0.0.1:8090/_/) now
- Select the 'tournament_organizer' user-collection and create a test-user for yourself
    - Click 'New Record', fill out the form and click 'Create'
- Select the 'tournaments' collection and create a tournament
    - Click 'New Record', give it a title and click 'Create'
- The backend is ready! On to the app itself.

### Building the app

The ezBadminton Admin App is a desktop app built with [Flutter](flutter.dev).

- [Install](https://docs.flutter.dev/get-started/install) the Flutter development tools on your system (Flutter 3.10.6 as of writing)
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
- Press `F5` to build and run a debug session! This takes about 2-3 minutes on the first run. Make sure your pocketbase service is still running.
	If the hotkey does not work, try
    ```console
	you@yourdevice:~/ez_badminton/ezBadmintonAdmin$ flutter run --debug
    ```
**You are ready to hack!**

<!-- Githook:  git config --local core.hooksPath .githooks/ -->
