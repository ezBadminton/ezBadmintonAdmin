// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:model_repository/model_repository.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';

class PocketbaseModelRepository extends ModelRepository {
  PocketbaseModelRepository({
    required PocketBaseProvider pocketbaseProvider,
    required AuthenticationRepository authRepository,
  })  : _pbProvider = pocketbaseProvider,
        _stores = <Type, ModelStore>{},
        _isLoaded = false,
        _controller = StreamController.broadcast() {
    _initStores();
    authRepository.status.listen(handleAuthChange);
  }

  final PocketBaseProvider _pbProvider;

  final Map<Type, ModelStore<dynamic>> _stores;

  bool _isLoaded;
  @override
  bool get isLoaded => _isLoaded;

  final StreamController<RepositoryEvent> _controller;
  @override
  Stream<RepositoryEvent> get loadStream => _controller.stream;

  void handleAuthChange(AuthenticationStatus status) {
    switch (status) {
      case AuthenticationStatus.authenticated:
        loadModels();
      default:
        _resetModels();
    }
  }

  @override
  ModelStore<M>? findStore<M extends Model>() {
    if (!_stores.containsKey(M)) {
      return null;
    }
    return _stores[M] as ModelStore<M>;
  }

  @override
  loadModels() async {
    var loadFutures = _stores.values.map((store) => store.load());

    await Future.wait(loadFutures);

    var allModels =
        _stores.values.expand((store) => store.getList()).cast<Model>();
    models = {
      for (final model in allModels) model.id: model,
    };

    _isLoaded = true;
    _controller.add(RepositoryEvent.loaded);
  }

  _resetModels() {
    _isLoaded = false;
    models.clear();
    _controller.add(RepositoryEvent.reset);
  }

  @override
  created(Model model) {
    models[model.id] = model;
  }

  @override
  updated(Model model) {
    models[model.id] = model;
  }

  @override
  deleted(Model model) {
    models.remove(model.id);
  }

  _initStores() {
    _stores[AgeGroup] = PocketbaseModelStore<AgeGroup>(
      repository: this,
      modelConstructor: AgeGroup.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Club] = PocketbaseModelStore<Club>(
      repository: this,
      modelConstructor: Club.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Competition] = PocketbaseModelStore<Competition>(
      repository: this,
      modelConstructor: Competition.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Court] = PocketbaseModelStore<Court>(
      repository: this,
      modelConstructor: Court.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Gymnasium] = PocketbaseModelStore<Gymnasium>(
      repository: this,
      modelConstructor: Gymnasium.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Player] = PocketbaseModelStore<Player>(
      repository: this,
      modelConstructor: Player.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[PlayingLevel] = PocketbaseModelStore<PlayingLevel>(
      repository: this,
      modelConstructor: PlayingLevel.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Team] = PocketbaseModelStore<Team>(
      repository: this,
      modelConstructor: Team.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[TieBreaker] = PocketbaseModelStore<TieBreaker>(
      repository: this,
      modelConstructor: TieBreaker.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[TournamentModeSettings] =
        PocketbaseModelStore<TournamentModeSettings>(
      repository: this,
      modelConstructor: TournamentModeSettings.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[TournamentEvent] = PocketbaseModelStore<TournamentEvent>(
      repository: this,
      modelConstructor: TournamentEvent.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[TournamentMatch] = PocketbaseModelStore<TournamentMatch>(
      repository: this,
      modelConstructor: TournamentMatch.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Registration] = PocketbaseModelStore<Registration>(
      repository: this,
      modelConstructor: Registration.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Schedule] = PocketbaseModelStore<Schedule>(
      repository: this,
      modelConstructor: Schedule.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[ScheduledRound] = PocketbaseModelStore<ScheduledRound>(
      repository: this,
      modelConstructor: ScheduledRound.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[ScheduledMatch] = PocketbaseModelStore<ScheduledMatch>(
      repository: this,
      modelConstructor: ScheduledMatch.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[TournamentPlan] = PocketbaseModelStore<TournamentPlan>(
      repository: this,
      modelConstructor: TournamentPlan.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[InfoscreenUser] = PocketbaseModelStore<InfoscreenUser>(
      repository: this,
      modelConstructor: InfoscreenUser.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[StartingFeeMassDiscount] =
        PocketbaseModelStore<StartingFeeMassDiscount>(
      repository: this,
      modelConstructor: StartingFeeMassDiscount.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[StartingFeePayment] = PocketbaseModelStore<StartingFeePayment>(
      repository: this,
      modelConstructor: StartingFeePayment.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
  }
}
