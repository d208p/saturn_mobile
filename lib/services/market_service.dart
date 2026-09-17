import 'package:saturn_app/models/assets.dart';
import 'package:saturn_app/models/sellorder.dart';
import 'package:saturn_app/services/api_client.dart';

class MarketData {
  final List<Asset> newProjects;
  final List<Asset> secondaryAssets;
  final List<SellOrder> userListings;
  final List<Asset> watchlist;

  MarketData({
    required this.newProjects,
    required this.secondaryAssets,
    required this.userListings,
    required this.watchlist,
  });
}

class MarketService {
  final ApiClient _client = ApiClient();

  Future<MarketData> getMarket() async {
    final response = await _client.get('/market');
    final json = response as Map<String, dynamic>;

    List<Asset> parseAssets(String key) {
      return (json[key] as List? ?? [])
          .map((a) => Asset.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return MarketData(
      newProjects: parseAssets('new_projects'),
      secondaryAssets: parseAssets('secondary_assets'),
      userListings: (json['user_listings'] as List? ?? [])
          .map((o) => SellOrder.fromJson(o as Map<String, dynamic>))
          .toList(),
      watchlist: parseAssets('watchlist'),
    );
  }

  Future<void> cancelListing(int listingId) async {
    await _client.post('/listings/$listingId/cancel');
  }
}