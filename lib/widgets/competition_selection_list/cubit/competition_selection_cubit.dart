import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ez_badminton_admin_app/competition_management/competition_sorter/comparators/competition_comparator.dart';
import 'package:ez_badminton_admin_app/l10n/gen/app_localizations.dart';
import 'package:model_repository/model_repository.dart';
import 'package:ez_badminton_admin_app/collection_queries/collection_querier.dart';
import 'package:ez_badminton_admin_app/input_models/models.dart';
import 'package:ez_badminton_admin_app/widgets/loading_screen/loading_screen.dart';
import 'package:ez_badminton_admin_app/display_strings/display_strings.dart'
    as display_strings;

part 'competition_selection_state.dart';

class CompetitionSelectionCubit
    extends CollectionQuerierCubit<CompetitionSelectionState> {
  CompetitionSelectionCubit({
    required ModelStore<Competition> competitionStore,
    required ModelStore<TournamentPlan> tPlanStore,
    required ModelStore<InfoscreenUser> infoscreenUserStore,
    required this.commandRepository,
    required this.l10n,
    this.cyclingInterval = Duration.zero,
  }) : super(
          modelStores: [
            competitionStore,
            tPlanStore,
            infoscreenUserStore,
          ],
          CompetitionSelectionState(),
        ) {
    subscribeToCollectionUpdates(
      competitionStore,
      _onCompetitionCollectionUpdate,
    );
    _commandSubscription = commandRepository.messageStream.listen(
      handleCommand,
    );
  }

  final AppLocalizations l10n;
  final RealtimeRepository<InfoscreenCommand> commandRepository;
  final CompetitionComparator _competitionComparator = CompetitionComparator();
  late final StreamSubscription _commandSubscription;

  final Duration? cyclingInterval;
  Timer? _timer;

  @override
  void onCollectionUpdate(
    List<List<Model>> collections,
    CollectionUpdateEvent<Model>? updateEvent,
  ) {
    List<Competition> oldCompetitions = state.hasCollection<Competition>()
        ? state.getCollection<Competition>()
        : [];

    CompetitionSelectionState updatedState = state.copyWith(
      collections: collections,
      loadingStatus: LoadingStatus.done,
    );

    List<Competition> sortedCompetitions = updatedState
        .getCollection<Competition>()
        .where((competition) => competition.tournamentPlan?.started ?? false)
        .sorted(_competitionComparator.comparator);

    updatedState.overrideCollection(sortedCompetitions);

    emit(updatedState);

    postDisplayCompetitions(oldCompetitions, sortedCompetitions);

    if (cyclingInterval != null && _timer == null) {
      cycleCompetition();
    }
  }

  void competitionToggled(Competition competition) {
    Competition? selectedCompetition = competition;
    if (state.selectedCompetition.value == competition) {
      selectedCompetition = null;
    }

    competitionSelected(selectedCompetition);
  }

  void competitionSelected(Competition? selectedCompetition) {
    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: selectedCompetition),
    ));
  }

  void cycleCompetition() {
    List<Competition> competitions = state.getCollection<Competition>();
    if (competitions.isEmpty) {
      return;
    }

    Competition? current = state.selectedCompetition.value;
    int nextIndex = 0;
    if (current != null) {
      nextIndex = (competitions.indexOf(current) + 1) % competitions.length;
    }
    Competition next = competitions[nextIndex];
    emit(state.copyWith(
      selectedCompetition: SelectionInput.dirty(value: next),
    ));

    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(cyclingInterval!, (_) => cycleCompetition());
    }
  }

  void handleCommand(InfoscreenCommand command) {
    pauseCycle();
    if (command.select == "") {
      return;
    }
    Competition? selected = state
        .getCollection<Competition>()
        .firstWhereOrNull((competition) => competition.id == command.select);
    if (selected == null) {
      return;
    }
    competitionSelected(selected);
  }

  void pauseCycle() {
    if (_timer == null || cyclingInterval == null) {
      return;
    }
    _timer!.cancel();
    _timer = Timer(Duration(seconds: 40), cycleCompetition);
  }

  void postDisplayCompetitions(
    List<Competition> oldCompetitions,
    List<Competition> competitions,
  ) {
    if (oldCompetitions.equals(competitions)) {
      return;
    }

    InfoscreenUser? infoscreenUser =
        state.getCollection<InfoscreenUser>().firstOrNull;

    if (infoscreenUser == null) {
      return;
    }

    List<String> competitionIds = [];
    List<String> competitionDisplayNames = [];

    for (final competition in competitions) {
      List<String> nameParts = [];
      if (competition.playingLevel != null) {
        nameParts.add(competition.playingLevel!.name);
      }
      if (competition.ageGroup != null) {
        nameParts.add(display_strings.ageGroup(l10n, competition.ageGroup!));
      }
      nameParts.add(display_strings.competitionGenderAndType(
        l10n,
        competition.genderCategory,
        competition.type,
      ));

      String displayName = nameParts.join(" • ");

      competitionIds.add(competition.id);
      competitionDisplayNames.add(displayName);
    }

    infoscreenUser = infoscreenUser.copyWith(
      infoItems: [competitionIds, competitionDisplayNames],
    );

    querier.updateModel(infoscreenUser);
  }

  void _onCompetitionCollectionUpdate(
    CollectionUpdateEvent<Competition>? event,
  ) {
    if (event == null || event.model != state.selectedCompetition.value) {
      return;
    }

    switch (event.updateType) {
      case UpdateType.update:
        emit(state.copyWith(
          selectedCompetition: SelectionInput.dirty(
            value: event.model,
          ),
        ));
        break;
      case UpdateType.delete:
        emit(state.copyWith(
          selectedCompetition: const SelectionInput.dirty(value: null),
        ));
        break;
      case UpdateType.create:
        break;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _commandSubscription.cancel();
    return super.close();
  }
}
