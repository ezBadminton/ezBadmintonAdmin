// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:collection/collection.dart';
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
      // TODO reset repository
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

    var allModels = _stores.values
        .expand((store) => store.getList())
        .toList()
        .cast<Model>();
    expandRelations(allModels);

    _isLoaded = true;
    _controller.add(RepositoryEvent.loaded);
  }

  @override
  created(Model model) {
    expandRelations([model]);
  }

  @override
  updated(Model model) {
    expandRelations([model]);
    var relMap = reverseRelations[model.id];
    if (relMap == null) {
      return;
    }
    var relations = relMap.values.expand((e) => e);
    for (final relation in relations) {
      switch (relation) {
        case SingleRelation r:
          r.model = model;
        case MultiRelation r:
          var i = r.models.indexWhere((e) => e.id == model.id);
          r.models[i] = model;
      }
    }
  }

  @override
  deleted(Model model) {
    reverseRelations.remove(model.id);
    _resetReverseRelations(model);
  }

  @override
  expandRelations(List<dynamic> models) {
    for (final model in models) {
      if (model is Model) {
        _resetReverseRelations(model);
      }
    }

    for (final model in models) {
      var relations = <Relation>[];
      switch (model) {
        case Competition m:
          relations.add(m.ageGroupRel);
          relations.add(m.playingLevelRel);
          relations.add(m.registrationsRel);
          relations.add(m.seedsRel);
          relations.add(m.drawRel);
          relations.add(m.tournamentModeSettingsRel);
          relations.add(m.matchesRel);
          relations.add(m.tieBreakersRel);
          relations.add(m.planRel);
        case Court m:
          relations.add(m.gymnasiumRel);
        case Player m:
          relations.add(m.clubRel);
        case Team m:
          relations.add(m.playersRel);
        case TieBreaker m:
          relations.add(m.tieBreakerRankingRel);
        case Registration m:
          relations.add(m.competitionRel);
          relations.add(m.teamRel);
        case WithdrawalPreview m:
          for (var e in m.changesRel.entries) {
            relations.add(e.key);
            relations.add(e.value);
          }
        case Schedule m:
          relations.add(m.roundQueueRel);
        case ScheduledRound m:
          relations.add(m.competitionRel);
          relations.add(m.matchesRel);
        case ScheduledMatch m:
          relations.add(m.matchRel);
          for (var MapEntry(key: playerRel, value: block)
              in m.blockingPlayersRel.entries) {
            relations.add(playerRel);
            relations.add(block.blockingMatchRel);
          }
        case TournamentPlan m:
          relations.add(m.competitionRel);
          var t = m.tournament;
          relations.add(t.editableRel);
          relations.addAll(t.entriesRel.flattened.map((slot) => slot.teamRel));
          relations
              .addAll(t.finalRankingRel.flattened.map((slot) => slot.teamRel));
          relations.addAll(t.relations);
        case TournamentMatch m:
          relations.add(m.setsRel);
          relations.add(m.courtRel);
          relations.add(m.withdrawnTeamsRel);
          relations.add(m.winnerRel);
          relations.add(m.slot1.teamRel);
          relations.add(m.slot2.teamRel);
      }

      for (final relation in relations) {
        relation.expandRelation();
      }

      if (model is Model) {
        _addReverseRelations(model.id, relations);
      }
    }
  }

  _addReverseRelations(String modelId, List<Relation> relations) {
    for (final relation in relations) {
      switch (relation) {
        case SingleRelation m:
          _addReverseRelation(m.relationId, modelId, relation);
        case MultiRelation m:
          for (final id in m.relationIds) {
            _addReverseRelation(id, modelId, relation);
          }
      }
    }
  }

  _addReverseRelation(String childId, String parentId, Relation relation) {
    if (childId == "") {
      return;
    }
    var relMap = reverseRelations.putIfAbsent(childId, () => {});
    var relList = relMap.putIfAbsent(parentId, () => []);
    relList.add(relation);
  }

  _resetReverseRelations(Model model) {
    for (final relMap in reverseRelations.values) {
      relMap.remove(model.id);
    }
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
    _stores[MatchSet] = PocketbaseModelStore<MatchSet>(
      repository: this,
      modelConstructor: MatchSet.fromJson,
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
  }
}
