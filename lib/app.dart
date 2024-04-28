import 'dart:io';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:collection_repository/collection_repository.dart';
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

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final PocketBaseProvider _pocketBaseProvider;
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final CollectionRepository<Tournament> _tournamentRepository;
  late final CollectionRepository<PlayingLevel> _playingLevelRepository;
  late final CollectionRepository<AgeGroup> _ageGroupRepository;
  late final CollectionRepository<Player> _playerRepository;
  late final CollectionRepository<Gymnasium> _gymnasiumRepository;
  late final CollectionRepository<Court> _courtRepository;
  late final CollectionRepository<MatchSet> _matchSetRepository;
  late final CollectionRepository<MatchData> _matchDataRepository;
  late final CollectionRepository<TieBreaker> _tieBreakerRepository;
  late final CollectionRepository<Competition> _competitionRepository;
  late final CollectionRepository<Team> _teamRepository;
  late final CollectionRepository<Club> _clubRepository;
  late final CollectionRepository<TournamentModeSettings>
      _tournamentModeSettingsRepository;

  @override
  void initState() {
    super.initState();

    runLocalSever();

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

    _tournamentRepository = PocketbaseCollectionRepository(
      modelConstructor: Tournament.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _playingLevelRepository = PocketbaseCollectionRepository(
      modelConstructor: PlayingLevel.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _ageGroupRepository = PocketbaseCollectionRepository(
      modelConstructor: AgeGroup.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _playerRepository = PocketbaseCollectionRepository(
      modelConstructor: Player.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _teamRepository = PocketbaseCollectionRepository(
      modelConstructor: Team.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _gymnasiumRepository = PocketbaseCollectionRepository(
      modelConstructor: Gymnasium.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _courtRepository = PocketbaseCollectionRepository(
      modelConstructor: Court.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _matchSetRepository = PocketbaseCollectionRepository(
      modelConstructor: MatchSet.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _matchDataRepository = PocketbaseCollectionRepository(
      modelConstructor: MatchData.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _tieBreakerRepository = PocketbaseCollectionRepository(
      modelConstructor: TieBreaker.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _competitionRepository = PocketbaseCollectionRepository(
      modelConstructor: Competition.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _clubRepository = PocketbaseCollectionRepository(
      modelConstructor: Club.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
    _tournamentModeSettingsRepository = PocketbaseCollectionRepository(
      modelConstructor: TournamentModeSettings.fromJson,
      pocketBaseProvider: _pocketBaseProvider,
    );
  }

  void loadCollections() {
    _tournamentRepository.load();
    _playingLevelRepository.load();
    _ageGroupRepository.load();
    _playerRepository.load();
    _gymnasiumRepository.load();
    _courtRepository.load();
    _matchSetRepository.load();
    _matchDataRepository.load();
    _tieBreakerRepository.load();
    _competitionRepository.load();
    _teamRepository.load();
    _clubRepository.load();
    _tournamentModeSettingsRepository.load();
  }

  void runLocalSever() async {
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

    if (!await serverWorkingDir.exists()) {
      return;
    }

    String localDataDirName = 'local_database';
    Directory documentDir = await getApplicationDocumentsDirectory();

    Directory localDataDir = Directory(
      "${documentDir.path}${Platform.pathSeparator}ez_badminton${Platform.pathSeparator}$localDataDirName",
    );

    Process.start(
      './ezBadmintonServer',
      ['serve', '--dir', localDataDir.path],
      workingDirectory: serverWorkingDir.path,
      mode: ProcessStartMode.normal,
    ).then((process) {
      stdout.addStream(process.stdout);
      stderr.addStream(process.stderr);
    });
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    _tournamentRepository.dispose();
    _playingLevelRepository.dispose();
    _ageGroupRepository.dispose();
    _playerRepository.dispose();
    _teamRepository.dispose();
    _gymnasiumRepository.dispose();
    _courtRepository.dispose();
    _matchSetRepository.dispose();
    _matchDataRepository.dispose();
    _tieBreakerRepository.dispose();
    _competitionRepository.dispose();
    _clubRepository.dispose();
    _tournamentModeSettingsRepository.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authenticationRepository),
        RepositoryProvider.value(value: _tournamentRepository),
        RepositoryProvider.value(value: _playingLevelRepository),
        RepositoryProvider.value(value: _ageGroupRepository),
        RepositoryProvider.value(value: _playerRepository),
        RepositoryProvider.value(value: _teamRepository),
        RepositoryProvider.value(value: _gymnasiumRepository),
        RepositoryProvider.value(value: _courtRepository),
        RepositoryProvider.value(value: _matchSetRepository),
        RepositoryProvider.value(value: _matchDataRepository),
        RepositoryProvider.value(value: _tieBreakerRepository),
        RepositoryProvider.value(value: _competitionRepository),
        RepositoryProvider.value(value: _clubRepository),
        RepositoryProvider.value(value: _tournamentModeSettingsRepository),
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
            loadCollections();
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
