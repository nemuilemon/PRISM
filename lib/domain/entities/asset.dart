import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset.freezed.dart';

@freezed
sealed class Asset with _$Asset {
  // 現金・預金
  const factory Asset.financial({
    required String id,
    required String name,
    required double amount,
    required String currency,
  }) = FinancialAsset;

  // ポイント資産
  const factory Asset.point({
    required String id,
    required String providerName,
    required int points,
    required double exchangeRate, // 円換算レート
    DateTime? expiryDate,
  }) = PointAsset;

  // 時間・経験資産（自己投資）
  const factory Asset.experience({
    required String id,
    required String activityName,
    required Duration totalTime,
    required int accumulatedLevel, // 独自のレベル概念
  }) = ExperienceAsset;
}
