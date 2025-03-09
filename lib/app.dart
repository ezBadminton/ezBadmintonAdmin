import 'dart:ffi';
import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/utils/test_environment.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/authentication/bloc/authentication_bloc.dart';
import 'package:ez_badminton_admin_app/home/view/home_page.dart';
import 'package:ez_badminton_admin_app/login/view/login_page.dart';
import 'package:ez_badminton_admin_app/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';
import 'package:user_repository/user_repository.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final PocketBaseProvider _pocketBaseProvider;
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final ModelRepository _modelRepository;

  @override
  void initState() {
    super.initState();

    _runLocalSever();

    String pocketbaseUrl = TestEnvironment().isTest
        ? 'http://127.0.0.1:8096'
        : 'http://127.0.0.1:8090';

    _pocketBaseProvider = PocketBaseProvider(pocketbaseUrl);
    _authenticationRepository = AuthenticationRepository(
      pocketBaseProvider: _pocketBaseProvider,
    );
    _userRepository = UserRepository(
      pocketBaseProvider: _pocketBaseProvider,
    );
    _modelRepository = PocketbaseModelRepository(
      pocketbaseProvider: _pocketBaseProvider,
    );
  }

  void _runLocalSever() async {
    if (TestEnvironment().isTest) {
      // Tests run their own server
      return;
    }

    String serverDirName = 'local_server';

    Directory cwd;

    if (kReleaseMode) {
      cwd = File(Platform.resolvedExecutable).parent;
    } else {
      cwd = Directory.current;
    }

    Directory serverWorkingDir = Directory(
      "${cwd.path}${Platform.pathSeparator}$serverDirName",
    );

    String exeFileExtension = Platform.isWindows ? '.exe' : '';
    File serverExe = File(
      '${serverWorkingDir.path}${Platform.pathSeparator}ezBadmintonServer$exeFileExtension',
    );

    if (!await serverExe.exists()) {
      return;
    }

    _createClientHeartbeat();

    String localDataDirName = 'local_database';
    Directory documentDir = await getApplicationDocumentsDirectory();

    Directory localDataDir = Directory(
      "${documentDir.path}${Platform.pathSeparator}ez_badminton${Platform.pathSeparator}$localDataDirName",
    );

    Process.start(
      serverExe.absolute.path,
      [
        'serve',
        '--dir',
        localDataDir.path,
        '--client-exit',
      ],
      workingDirectory: serverWorkingDir.path,
      mode: ProcessStartMode.normal,
    ).then((process) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);
    });
  }

  void _createClientHeartbeat() {
    if (Platform.isWindows) {
      CreateNamedPipe(
        "\\\\.\\pipe\\ezbadmintonheartbeat".toNativeUtf16(),
        0x00000003,
        0x00000000,
        1,
        1,
        1,
        0,
        Pointer.fromAddress(0),
      );
    }

    // On linux the prctl syscall can notfify the child process when the parent
    // process dies. Therefore no active heartbeat is needed.
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(
          value: _modelRepository.findStore<TournamentEvent>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<PlayingLevel>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<AgeGroup>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Player>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Team>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Gymnasium>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Court>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<MatchSet>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<TournamentMatch>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<TieBreaker>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Competition>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Club>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<TournamentModeSettings>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Registration>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<Schedule>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<ScheduledRound>(),
        ),
        RepositoryProvider.value(
          value: _modelRepository.findStore<ScheduledMatch>(),
        ),
        RepositoryProvider.value(
          value: WithdrawalPreviewEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: PlayerStatusEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: AssignCourtEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: UnassignCourtEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: MakeDrawEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: SwapDrawEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: RedrawEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: SetSeedsEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: DeleteDrawEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: StartMatchEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: CancelMatchEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: SetScoreEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: ResetMatchEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: RegisterTeamEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: UpdateTeamEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: AddTieBreakerEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: UpdateTieBreakerEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: TournamentStartEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: TournamentStopEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: CompetitionDeleteEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
        RepositoryProvider.value(
          value: PlayingLevelReorderEndpoint(
            pocketBase: _pocketBaseProvider.pocketBase,
            modelRepository: _modelRepository,
          ),
        ),
      ],
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
            authenticationRepository: _authenticationRepository,
            userRepository: _userRepository),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previous, current) =>
              current.status == AuthenticationStatus.authenticated &&
              previous.status != AuthenticationStatus.authenticated,
          listener: (context, state) {
            _modelRepository.loadModels();
          },
          child: const AppView(),
        ),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ez Badminton Admin',
      navigatorKey: _navigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: false),
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (_, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomePage.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unknown:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
