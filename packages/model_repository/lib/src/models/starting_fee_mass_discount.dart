import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';

part 'generated/starting_fee_mass_discount.freezed.dart';
part 'generated/starting_fee_mass_discount.g.dart';

@freezed
class StartingFeeMassDiscount extends Model with _$StartingFeeMassDiscount {
  const StartingFeeMassDiscount._();

  const factory StartingFeeMassDiscount({
    required String id,
    required DateTime created,
    required DateTime updated,
    required int minRegistrations,
    required int discountAmount,
  }) = _StartingFeeMassDiscount;

  factory StartingFeeMassDiscount.fromJson(Map<String, dynamic> json) =>
      _$StartingFeeMassDiscountFromJson(json);

  factory StartingFeeMassDiscount.newStartingFeeMassDiscount({
    required int minRegistrations,
    required int discountAmount,
  }) {
    return StartingFeeMassDiscount(
      id: '',
      created: DateTime.now().toUtc(),
      updated: DateTime.now().toUtc(),
      minRegistrations: minRegistrations,
      discountAmount: discountAmount,
    );
  }
}
