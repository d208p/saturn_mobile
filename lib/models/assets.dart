class Asset {
  final int id;
  final String title;
  final String? category;
  final String? status;
  final double sharePrice;
  final double? totalValuation;
  final int? totalShares;
  final int? availableShares;
  final int? activeListingsCount;
  final int? totalSecondaryShares;
  final double? minPrice;

  Asset({
    required this.id,
    required this.title,
    this.category,
    this.status,
    required this.sharePrice,
    this.totalValuation,
    this.totalShares,
    this.availableShares,
    this.activeListingsCount,
    this.totalSecondaryShares,
    this.minPrice,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      return int.tryParse(value.toString());
    }

    return Asset(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Asset',
      category: json['category'],
      status: json['status'],
      sharePrice: parseDouble(json['share_price']),
      totalValuation: parseDouble(json['total_valuation']),
      totalShares: parseInt(json['total_shares']),
      availableShares: parseInt(json['available_shares']),
      activeListingsCount: parseInt(json['active_listings_count']),
      totalSecondaryShares: parseInt(json['total_secondary_shares']),
      minPrice: parseDouble(json['min_price']),
    );
  }
}