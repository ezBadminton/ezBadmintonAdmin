// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:model_repository/model_repository.dart';
import 'package:pocketbase_provider/pocketbase_provider.dart';

class PocketbaseModelRepository extends ModelRepository {
  PocketbaseModelRepository({
    required PocketBaseProvider pocketbaseProvider,
  })  : _pbProvider = pocketbaseProvider,
        _stores = <Type, ModelStore>{} {
    _initStores();
  }

  final PocketBaseProvider _pbProvider;

  final Map<Type, ModelStore<dynamic>> _stores;

  Completer<void> _loadCompleter = Completer();
  @override
  Completer<void> get loadCompleter => _loadCompleter;

  @override
  ModelStore<M>? findStore<M extends Model>() {
    if (!_stores.containsKey(M)) {
      return null;
    }
    return _stores[M] as ModelStore<M>;
  }

  @override
  loadModels() {
    _pbProvider.whenAvailable.then<void>(_loadModels);
  }

  FutureOr<void> _loadModels(void _) async {
    if (_loadCompleter.isCompleted) {
      _loadCompleter = Completer();
    }

    var loadFutures = _stores.values.map((store) => store.loadCompleter.future);
    for (final modelStore in _stores.values) {
      modelStore.load();
    }

    await Future.wait(loadFutures);

    var allModels = _stores.values
        .expand((store) => store.getList())
        .toList()
        .cast<Model>();
    expandRelations(allModels);

    _loadCompleter.complete();
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
        case Court m:
          relations.add(m.gymnasiumRel);
        case MatchData m:
          relations.add(m.setsRel);
          relations.add(m.courtRel);
          relations.add(m.withdrawnTeamsRel);
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
    _stores[MatchData] = PocketbaseModelStore<MatchData>(
      repository: this,
      modelConstructor: MatchData.fromJson,
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
    _stores[Tournament] = PocketbaseModelStore<Tournament>(
      repository: this,
      modelConstructor: Tournament.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
    _stores[Registration] = PocketbaseModelStore<Registration>(
      repository: this,
      modelConstructor: Registration.fromJson,
      pocketBase: _pbProvider.pocketBase,
    );
  }
}
