import 'package:saturn_app/services/api_client.dart';
import '../models/holding.dart';

class PortfolioData {
  final double portfolioValue;
  final double investedTotal;
  final double availableCash;
  final List<Holding> holdings;

  PortfolioData({
    required this.portfolioValue,
    required this.investedTotal,
    required this.availableCash,
    required this.holdings,
  });

  /// Calculates holdings current total market value
  double get holdingsValue =>
      holdings.fold(0.0, (sum, h) => sum + h.currentValue);

  /// Groups holdings by asset category and returns total value per category
  Map<String, double> get categoryAllocation {
    final Map<String, double> categories = {};
    for (final holding in holdings) {
      final category = holding.asset?.category ?? 'Other';
      categories[category] = (categories[category] ?? 0) + holding.currentValue;
    }
    return categories;
  }
}

class PortfolioService {
  final ApiClient _client = ApiClient();

  Future<PortfolioData> getPortfolio() async {
    final response = await _client.get('/portfolio');
    final json = response as Map<String, dynamic>;

    final holdingsList = (json['holdings'] as List? ?? [])
        .map((h) => Holding.fromJson(h as Map<String, dynamic>))
        .toList();

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return PortfolioData(
      portfolioValue: parseDouble(json['portfolio_value']),
      investedTotal: parseDouble(json['invested_total']),
      availableCash: parseDouble(json['available_cash']),
      holdings: holdingsList,
    );
  }
}