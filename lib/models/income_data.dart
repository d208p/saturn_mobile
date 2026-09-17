class IncomeData {
  final double balance;
  final double totalIncome;
  final double averageMonthlyIncome;
  final List<ChartBarData> chartData;
  final List<UpcomingDistribution> upcomingDistributions;

  IncomeData({
    required this.balance,
    required this.totalIncome,
    required this.averageMonthlyIncome,
    required this.chartData,
    required this.upcomingDistributions,
  });

  factory IncomeData.fromJson(Map<String, dynamic> json) {
    return IncomeData(
      balance: (json['balance'] as num? ?? 0).toDouble(),
      totalIncome: (json['total_income'] as num? ?? 0).toDouble(),
      averageMonthlyIncome:
          (json['average_monthly_income'] as num? ?? 0).toDouble(),
      chartData: (json['chart_data'] as List? ?? [])
          .map((i) => ChartBarData.fromJson(i))
          .toList(),
      upcomingDistributions: (json['upcoming_distributions'] as List? ?? [])
          .map((i) => UpcomingDistribution.fromJson(i))
          .toList(),
    );
  }
}

class ChartBarData {
  final String label;
  final double value;
  final int height;

  ChartBarData({
    required this.label,
    required this.value,
    required this.height,
  });

  factory ChartBarData.fromJson(Map<String, dynamic> json) {
    return ChartBarData(
      label: json['label'] ?? '',
      value: (json['value'] as num? ?? 0).toDouble(),
      height: (json['height'] as num? ?? 0).toInt(),
    );
  }
}

class UpcomingDistribution {
  final String assetName;
  final double payout;
  final String date;

  UpcomingDistribution({
    required this.assetName,
    required this.payout,
    required this.date,
  });

  factory UpcomingDistribution.fromJson(Map<String, dynamic> json) {
    return UpcomingDistribution(
      assetName: json['asset_name'] ?? '',
      payout: (json['payout'] as num? ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}