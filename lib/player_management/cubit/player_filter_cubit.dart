import 'package:bloc/bloc.dart';
import 'package:collection_repository/collection_repository.dart';
import 'package:ez_badminton_admin_app/list_filter/cubit/list_filter_cubit.dart';
import 'package:ez_badminton_admin_app/player_management/models/age.dart';
import 'package:ez_badminton_admin_app/player_management/models/search_term.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

part 'player_filter_state.dart';

class PlayerFilterCubit extends Cubit<PlayerFilterState> {
  PlayerFilterCubit({
    required CollectionRepository<PlayingLevel> playingLevelRepository,
  })  : _playingLevelRepository = playingLevelRepository,
        super(const PlayerFilterState()) {
    loadPlayingLevels();
  }

  final CollectionRepository<PlayingLevel> _playingLevelRepository;

  static const String genderDomain = 'gender';
  static const String underAgeDomain = 'under';
  static const String overAgeDomain = 'over';
  static const String searchDomain = 'search';

  static const String playingLevelConjunction = 'playingLevel';
  static const String competitionConjunction = 'competition';

  void loadPlayingLevels() async {
    if (state.loadingStatus != LoadingStatus.loading) {
      emit(state.copyWith(loadingStatus: LoadingStatus.loading));
    }
    try {
      List<PlayingLevel> playingLevels =
          await _playingLevelRepository.getList();
      emit(state.copyWith(
          allPlayingLevels: playingLevels, loadingStatus: LoadingStatus.done));
    } on CollectionFetchException {
      emit(state.copyWith(loadingStatus: LoadingStatus.failed));
    }
  }

  void predicateRemoved(FilterPredicate predicate) {
    switch (predicate.domain) {
      case genderDomain:
        genderChanged(null);
        break;
      case overAgeDomain:
        overAgeChanged('');
        ageFilterSubmitted();
        break;
      case underAgeDomain:
        underAgeChanged('');
        ageFilterSubmitted();
        break;
      case searchDomain:
        searchTermChanged('');
        break;
    }
    switch (predicate.disjunction) {
      case playingLevelConjunction:
        playingLevelToggled(predicate.domain);
        break;
      case competitionConjunction:
        competitionToggled(predicate.domain);
        break;
    }
  }

  void overAgeChanged(String ageInput) {
    PlayerFilterState newState = state.copyWith(overAge: Age.dirty(ageInput));
    emit(newState);
  }

  void underAgeChanged(String ageInput) {
    PlayerFilterState newState = state.copyWith(underAge: Age.dirty(ageInput));
    emit(newState);
  }

  void ageFilterSubmitted() {
    if (state.overAge.isValid) {
      _updateAgeFilter(true);
    }
    if (state.underAge.isValid) {
      _updateAgeFilter(false);
    }
  }

  void genderChanged(Gender? gender) {
    if (state.gender != gender) {
      PlayerFilterState newState = state.copyWith(gender: () => gender);
      String filterName = gender == null ? '' : gender.name;
      genderFilter(Object p) => (p as Player).gender == gender;
      var predicate = FilterPredicate(
        gender == null ? null : genderFilter,
        Player,
        filterName,
        genderDomain,
      );
      emit(newState.copyWithPredicate(filterPredicate: predicate));
    } else if (state.gender != null) {
      genderChanged(null);
    }
  }

  void playingLevelToggled(PlayingLevel playingLevel) {
    var playingLevels = List.of(state.playingLevels);
    FilterPredicate predicate;
    if (playingLevels.contains(playingLevel)) {
      playingLevels.remove(playingLevel);
      predicate = FilterPredicate(null, Player, '', playingLevel);
    } else {
      playingLevels.add(playingLevel);
      playingLevelFilter(Object p) =>
          (p as Player).playingLevel == playingLevel;
      predicate = FilterPredicate(
        playingLevelFilter,
        Player,
        playingLevel.name,
        playingLevel,
        playingLevelConjunction,
      );
    }

    var newState = state.copyWith(
      playingLevels: List.unmodifiable(playingLevels),
    );
    emit(newState.copyWithPredicate(filterPredicate: predicate));
  }

  void competitionToggled(CompetitionType competition) {
    var competitions = List.of(state.competitions);
    FilterPredicate predicate;
    if (competitions.contains(competition)) {
      competitions.remove(competition);
      predicate = FilterPredicate(null, Competition, '', competition);
    } else {
      competitions.add(competition);
      competitionFilter(Object c) =>
          (c as Competition).getCompetitionType() == competition;
      predicate = FilterPredicate(
        competitionFilter,
        Competition,
        competition.name,
        competition,
        competitionConjunction,
      );
    }

    var newState =
        state.copyWith(competitions: List.unmodifiable(competitions));
    emit(newState.copyWithPredicate(filterPredicate: predicate));
  }

  void searchTermChanged(String searchTerm) {
    PlayerFilterState newState =
        state.copyWith(searchTerm: SearchTerm.dirty(searchTerm));
    if (newState.searchTerm.isValid) {
      var cleanSearchTerm = searchTerm.trim().toLowerCase();
      textFilter(Object p) => _playerSearch(cleanSearchTerm, p as Player);
      var predicate = FilterPredicate(
        textFilter,
        Player,
        searchTerm,
        searchDomain,
      );
      emit(newState.copyWithPredicate(filterPredicate: predicate));
    } else if (searchTerm.isEmpty) {
      var predicate = const FilterPredicate(null, Player, '', searchDomain);
      emit(newState.copyWithPredicate(filterPredicate: predicate));
    } else {
      emit(newState);
    }
  }

  bool _playerSearch(String searchTerm, Player p) {
    var name = '${p.firstName} ${p.lastName}'.toLowerCase();
    var club = p.club.name.toLowerCase();

    return name.contains(searchTerm) || club.contains(searchTerm);
  }

  void _updateAgeFilter(
    bool over,
  ) {
    Age newAge = over ? state.overAge : state.underAge;
    String filterDomain = over ? overAgeDomain : underAgeDomain;
    PlayerFilterState newState;
    if (newAge.value.isEmpty) {
      var predicate = FilterPredicate(null, Player, '', filterDomain);
      newState = state.copyWithPredicate(filterPredicate: predicate);
    } else {
      int age = int.parse(newAge.value);
      String filterName = '$filterDomain$age';
      Predicate ageFilter = over
          ? (Object p) => (p as Player).calculateAge() >= age
          : (Object p) => (p as Player).calculateAge() < age;
      var predicate =
          FilterPredicate(ageFilter, Player, filterName, filterDomain);
      newState = state.copyWithPredicate(filterPredicate: predicate);
    }
    emit(newState);
  }
}
