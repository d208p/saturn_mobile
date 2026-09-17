class CreateListingData {
  final int assetId;
  final String assetTitle;
  final double sharePrice;
  final int userShares;

  CreateListingData({
    required this.assetId,
    required this.assetTitle,
    required this.sharePrice,
    required this.userShares,
  });

  factory CreateListingData.fromJson(Map<String, dynamic> json) {
    return CreateListingData(
      assetId: json['asset']['id'],
      assetTitle: json['asset']['title'] ?? '',
      sharePrice: (json['asset']['share_price'] as num? ?? 0).toDouble(),
      userShares: (json['user_shares'] as num? ?? 0).toInt(),
    );
  }
}