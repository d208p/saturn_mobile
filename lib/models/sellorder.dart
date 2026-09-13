import 'package:saturn_app/models/assets.dart';

/// Mirrors the `SellOrder` model, as returned in `userListings` by
/// MarketController.
class SellOrder {
  final int id;
  final int shares;
  final double pricePerShare;
  final String status;
  final DateTime? createdAt;
  final Asset? asset;

  SellOrder({
    required this.id,
    required this.shares,
    required this.pricePerShare,
    required this.status,
    this.createdAt,
    this.asset,
  });

  factory SellOrder.fromJson(Map<String, dynamic> json) {
    return SellOrder(
      id: json['id'] as int,
      shares: json['shares'] ?? 0,
      pricePerShare: json['price_per_share'] == null
          ? 0
          : double.tryParse(json['price_per_share'].toString()) ?? 0,
      status: json['status'] ?? 'unknown',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      asset: json['asset'] != null ? Asset.fromJson(json['asset']) : null,
    );
  }
}