class AssetDetailData {
  final AssetDetail asset;
  final HoldingDetail holding;
  final List<DistributionDetail> distributions;

  AssetDetailData({
    required this.asset,
    required this.holding,
    required this.distributions,
  });

  factory AssetDetailData.fromJson(Map<String, dynamic> json) {
    return AssetDetailData(
      asset: AssetDetail.fromJson(json['asset']),
      holding: HoldingDetail.fromJson(json['holding']),
      distributions: (json['distributions'] as List? ?? [])
          .map((d) => DistributionDetail.fromJson(d))
          .toList(),
    );
  }
}

class AssetDetail {
  final int id;
  final String title;
  final String location;
  final String category;
  final String description;
  final double sharePrice;
  final double totalValuation;
  final double targetYield;
  final double totalReturn;
  final double revenueTtm;
  final double occupancyRate;
  final double noi;
  final int availableShares;
  final bool isFavorited;

  AssetDetail({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.description,
    required this.sharePrice,
    required this.totalValuation,
    required this.targetYield,
    required this.totalReturn,
    required this.revenueTtm,
    required this.occupancyRate,
    required this.noi,
    required this.availableShares,
    required this.isFavorited,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    return AssetDetail(
      id: json['id'],
      title: json['title'] ?? '',
      location: json['location'] ?? 'Global',
      category: json['category'] ?? 'Real Estate',
      description: json['description'] ?? '',
      sharePrice: (json['share_price'] as num? ?? 0).toDouble(),
      totalValuation: (json['total_valuation'] as num? ?? 0).toDouble(),
      targetYield: (json['target_yield'] as num? ?? 0).toDouble(),
      totalReturn: (json['total_return'] as num? ?? 0).toDouble(),
      revenueTtm: (json['revenue_ttm'] as num? ?? 0).toDouble(),
      occupancyRate: (json['occupancy_rate'] as num? ?? 0).toDouble(),
      noi: (json['noi'] as num? ?? 0).toDouble(),
      availableShares: (json['available_shares'] as num? ?? 0).toInt(),
      isFavorited: json['is_favorited'] ?? false,
    );
  }
}

class HoldingDetail {
  final double unitsOwned;
  final double currentValue;
  final double avgPurchasePrice;
  final double unrealizedGain;

  HoldingDetail({
    required this.unitsOwned,
    required this.currentValue,
    required this.avgPurchasePrice,
    required this.unrealizedGain,
  });

  factory HoldingDetail.fromJson(Map<String, dynamic> json) {
    return HoldingDetail(
      unitsOwned: (json['units_owned'] as num? ?? 0).toDouble(),
      currentValue: (json['current_value'] as num? ?? 0).toDouble(),
      avgPurchasePrice: (json['avg_purchase_price'] as num? ?? 0).toDouble(),
      unrealizedGain: (json['unrealized_gain'] as num? ?? 0).toDouble(),
    );
  }
}

class DistributionDetail {
  final String date;
  final String type;
  final double amountPerShare;

  DistributionDetail({
    required this.date,
    required this.type,
    required this.amountPerShare,
  });

  factory DistributionDetail.fromJson(Map<String, dynamic> json) {
    return DistributionDetail(
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      amountPerShare: (json['amount_per_share'] as num? ?? 0).toDouble(),
    );
  }
}