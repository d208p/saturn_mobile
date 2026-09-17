class TradeData {
  final TradeAssetSummary asset;
  final int userShares;

  TradeData({
    required this.asset,
    required this.userShares,
  });

  factory TradeData.fromJson(Map<String, dynamic> json) {
    return TradeData(
      asset: TradeAssetSummary.fromJson(json['asset']),
      userShares: (json['user_shares'] as num? ?? 0).toInt(),
    );
  }
}

class TradeAssetSummary {
  final int id;
  final String title;
  final double sharePrice;
  final int availableShares;
  final String status;

  TradeAssetSummary({
    required this.id,
    required this.title,
    required this.sharePrice,
    required this.availableShares,
    required this.status,
  });

  factory TradeAssetSummary.fromJson(Map<String, dynamic> json) {
    return TradeAssetSummary(
      id: json['id'],
      title: json['title'] ?? '',
      sharePrice: (json['share_price'] as num? ?? 0).toDouble(),
      availableShares: (json['available_shares'] as num? ?? 0).toInt(),
      status: json['status'] ?? 'active',
    );
  }
}