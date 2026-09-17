class SecondaryMarketData {
  final SecondaryAssetSummary asset;
  final int totalAvailableShares;
  final double minPrice;
  final List<MarketListing> listings;

  SecondaryMarketData({
    required this.asset,
    required this.totalAvailableShares,
    required this.minPrice,
    required this.listings,
  });

  factory SecondaryMarketData.fromJson(Map<String, dynamic> json) {
    return SecondaryMarketData(
      asset: SecondaryAssetSummary.fromJson(json['asset']),
      totalAvailableShares: (json['total_available_shares'] as num? ?? 0).toInt(),
      minPrice: (json['min_price'] as num? ?? 0).toDouble(),
      listings: (json['listings'] as List? ?? [])
          .map((i) => MarketListing.fromJson(i))
          .toList(),
    );
  }
}

class SecondaryAssetSummary {
  final int id;
  final String title;
  final String location;

  SecondaryAssetSummary({
    required this.id,
    required this.title,
    required this.location,
  });

  factory SecondaryAssetSummary.fromJson(Map<String, dynamic> json) {
    return SecondaryAssetSummary(
      id: json['id'],
      title: json['title'] ?? '',
      location: json['location'] ?? 'Global',
    );
  }
}

class MarketListing {
  final int id;
  final String sellerName;
  final double pricePerShare;
  final int shares;
  final double subtotal;

  MarketListing({
    required this.id,
    required this.sellerName,
    required this.pricePerShare,
    required this.shares,
    required this.subtotal,
  });

  factory MarketListing.fromJson(Map<String, dynamic> json) {
    return MarketListing(
      id: json['id'],
      sellerName: json['seller_name'] ?? 'User',
      pricePerShare: (json['price_per_share'] as num? ?? 0).toDouble(),
      shares: (json['shares'] as num? ?? 0).toInt(),
      subtotal: (json['subtotal'] as num? ?? 0).toDouble(),
    );
  }
}