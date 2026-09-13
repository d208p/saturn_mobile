import 'package:saturn_app/models/assets.dart';

class Holding {
  final int id;
  final int userId;
  final int assetId;
  final int sharesOwned;
  final double totalInvested;
  final Asset? asset;

  Holding({
    required this.id,
    required this.userId,
    required this.assetId,
    required this.sharesOwned,
    required this.totalInvested,
    this.asset,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      assetId: json['asset_id'] ?? 0,
      sharesOwned: json['shares_owned'] ?? 0,
      totalInvested: double.tryParse(json['total_invested']?.toString() ?? '0') ?? 0.0,
      asset: json['asset'] != null ? Asset.fromJson(json['asset']) : null,
    );
  }

  double get currentValue => sharesOwned * (asset?.sharePrice ?? 0.0);
}