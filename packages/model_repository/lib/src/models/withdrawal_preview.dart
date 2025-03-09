import 'package:model_repository/model_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: unused_import
import 'package:flutter/foundation.dart';

part 'generated/withdrawal_preview.freezed.dart';
part 'generated/withdrawal_preview.g.dart';

typedef PreviewMap
    = Map<SingleRelation<Competition>, MultiRelation<TournamentMatch>>;

@freezed
class WithdrawalPreview with _$WithdrawalPreview {
  const WithdrawalPreview._();
  factory WithdrawalPreview({
    required bool withdrawing,
    @JsonKey(name: 'changes')
    @_PreviewChangesConverter()
    required PreviewMap changesRel,
  }) = _WithdrawalPreview;

  Map<Competition, List<TournamentMatch>> get changes {
    Map<Competition, List<TournamentMatch>> c = {};
    for (SingleRelation<Competition> competitionRel in changesRel.keys) {
      var competition = competitionRel.model!;
      var match = changesRel[competitionRel]!.models;
      c[competition] = match;
    }
    return c;
  }

  factory WithdrawalPreview.fromJson(Map<String, dynamic> json) =>
      _$WithdrawalPreviewFromJson(json);
}

class _PreviewChangesConverter
    implements JsonConverter<PreviewMap, Map<String, dynamic>> {
  const _PreviewChangesConverter();

  @override
  PreviewMap fromJson(Map<String, dynamic> json) {
    PreviewMap preview = json.map(
      (key, value) {
        var competition = SingleRelation<Competition>(
          relationId: key,
        );
        var matchList = MultiRelation<TournamentMatch>(
          relationIds: List<String>.from(value),
        );
        return MapEntry(competition, matchList);
      },
    );
    return preview;
  }

  @override
  Map<String, dynamic> toJson(PreviewMap object) {
    throw UnimplementedError();
  }
}
