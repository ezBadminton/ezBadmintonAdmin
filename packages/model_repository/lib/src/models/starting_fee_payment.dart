import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:model_repository/model_repository.dart';

part 'generated/starting_fee_payment.freezed.dart';
part 'generated/starting_fee_payment.g.dart';

@freezed
class StartingFeePayment extends Model with _$StartingFeePayment {
  const StartingFeePayment._();

  const factory StartingFeePayment({
    required String id,
    required DateTime created,
    required DateTime updated,
    @JsonKey(name: 'player') required SingleRelation<Player> playerRel,
    required int amount,
    required int massDiscount,
    required int discountPercent,
  }) = _StartingFeePayment;

  Player get player => playerRel.model!;

  factory StartingFeePayment.fromJson(Map<String, dynamic> json) =>
      _$StartingFeePaymentFromJson(json);
}
