import 'package:authentication_repository/authentication_repository.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ez_badminton_admin_app/authentication/bloc/authentication_bloc.dart';
import 'package:ez_badminton_admin_app/home/view/home_page.dart';
import 'package:ez_badminton_admin_app/login/view/login_page.dart';
import 'package:ez_badminton_admin_app/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final CollectionRepository<Competition> _competitionRepository;
  late final CollectionRepository<Team> _teamRepository;
  late final CollectionRepository<Club> _clubRepository;
  late final CollectionRepository<TournamentModeSettings>
      _tournamentModeSettingsRepository;

  @override
  void initState() {
    super.initState();
    _pocketBaseProvider = PocketBaseProvider();
    _authenticationRepository = AuthenticationRepository(
      pocketBaseProvider: _pocketBaseProvider,
    );
    _userRepository = UserRepository(
      pocketBaseProvider: _pocketBaseProvider,
    );
    _tournamentRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: Tournament.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _playingLevelRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: PlayingLevel.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _ageGroupRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: AgeGroup.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _playerRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: Player.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _teamRepository = CachedCollectionRepository(
      relationRepositories: [
        _playerRepository,
      ],
      relationUpdateHandler: onTeamRelationUpdate,
      PocketbaseCollectionRepository(
        modelConstructor: Team.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _gymnasiumRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: Gymnasium.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _courtRepository = CachedCollectionRepository(
      relationRepositories: [
        _gymnasiumRepository,
      ],
      relationUpdateHandler: onCourtRelationUpdate,
      PocketbaseCollectionRepository(
        modelConstructor: Court.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _matchSetRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: MatchSet.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _matchDataRepository = CachedCollectionRepository(
      relationRepositories: [
        _courtRepository,
        _matchSetRepository,
      ],
      relationUpdateHandler: onMatchDataRelationUpdate,
      PocketbaseCollectionRepository(
        modelConstructor: MatchData.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _competitionRepository = CachedCollectionRepository(
      relationRepositories: [
        _playingLevelRepository,
        _teamRepository,
        _matchDataRepository,
      ],
      relationUpdateHandler: onCompetitionRelationUpdate,
      PocketbaseCollectionRepository(
        modelConstructor: Competition.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _clubRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: Club.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
    _tournamentModeSettingsRepository = CachedCollectionRepository(
      PocketbaseCollectionRepository(
        modelConstructor: TournamentModeSettings.fromJson,
        pocketBaseProvider: _pocketBaseProvider,
      ),
    );
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
        RepositoryProvider.value(value: _competitionRepository),
        RepositoryProvider.value(value: _clubRepository),
        RepositoryProvider.value(value: _tournamentModeSettingsRepository),
      ],
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
            authenticationRepository: _authenticationRepository,
            userRepository: _userRepository),
        child: const AppView(),
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
